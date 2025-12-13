#!/usr/bin/env bash
set -euo pipefail
# Usage: ./run_bench.sh <csv-file> <output-csv>
CSV="$1"
OUT="$2"

DB=salarydb
USER=projuser
PASS=projpass
HOST=127.0.0.1
PORT=3306

QUERIES=(
"SELECT DISTINCT PersonName, BirthDate FROM salary_raw;"
"SELECT PersonName, SchoolName, SchoolCampus FROM salary_raw WHERE StillWorking = TRUE;"
"SELECT PersonName FROM salary_raw WHERE JobTitle = 'Assistant Professor' AND SchoolName = 'UMass Dartmouth';"
"SELECT SchoolCampus, COUNT(DISTINCT PersonID) FROM salary_raw WHERE EarningsYear = (SELECT MAX(EarningsYear) FROM salary_raw) GROUP BY SchoolCampus;"
"SELECT PersonID, SUM(Earnings) AS TotalEarnings FROM salary_raw GROUP BY PersonID;"
)

mkdir -p results_graphs

if [ ! -f "$OUT" ]; then
  echo "dataset,query_id,time_seconds" > "$OUT"
fi

ABS_CSV="$(realpath "$CSV")"

echo "Loading $ABS_CSV into salary_raw..."
mysql --protocol=TCP -h${HOST} -P${PORT} --local-infile=1 -u${USER} -p${PASS} ${DB} -e "TRUNCATE TABLE salary_raw;"
mysql --protocol=TCP -h${HOST} -P${PORT} --local-infile=1 -u${USER} -p${PASS} ${DB} -e "LOAD DATA LOCAL INFILE '${ABS_CSV}' INTO TABLE salary_raw FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"

dataset_name="$(basename "$CSV")"

for i in "${!QUERIES[@]}"; do
  q="${QUERIES[$i]}"
  echo "Running query $((i+1))..."
  # run and capture wall-clock seconds using date for portability
  start=$(date +%s.%N)
  mysql --protocol=TCP -h${HOST} -P${PORT} -u${USER} -p${PASS} -D ${DB} -sN -e "$q" > /dev/null
  end=$(date +%s.%N)
  secs=$(awk "BEGIN {print ${end} - ${start}}")
  echo "${dataset_name},$((i+1)),${secs}" >> "$OUT"
done

echo "Results appended to $OUT"
