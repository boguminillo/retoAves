from pyspark.sql import SparkSession
from pyspark.sql.functions import col, from_json
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType

# Create a SparkSession
spark = (SparkSession.builder.appName("KafkaConsumer")
         .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0")
         .getOrCreate())

# Define the Kafka consumer
df = (spark.readStream.format("kafka")
      .option("kafka.bootstrap.servers", "10.22.82.181:9092")
      .option("subscribe", "retoJulen")
      .load())

# Select the 'value' column and cast it as a string
df = df.select(col("value").cast("string"))

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

# Expand the JSON string into separate columns
df = df.select(from_json(col("value"), schema).alias("data")).select("data.*")

# Write the DataFrame to a CSV file
query = df.writeStream.outputMode("append").format("csv").option("path", "output").option("checkpointLocation", "checkpoint").start()

# Wait for the streaming query to end
query.awaitTermination()

# Stop the SparkSession
spark.stop()
