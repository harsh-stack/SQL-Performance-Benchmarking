-- Use workspace-relative paths. Run from project root and enable LOCAL INFILE in the mysql client.
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'salary_tracker_1MB.csv'
INTO TABLE salary_raw
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'salary_tracker_10MB.csv'
INTO TABLE salary_raw
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'salary_tracker_100MB.csv'
INTO TABLE salary_raw
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;