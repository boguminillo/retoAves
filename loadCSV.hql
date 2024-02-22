CREATE TABLE birds (
  sciName STRING,
  howMany INT,
  locName STRING,
  lat DOUBLE,
  lng DOUBLE,
  tmed DOUBLE,
  prec DOUBLE,
  velmedia DOUBLE,
  year INT,
  month INT,
  day INT,
  exoticCategoryN BOOLEAN,
  exoticCategoryP BOOLEAN,
  exoticCategoryX BOOLEAN
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
   "separatorChar" = ",",
   "quoteChar"     = "\""
)  
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="1");

LOAD DATA INPATH '/tmp/birdData.csv' INTO TABLE birds;