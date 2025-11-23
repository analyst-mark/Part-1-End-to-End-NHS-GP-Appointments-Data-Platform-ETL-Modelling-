USE NHS_DataWarehouse_v2;
GO

IF OBJECT_ID('dbo.usp_ImportNewTestCsvs', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_ImportNewTestCsvs;
GO

CREATE PROCEDURE dbo.usp_ImportNewTestCsvs
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------
    -- 1 — Fixed folder path (no parameter)
    ------------------------------------------------------------
    DECLARE @FolderPath NVARCHAR(500) = 
        N'C:\Users\mark\Desktop\Part-1-End-to-End-NHS-GP-Appointments-Data-Platform-ETL-Modelling-\scripts\1 Bronze\test v2 - multiple import and update\';

    IF RIGHT(@FolderPath,1) NOT IN ('\', '/')
        SET @FolderPath = @FolderPath + N'\';


    /* ============================================================
       0 — Staging table
       ============================================================ */
    IF OBJECT_ID('dbo.test_staging') IS NOT NULL
        DROP TABLE dbo.test_staging;

    CREATE TABLE dbo.test_staging (
        name           VARCHAR(100),
        age            VARCHAR(10),
        SourceFileName NVARCHAR(255)
    );


    /* ============================================================
       2 — Read CSV filenames from folder
       ============================================================ */
    IF OBJECT_ID('tempdb..#Files') IS NOT NULL DROP TABLE #Files;
    CREATE TABLE #Files (FileName NVARCHAR(255));

    DECLARE @Cmd NVARCHAR(1000) =
        N'dir /b "' + @FolderPath + N'*.csv"';

    INSERT INTO #Files (FileName)
    EXEC master..xp_cmdshell @Cmd;

    DELETE FROM #Files
    WHERE FileName IS NULL OR FileName NOT LIKE '%.csv';


    /* ============================================================
       2b — Get already-imported filenames
       ============================================================ */
    IF OBJECT_ID('tempdb..#AlreadyLoaded') IS NOT NULL DROP TABLE #AlreadyLoaded;
    CREATE TABLE #AlreadyLoaded (SourceFilename NVARCHAR(255));

    INSERT INTO #AlreadyLoaded (SourceFilename)
    SELECT DISTINCT SourceFilename
    FROM dbo.test
    WHERE SourceFilename IS NOT NULL;


    /* ============================================================
       2c — Determine NEW files to import
       ============================================================ */
    IF OBJECT_ID('tempdb..#FilesToImport') IS NOT NULL DROP TABLE #FilesToImport;

    SELECT f.FileName
    INTO #FilesToImport
    FROM #Files f
    LEFT JOIN #AlreadyLoaded a
        ON a.SourceFilename = f.FileName
    WHERE a.SourceFilename IS NULL;


    /* ============================================================
       3 — Temp table for raw file load
       ============================================================ */
    IF OBJECT_ID('tempdb..#Raw') IS NOT NULL DROP TABLE #Raw;

    CREATE TABLE #Raw (
        name VARCHAR(100),
        age  VARCHAR(10)
    );


    /* ============================================================
       4 — Loop + BULK INSERT each NEW file
       ============================================================ */
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

        EXEC (@SQL);

        INSERT INTO dbo.test_staging (name, age, SourceFileName)
        SELECT r.name, r.age, @FileName
        FROM #Raw AS r;

        FETCH NEXT FROM file_cursor INTO @FileName;
    END

    CLOSE file_cursor;
    DEALLOCATE file_cursor;


    /* ============================================================
       5 — Insert new rows into final table
       ============================================================ */
    INSERT INTO dbo.test (name, age, SourceFilename)
    SELECT name,
           age,
           SourceFileName
    FROM dbo.test_staging;

END
GO


EXEC dbo.usp_ImportNewTestCsvs;


select * from test