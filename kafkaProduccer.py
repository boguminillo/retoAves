from pyspark.sql import SparkSession
from pyspark.sql.functions import to_json, struct
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType

# Create a SparkSession
spark = (SparkSession.builder.appName("KafkaProducer")
         .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0")
         .getOrCreate())

# Define the schema of your JSON string
schema = StructType([
    StructField("sciName", StringType()),
    StructField("howMany", IntegerType()),
    StructField("locName", StringType()),
    StructField("lat", DoubleType()),
    StructField("lng", DoubleType()),
    StructField("tmed", DoubleType()),
    StructField("prec", DoubleType()),
    StructField("velmedia", DoubleType()),
    StructField("year", IntegerType()),
    StructField("month", IntegerType()),
    StructField("day", IntegerType()),
    StructField("exoticCategoryN", StringType()),
    StructField("exoticCategoryP", StringType()),
    StructField("exoticCategoryX", StringType())
])

# Read the CSV file
df = spark.read.csv('assets/data/birdData.csv', schema=schema, header=True)

# Convert all columns to a JSON string and rename it as 'value'
df = df.select(to_json(struct("*")).alias("value"))

# Write the DataFrame to the Kafka server
df.write.format("kafka") \
  .option("kafka.bootstrap.servers", "10.22.82.181:9092") \
  .option("topic", "retoJulen") \
  .save()

# Stop the SparkSession
# spark.stop()