/* ============================================================
   STEP 1 — Create the table that matches the CSV structure
   ============================================================ */
truncate table tests;

CREATE TABLE dbo.tests (
    SUB_ICB_LOCATION_CODE        VARCHAR(20),     -- e.g. '92A'
    SUB_ICB_LOCATION_ONS_CODE    VARCHAR(20),    
    SUB_ICB_LOCATION_NAME        VARCHAR(255),    -- text name
    ICB_ONS_CODE                 VARCHAR(20),
    REGION_ONS_CODE              VARCHAR(20),

    -- CSV stores values like '01APR2025'; keep VARCHAR unless converting later
    Appointment_Date             VARCHAR(20),

    APPT_STATUS                  VARCHAR(50),
    HCP_TYPE                     VARCHAR(100),
    APPT_MODE                    VARCHAR(50),
    TIME_BETWEEN_BOOK_AND_APPT  VARCHAR(50),
    COUNT_OF_APPOINTMENTS       INT              -- must be numeric in CSV
);

-- Check table structure
SELECT TOP 5 * FROM dbo.tests;



/* ============================================================
   STEP 2 — BULK INSERT the CSV file
   ============================================================ */
/*
    IMPORTANT NOTES:
    - SQL Server reads the file ON THE SERVER, not on your PC (unless local instance).
    - The account running SQL Server must have Read permissions on the filepath.
    - FIRSTROW = 2 skips the header row.
    - FIELDTERMINATOR = ',' for CSV.
    - ROWTERMINATOR = '0x0A' works for most LF line endings.
    - If your CSV uses CRLF, switch to ROWTERMINATOR = '\r\n'.
*/

BULK INSERT dbo.tests
FROM 'C:\Users\mark\Desktop\Part-1-End-to-End-NHS-GP-Appointments-Data-Platform-ETL-Modelling-\scripts\1 Bronze\test import file\Apr_25.csv'
WITH (
    FIRSTROW = 2,              -- skip column header
    FIELDTERMINATOR = ',',     -- comma-separated
    ROWTERMINATOR = '0x0A',    -- LF newline
    TABLOCK                    -- improves performance
);


-- Verify import
SELECT TOP 50 * FROM dbo.tests;