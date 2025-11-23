USE NHS_DataWarehouse_v2;
GO

/* ============================================================
   0 — Staging table (kept in the DB, NOT a final table)
   ============================================================ */
IF OBJECT_ID('dbo.test_staging') IS NOT NULL
    DROP TABLE dbo.test_staging;

CREATE TABLE dbo.test_staging (
    name           varchar(100),
    age            varchar(10),
    SourceFileName nvarchar(255)
);


/* ============================================================
   1 — Folder path
   ============================================================ */
DECLARE @FolderPath NVARCHAR(500) = 
    N'C:\Users\mark\Desktop\Part-1-End-to-End-NHS-GP-Appointments-Data-Platform-ETL-Modelling-\scripts\1 Bronze\test v2 - multiple import and update\';
    -- NOTE: trailing backslash ?


/* ============================================================
   2 — Get list of CSV files
   ============================================================ */
IF OBJECT_ID('tempdb..#Files') IS NOT NULL DROP TABLE #Files;
CREATE TABLE #Files (FileName NVARCHAR(255));

DECLARE @Cmd NVARCHAR(1000) =
    N'dir /b "' + @FolderPath + N'*.csv"';

PRINT @Cmd;  -- Debug: see the exact command

INSERT INTO #Files (FileName)
EXEC master..xp_cmdshell @Cmd;

DELETE FROM #Files
WHERE FileName IS NULL OR FileName NOT LIKE '%.csv';

-- Optional: confirm we actually got filenames
SELECT * FROM #Files;   -- e.g. Book1.csv, Book2.csv


/* ============================================================
   3 — Temp table used for raw BULK INSERT
   ============================================================ */
IF OBJECT_ID('tempdb..#Raw') IS NOT NULL DROP TABLE #Raw;

CREATE TABLE #Raw (
    name varchar(100),
    age  varchar(10)
);


/* ============================================================
   4 — Loop: bulk each file into #Raw, then into staging with filename
   ============================================================ */
DECLARE 
    @FileName  NVARCHAR(255),
    @FullPath  NVARCHAR(1000),
    @SQL       NVARCHAR(MAX);

DECLARE file_cursor CURSOR FAST_FORWARD FOR
    SELECT FileName FROM #Files;

OPEN file_cursor;
FETCH NEXT FROM file_cursor INTO @FileName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Build full path
    SET @FullPath = @FolderPath + @FileName;

    PRINT 'Importing: ' + @FullPath;

    -- Clear raw table for this file
    TRUNCATE TABLE #Raw;

    -- 1) BULK INSERT into #Raw
    SET @SQL = N'
        BULK INSERT #Raw
        FROM ''' + @FullPath + N'''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0A'',
            TABLOCK
        );';

    PRINT @SQL;      -- Debug
    EXEC (@SQL);

    -- 2) Move from #Raw into staging, tagging each row with its source file
    INSERT INTO dbo.test_staging (name, age, SourceFileName)
    SELECT r.name, r.age, ca.SourceFileName
    FROM #Raw r
    CROSS APPLY (SELECT @FileName AS SourceFileName) ca;

    FETCH NEXT FROM file_cursor INTO @FileName;
END

CLOSE file_cursor;
DEALLOCATE file_cursor;


/* ============================================================
   5 — Show staging results (ONLY)
   ============================================================ */
SELECT *
FROM dbo.test_staging;


/* ============================================================
   6 — Load into final table: dbo.test
   ============================================================ */


-- Optional: if you want to replace the data each run, uncomment:
-- TRUNCATE TABLE dbo.test;

-- Insert from staging into final table
INSERT INTO dbo.test (name, age, SourceFilename)
SELECT name,
       age,
       SourceFilename
FROM dbo.test_staging;

-- Check final table
SELECT *
FROM dbo.test;

-- select count(*) from test
 -- truncate table test