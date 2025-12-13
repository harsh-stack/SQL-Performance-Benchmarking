#!/usr/bin/env bash
set -euo pipefail
# Usage: ./run_bench_normalized.sh <csv-file> <output-csv>
CSV="$1"
OUT="$2"

DB=salarydb
USER=projuser
PASS=projpass
HOST=127.0.0.1
PORT=3306

QUERIES=(
"SELECT DISTINCT p.PersonName, p.BirthDate FROM Person p;"
"SELECT p.PersonName, s.SchoolName, s.SchoolCampus FROM Person p JOIN Employment e ON p.PersonID=e.PersonID JOIN School s ON e.SchoolID=s.SchoolID WHERE e.StillWorking = TRUE;"
"SELECT p.PersonName FROM Person p JOIN Employment e ON p.PersonID=e.PersonID JOIN Job j ON e.JobID=j.JobID JOIN School s ON e.SchoolID=s.SchoolID WHERE j.JobTitle = 'Assistant Professor' AND s.SchoolName = 'UMass Dartmouth';"
"SELECT s.SchoolCampus, COUNT(DISTINCT e.PersonID) FROM Employment e JOIN School s ON e.SchoolID=s.SchoolID WHERE e.EarningsYear = (SELECT MAX(EarningsYear) FROM Earnings) GROUP BY s.SchoolCampus;"
"SELECT e.PersonID, SUM(e.Earnings) AS TotalEarnings FROM Employment e GROUP BY e.PersonID;"
)

mkdir -p results_graphs

if [ ! -f "$OUT" ]; then
  echo "dataset,query_id,time_seconds" > "$OUT"
fi

ABS_CSV="$(realpath "$CSV")"

echo "Loading $ABS_CSV into salary_raw..."
mysql --protocol=TCP -h${HOST} -P${PORT} --local-infile=1 -u${USER} -p${PASS} ${DB} -e "TRUNCATE TABLE salary_raw;"
mysql --protocol=TCP -h${HOST} -P${PORT} --local-infile=1 -u${USER} -p${PASS} ${DB} -e "LOAD DATA LOCAL INFILE '${ABS_CSV}' INTO TABLE salary_raw FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"

echo "Populating normalized tables from salary_raw..."
mysql --protocol=TCP -h${HOST} -P${PORT} -u${USER} -p${PASS} ${DB} < populate_normalized.sql

dataset_name="$(basename "$CSV")"

for i in "${!QUERIES[@]}"; do
  q="${QUERIES[$i]}"
  echo "Running normalized query $((i+1))..."
  start=$(date +%s.%N)
  mysql --protocol=TCP -h${HOST} -P${PORT} -u${USER} -p${PASS} -D ${DB} -sN -e "$q" > /dev/null
  end=$(date +%s.%N)
  secs=$(awk "BEGIN {print ${end} - ${start}}")
  echo "${dataset_name},$((i+1)),${secs}" >> "$OUT"
done

echo "Normalized results appended to $OUT"
