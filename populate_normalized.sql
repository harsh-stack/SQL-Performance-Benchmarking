-- Populate normalized tables from salary_raw
-- Assumes tables from `normalized_schema.sql` already exist

INSERT IGNORE INTO Person (PersonID, PersonName, BirthDate)
SELECT DISTINCT PersonID, PersonName, BirthDate
FROM salary_raw;

INSERT IGNORE INTO School (SchoolID, SchoolName, SchoolCampus)
SELECT DISTINCT SchoolID, SchoolName, SchoolCampus
FROM salary_raw;

INSERT IGNORE INTO Department (DepartmentID, DepartmentName)
SELECT DISTINCT DepartmentID, DepartmentName
FROM salary_raw;

INSERT IGNORE INTO Job (JobID, JobTitle, StillWorking)
SELECT DISTINCT JobID, JobTitle, StillWorking
FROM salary_raw;

-- Earnings: preserve one row per person-year
INSERT INTO Earnings (PersonID, EarningsYear, Earnings)
SELECT PersonID, EarningsYear, Earnings
FROM salary_raw;

-- Note: consider adding indexes and deduplication logic for production runs.

-- Employment mapping: one row per person-year with school and job
TRUNCATE TABLE Employment;
INSERT INTO Employment (PersonID, SchoolID, JobID, StillWorking, EarningsYear, Earnings)
SELECT PersonID, SchoolID, JobID, StillWorking, EarningsYear, Earnings
FROM salary_raw;
