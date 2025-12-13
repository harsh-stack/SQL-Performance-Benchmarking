CREATE TABLE Person (
    PersonID INT PRIMARY KEY,
    PersonName VARCHAR(100),
    BirthDate DATE
);

CREATE TABLE School (
    SchoolID INT PRIMARY KEY,
    SchoolName VARCHAR(100),
    SchoolCampus VARCHAR(100)
);

CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100)
);

CREATE TABLE Job (
    JobID INT PRIMARY KEY,
    JobTitle VARCHAR(100),
    StillWorking BOOLEAN
);

CREATE TABLE Earnings (
    PersonID INT,
    EarningsYear INT,
    Earnings DECIMAL(12,2),
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID)
);

CREATE TABLE Employment (
    PersonID INT,
    SchoolID INT,
    JobID INT,
    StillWorking BOOLEAN,
    EarningsYear INT,
    Earnings DECIMAL(12,2),
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID),
    FOREIGN KEY (SchoolID) REFERENCES School(SchoolID),
    FOREIGN KEY (JobID) REFERENCES Job(JobID)
);