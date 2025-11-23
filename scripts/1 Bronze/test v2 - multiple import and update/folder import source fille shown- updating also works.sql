USE NHS_DataWarehouse_v2;
GO

/* ============================================================
   0 — Staging table (kept in the DB, NOT a final table)
   ============================================================ */
IF OBJECT_ID('dbo.test_staging') IS NOT NULL
    DROP TABLE dbo.test_staging;

CREATE TABLE dbo.test_staging (
    name           VARCHAR(100),
    age            VARCHAR(10),
    SourceFileName NVARCHAR(255)
);


/* ============================================================
   1 — Folder path
   ============================================================ */
DECLARE @FolderPath NVARCHAR(500) = 
    N'C:\Users\mark\Desktop\Part-1-End-to-End-NHS-GP-Appointments-Data-Platform-ETL-Modelling-\scripts\1 Bronze\test v2 - multiple import and update\';
    -- NOTE: trailing backslash


/***************************************************************
   2 — Get list of CSV files in folder
****************************************************************/
IF OBJECT_ID('tempdb..#Files') IS NOT NULL DROP TABLE #Files;
CREATE TABLE #Files (FileName NVARCHAR(255));

DECLARE @Cmd NVARCHAR(1000) =
    N'dir /b "' + @FolderPath + N'*.csv"';

PRINT @Cmd;  -- Debug: see the exact command

INSERT INTO #Files (FileName)
EXEC master..xp_cmdshell @Cmd;

DELETE FROM #Files
WHERE FileName IS NULL OR FileName NOT LIKE '%.csv';

-- All files in folder
SELECT * FROM #Files AS AllFiles;


/***************************************************************
   2b — Get list of files we've ALREADY loaded into dbo.test
        (by SourceFilename) and work out which files are NEW
****************************************************************/
IF OBJECT_ID('tempdb..#AlreadyLoaded') IS NOT NULL DROP TABLE #AlreadyLoaded;
CREATE TABLE #AlreadyLoaded (SourceFilename NVARCHAR(255));

IF OBJECT_ID('dbo.test') IS NOT NULL
BEGIN
    INSERT INTO #AlreadyLoaded (SourceFilename)
    SELECT DISTINCT SourceFilename
    FROM dbo.test
    WHERE SourceFilename IS NOT NULL;
END

-- Files in folder that are NOT yet in dbo.test
IF OBJECT_ID('tempdb..#FilesToImport') IS NOT NULL DROP TABLE #FilesToImport;
SELECT f.FileName
INTO #FilesToImport
FROM #Files f
LEFT JOIN #AlreadyLoaded a
    ON a.SourceFilename = f.FileName
WHERE a.SourceFilename IS NULL;

-- Debug: see which files will be imported this run
SELECT * FROM #FilesToImport AS FilesToImport;


/* ============================================================
   3 — Temp table used for raw BULK INSERT
   ============================================================ */
IF OBJECT_ID('tempdb..#Raw') IS NOT NULL DROP TABLE #Raw;

CREATE TABLE #Raw (
    name VARCHAR(100),
    age  VARCHAR(10)
);


/* ============================================================
   4 — Loop: bulk each *NEW* file into #Raw, then into staging
   ============================================================ */
DECLARE 
    @FileName  NVARCHAR(255),
    @FullPath  NVARCHAR(1000),
    @SQL       NVARCHAR(MAX);

DECLARE file_cursor CURSOR FAST_FORWARD FOR
    SELECT FileName FROM #FilesToImport;   -- <-- only NEW files

OPEN file_cursor;
FETCH NEXT FROM file_cursor INTO @FileName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Build full path
    SET @FullPath = @FolderPath + @FileName;

    PRINT 'Importing NEW file: ' + @FullPath;

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
   6 — Append new rows into final table: dbo.test
       (no TRUNCATE – we are doing incremental loads)
   ============================================================ */

INSERT INTO dbo.test (name, age, SourceFilename)   -- adjust name if needed
SELECT name,
       age,
       SourceFileName
FROM dbo.test_staging;

-- Check final table
SELECT *
FROM dbo.test;

