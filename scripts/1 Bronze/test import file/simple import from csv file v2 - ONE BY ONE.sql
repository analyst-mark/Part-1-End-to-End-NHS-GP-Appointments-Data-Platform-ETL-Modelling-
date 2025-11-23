------------------------------------------------------------
-- 1. Remove all existing rows from the Employees table
--    TRUNCATE is fast and resets identity values (if any).
--    It requires that no foreign keys reference this table.
------------------------------------------------------------
TRUNCATE TABLE Employees;


------------------------------------------------------------
-- 2. Recreate the Employees table structure
--    Note: varchar normally requires a length (e.g., varchar(100)).
--    Without a length, SQL Server defaults to varchar(1).
------------------------------------------------------------
CREATE TABLE Employees (
    name varchar(100),   -- stores employee names
    age int              -- stores employee ages
);


------------------------------------------------------------
-- 3. Bulk insert CSV data into the Employees table
--    This loads data from a file on disk.
--    Requirements:
--      • SQL Server must have access to that file path.
--      • SQL Server service account must have read permissions.
------------------------------------------------------------
BULK INSERT dbo.Employees
FROM 'C:\Users\mark\Desktop\Part-1-End-to-End-NHS-GP-Appointments-Data-Platform-ETL-Modelling-\scripts\1 Bronze\test import file\Book1.csv'
WITH (
    FIRSTROW = 2,             -- Skip header row in the CSV
    FIELDTERMINATOR = ',',    -- Columns are separated by commas
    ROWTERMINATOR = '\n',     -- Each row ends with a newline (default but included for clarity)
    TABLOCK                   -- Use a table lock for better performance
);


------------------------------------------------------------
-- 4. Retrieve all rows from the Employees table
--    Note: "~" at the end is a typo and should be removed.
------------------------------------------------------------
SELECT * 
FROM Employees;
