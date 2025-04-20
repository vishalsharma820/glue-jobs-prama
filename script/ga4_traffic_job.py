import sys
import subprocess

subprocess.run(["pip", "install", "google-analytics-data", "--target", "/tmp/dependencies"])
sys.path.append("/tmp/dependencies")

from pyspark.sql import SparkSession
import os
import boto3
import logging
from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import (
    RunReportRequest,
    DateRange,
    Dimension,
    Metric,
)
from pyspark.sql.functions import to_date, date_format
from datetime import datetime, timedelta

# === Directory Paths ===
S3_BUCKET = "legacy-data-pod-peach"
S3_RAW_PREFIX = f"bronze/traffic/raw_data_test/"
ICEBERG_TABLE = "glue_catalog.legacy_data_pod_db_test.bronze_traffic_tbl_test"
S3_CREDENTIALS_PATH = f"bronze/traffic/config.json"

s3 = boto3.client("s3")

# Initialize Spark session
spark = SparkSession.builder.appName("GA4TrafficDataProcessingTest") \
    .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
    .config("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.glue_catalog.type", "glue") \
    .config("spark.sql.catalog.glue_catalog.warehouse", f"s3://{S3_BUCKET}/bronze/") \
    .getOrCreate()

# === Logging Setup ===
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger()

def download_credentials_from_s3():
    try:
        obj = s3.get_object(Bucket=S3_BUCKET, Key=S3_CREDENTIALS_PATH)
        creds_data = obj["Body"].read().decode("utf-8")
        temp_cred_path = "/tmp/google_credentials.json"
        with open(temp_cred_path, "w") as f:
            f.write(creds_data)
        return temp_cred_path
    except Exception as e:
        logger.error(f"Error downloading credentials from S3: {str(e)}")
        return None

def fetch_data_for_date(date: str):
    logger.info(f"Fetching data for {date}")
    try:
        request = RunReportRequest(
            property=f"properties/{property_id}",
            dimensions=[Dimension(name="date")],
            metrics=[Metric(name="totalUsers"), Metric(name="screenPageViews")],
            date_ranges=[DateRange(start_date=date, end_date=date)],
        )
        response = client.run_report(request)
        if response.rows:
            date_value = response.rows[0].dimension_values[0].value
            formatted_date = datetime.strptime(date_value, "%Y%m%d").strftime("%Y-%m-%d")
            return {"Date": formatted_date, "Total Users": int(response.rows[0].metric_values[0].value), "Pageviews": int(response.rows[0].metric_values[1].value)}
    except Exception as e:
        logger.error(f"Error fetching data for {date}: {str(e)}")
    return None

def get_all_dates(start_date: str, end_date: str):
    start = datetime.strptime(start_date, "%Y-%m-%d")
    end = datetime.strptime(end_date, "%Y-%m-%d")
    return [(start + timedelta(days=i)).strftime("%Y-%m-%d") for i in range((end - start).days + 1)]

def fetch_and_update_data(start_date, end_date):
    dates = get_all_dates(start_date, end_date)
    new_data = [fetch_data_for_date(date) for date in dates]

    if not new_data:
        logger.info("No new data fetched.")
        return

    # Convert new data to DataFrame
    new_df = spark.createDataFrame(new_data)
    new_df = new_df.withColumn("date", to_date("date", "yyyy-MM-dd"))
    
    new_df = new_df.withColumnRenamed("Total Users", "total_users") \
            .withColumnRenamed("Pageviews", "pageviews") \
            .withColumn("year_month", date_format("date", "yyyy-MM"))

    # Check if table exists
    table_exists = spark._jsparkSession.catalog().tableExists(ICEBERG_TABLE)

    if not table_exists:
        spark.sql(f"""
        CREATE TABLE {ICEBERG_TABLE} (
            total_users BIGINT,
            pageviews BIGINT,
            date DATE,
            year_month STRING
        )
        USING iceberg
        PARTITIONED BY (year_month)
        LOCATION 's3://{S3_BUCKET}/{S3_RAW_PREFIX}'
        TBLPROPERTIES ('format-version' = '2')
        """)
        
        logger.info(f"✅ Table {ICEBERG_TABLE} created.")

        new_df.writeTo(ICEBERG_TABLE).append()
        logger.info("✅ Initial data appended.")

    else:
        # Use MERGE INTO for incremental updates
        new_df.createOrReplaceTempView("staging_traffic_tbl")

        spark.sql(f"""
            MERGE INTO {ICEBERG_TABLE} AS target
            USING staging_traffic_tbl AS source
            ON target.date = source.date

            WHEN MATCHED THEN
                UPDATE SET
                    target.total_users = source.total_users,
                    target.pageviews = source.pageviews,
                    target.year_month = source.year_month

            WHEN NOT MATCHED THEN
                INSERT (total_users, pageviews, date, year_month)
                VALUES (source.total_users, source.pageviews, source.date, source.year_month)
        """)

        logger.info("✅ Incremental MERGE completed.")

def main():
    credentials_path = download_credentials_from_s3()
    if credentials_path:
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = credentials_path
        logger.info("Google Analytics credentials loaded from S3.")
    else:
        logger.error("Failed to load Google Analytics credentials from S3.")
    
    global property_id, client
    property_id = "262388854"
    client = BetaAnalyticsDataClient()
    
    fetch_and_update_data("2024-01-01", "2025-04-04")
    
    today = datetime.utcnow()
    last_week = today - timedelta(days=7)
    fetch_and_update_data(last_week.strftime("%Y-%m-%d"), today.strftime("%Y-%m-%d"))

if __name__ == "__main__":
    main()