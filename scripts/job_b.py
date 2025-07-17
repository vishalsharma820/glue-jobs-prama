import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from awsglue.job import Job
from pyspark.sql.functions import upper, col

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'INPUT_PATH', 'FINAL_OUTPUT_PATH'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Read from previous output
df = spark.read.parquet(args['INPUT_PATH'])

# Transform: uppercase names
df_transformed = df.withColumn("name", upper(col("name")))

# Show for debugging
df_transformed.show()

# Write final result
df_transformed.write.mode("overwrite").parquet(args['FINAL_OUTPUT_PATH'])

job.commit()
