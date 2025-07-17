import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame  # <-- Add this import

# Get arguments vishal
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'SOURCE_DATABASE', 'SOURCE_TABLE', 'OUTPUT_PATH'])

# Initialize contexts
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Step 1: Read from Glue Catalog
dyf = glueContext.create_dynamic_frame.from_catalog(
    database=args['SOURCE_DATABASE'],
    table_name=args['SOURCE_TABLE']
)

# Step 2: Filter using Spark DataFrame
df = dyf.toDF().filter("age >= 21")

# Step 3: Convert back to DynamicFrame
dyf_filtered = DynamicFrame.fromDF(df, glueContext, "dyf_filtered")

# Step 4: Write to S3 in Parquet format
glueContext.write_dynamic_frame.from_options(
    frame=dyf_filtered,
    connection_type="s3",
    connection_options={"path": args['OUTPUT_PATH']},
    format="parquet"
)

# Step 5: Commit job
job.commit()
