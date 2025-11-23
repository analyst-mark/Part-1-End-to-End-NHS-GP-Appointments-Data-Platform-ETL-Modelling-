USE NHS_DataWarehouse_v2;
GO

IF OBJECT_ID('dbo.usp_ImportNewTestCsvs', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_ImportNewTestCsvs;
GO

CREATE PROCEDURE dbo.usp_ImportNewTestCsvs
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Step 1: Set folder path';

    DECLARE @FolderPath NVARCHAR(500) = 
        N'C:\Users\mark\Desktop\Part-1-End-to-End-NHS-GP-Appointments-Data-Platform-ETL-Modelling-\scripts\1 Bronze\test v2 - multiple import and update\';

    IF RIGHT(@FolderPath, 1) NOT IN ('\', '/')
        SET @FolderPath = @FolderPath + N'\';


    /* ============================================================
       A — What is already in dbo.test?
       ============================================================ */
    PRINT 'Step 1a: Existing source files already in dbo.test';

    IF OBJECT_ID('dbo.test') IS NOT NULL
    BEGIN
        -- Per-file row counts
        SELECT 
            SourceFilename,
            COUNT(*) AS RowsPerFile
        FROM dbo.test
        GROUP BY SourceFilename;

        -- Column count for dbo.test
        SELECT 
            COUNT(*) AS TestTableColumnCount
        FROM sys.columns
        WHERE object_id = OBJECT_ID('dbo.test');
    END
    ELSE
    BEGIN
        PRINT 'Table dbo.test does not exist yet.';
    END


    /* ============================================================
       0 — Staging table
       ============================================================ */
    PRINT 'Step 2: Recreate staging table dbo.test_staging';

    IF OBJECT_ID('dbo.test_staging') IS NOT NULL
        DROP TABLE dbo.test_staging;

    CREATE TABLE dbo.test_staging (
        name           VARCHAR(100),
        age            VARCHAR(10),
        SourceFileName NVARCHAR(255)
    );

    -- Column count for staging table
    SELECT 
        COUNT(*) AS TestStagingColumnCount
    FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.test_staging');


    /* ============================================================
       2 — Read CSV filenames from folder
       ============================================================ */
    PRINT 'Step 3: Read CSV filenames from folder';

    IF OBJECT_ID('tempdb..#Files') IS NOT NULL DROP TABLE #Files;
    CREATE TABLE #Files (FileName NVARCHAR(255));

    DECLARE @Cmd NVARCHAR(1000) =
        N'dir /b "' + @FolderPath + N'*.csv"';

    PRINT 'xp_cmdshell command: ' + @Cmd;

    INSERT INTO #Files (FileName)
    EXEC master..xp_cmdshell @Cmd;

    DELETE FROM #Files
    WHERE FileName IS NULL OR FileName NOT LIKE '%.csv';

    PRINT 'All CSV files found in folder:';
    SELECT * FROM #Files AS AllFiles;


    /* ============================================================
       2b — Already-imported filenames
       ============================================================ */
    PRINT 'Step 4: Get already-imported filenames from dbo.test';

    IF OBJECT_ID('tempdb..#AlreadyLoaded') IS NOT NULL DROP TABLE #AlreadyLoaded;
    CREATE TABLE #AlreadyLoaded (SourceFilename NVARCHAR(255));

    IF OBJECT_ID('dbo.test') IS NOT NULL
    BEGIN
        INSERT INTO #AlreadyLoaded (SourceFilename)
        SELECT DISTINCT SourceFilename
        FROM dbo.test
        WHERE SourceFilename IS NOT NULL;
    END

    PRINT 'Files already in dbo.test:';
    SELECT * FROM #AlreadyLoaded;


    /* ============================================================
       2c — Determine NEW files to import
       ============================================================ */
    PRINT 'Step 5: Work out which files are NEW (not yet in dbo.test)';

    IF OBJECT_ID('tempdb..#FilesToImport') IS NOT NULL DROP TABLE #FilesToImport;

    SELECT f.FileName
    INTO #FilesToImport
    FROM #Files f
    LEFT JOIN #AlreadyLoaded a
        ON a.SourceFilename = f.FileName
    WHERE a.SourceFilename IS NULL;

    PRINT 'Files that will be imported this run:';
    SELECT * FROM #FilesToImport;


    /* ============================================================
       3 — Temp table for raw file load
       ============================================================ */
    PRINT 'Step 6: Create #Raw temp table';

    IF OBJECT_ID('tempdb..#Raw') IS NOT NULL DROP TABLE #Raw;

    CREATE TABLE #Raw (
        name VARCHAR(100),
        age  VARCHAR(10)
    );


    /* ============================================================
       4 — Loop + BULK INSERT each NEW file
       ============================================================ */
    PRINT 'Step 7: Loop over NEW files and BULK INSERT into staging';

    DECLARE 
        @FileName  NVARCHAR(255),
        @FullPath  NVARCHAR(1000),
        @SQL       NVARCHAR(MAX);

    DECLARE file_cursor CURSOR FAST_FORWARD FOR
        SELECT FileName FROM #FilesToImport;

    OPEN file_cursor;
    FETCH NEXT FROM file_cursor INTO @FileName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @FullPath = @FolderPath + @FileName;

        PRINT '  Importing NEW file: ' + @FullPath;

        TRUNCATE TABLE #Raw;

        SET @SQL = N'
            BULK INSERT #Raw
            FROM ''' + @FullPath + N'''
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = '','',
                ROWTERMINATOR = ''0x0A'',
                TABLOCK
            );';

        PRINT '  BULK INSERT command:';
        PRINT @SQL;

        EXEC (@SQL);

        INSERT INTO dbo.test_staging (name, age, SourceFileName)
        SELECT r.name, r.age, @FileName
        FROM #Raw AS r;

        FETCH NEXT FROM file_cursor INTO @FileName;
    END

    CLOSE file_cursor;
    DEALLOCATE file_cursor;


    /* ============================================================
       5 — Show what data WILL be uploaded
       ============================================================ */
    PRINT 'Step 8: Data in dbo.test_staging (this is what will be uploaded to dbo.test)';

    SELECT *
    FROM dbo.test_staging;

    SELECT 
        COUNT(*) AS RowsToUpload,
        COUNT(DISTINCT SourceFileName) AS DistinctFilesInThisRun
    FROM dbo.test_staging;


    /* ============================================================
       6 — Insert into final table
       ============================================================ */
    PRINT 'Step 9: Insert new rows into dbo.test';

    INSERT INTO dbo.test (name, age, SourceFilename)
    SELECT name,
           age,
           SourceFileName
    FROM dbo.test_staging;

    PRINT 'Step 10: Final row count in dbo.test';

    SELECT 
        COUNT(*) AS TotalRowsInTest,
        COUNT(DISTINCT SourceFilename) AS TotalDistinctSourceFiles
    FROM dbo.test;

END
GO


exec  dbo.usp_ImportNewTestCsvs