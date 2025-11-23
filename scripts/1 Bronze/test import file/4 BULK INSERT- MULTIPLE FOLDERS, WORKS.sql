/* ============================================================
   OPTIONAL: Enable xp_cmdshell once (run separately if needed)
   ============================================================ 
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO
*/


/* ============================================================
   CONFIG: Base folder that contains 2020, 2021, ... 2025
   ============================================================ */
DECLARE @BasePath NVARCHAR(500) =
N'C:\Users\mark\Desktop\Part-1-End-to-End-NHS-GP-Appointments-Data-Platform-ETL-Modelling-\datasets\';


/* ============================================================
   1 — Clear target table
   ============================================================ */
TRUNCATE TABLE dbo.tests;


/* ============================================================
   2 — Prep temp tables for years, files, and logging
   ============================================================ */
IF OBJECT_ID('tempdb..#YearFolders') IS NOT NULL DROP TABLE #YearFolders;
IF OBJECT_ID('tempdb..#Files')       IS NOT NULL DROP TABLE #Files;
IF OBJECT_ID('tempdb..#ImportLog')   IS NOT NULL DROP TABLE #ImportLog;

CREATE TABLE #YearFolders (FolderName NVARCHAR(255));
CREATE TABLE #Files       (FileName  NVARCHAR(255));
CREATE TABLE #ImportLog (
    YearFolder    NVARCHAR(50),
    FileName      NVARCHAR(255),
    RowsInserted  INT,
    Milliseconds  INT
);


/* ============================================================
   3 — Get list of subfolders under @BasePath, keep 2020–2025
   ============================================================ */
DECLARE @Cmd NVARCHAR(1000);

SET @Cmd = 'dir /b /ad "' + @BasePath + '"';

INSERT INTO #YearFolders (FolderName)
EXEC master..xp_cmdshell @Cmd;

-- Clean nulls and keep only explicit year folders
DELETE FROM #YearFolders
WHERE FolderName IS NULL;

DELETE FROM #YearFolders
WHERE FolderName NOT IN ('2020','2021','2022','2023','2024','2025');


/* ============================================================
   4 — Loop year folders, then CSV files within each year
   ============================================================ */
DECLARE 
    @YearFolder     NVARCHAR(255),
    @FullYearPath   NVARCHAR(500),
    @File           NVARCHAR(255),
    @FullFilePath   NVARCHAR(1000),
    @SQL            NVARCHAR(MAX),
    @Before         INT,
    @After          INT,
    @Inserted       INT,
    @Start          DATETIME2(7),
    @End            DATETIME2(7),
    @Ms             INT,
    @OverallStart   DATETIME2(7),
    @OverallEnd     DATETIME2(7),
    @TotalMs        INT;

SET @OverallStart = SYSDATETIME();

DECLARE year_cursor CURSOR FOR
    SELECT FolderName FROM #YearFolders;

OPEN year_cursor;
FETCH NEXT FROM year_cursor INTO @YearFolder;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @FullYearPath = @BasePath + @YearFolder + '\';

    PRINT '=============================';
    PRINT 'Processing YEAR folder: ' + @YearFolder;
    PRINT 'Path: ' + @FullYearPath;
    PRINT '=============================';

    -- Reset file list for this year
    TRUNCATE TABLE #Files;

    SET @Cmd = 'dir /b "' + @FullYearPath + '*.csv"';

    INSERT INTO #Files (FileName)
    EXEC master..xp_cmdshell @Cmd;

    DELETE FROM #Files
    WHERE FileName IS NULL
       OR FileName NOT LIKE '%.csv';

    -- If no CSVs, skip this year
    IF NOT EXISTS (SELECT 1 FROM #Files)
    BEGIN
        PRINT '  (No CSV files found in ' + @FullYearPath + ')';
        GOTO NextYear;
    END

    -- Cursor over files in this year
    DECLARE file_cursor CURSOR FOR
        SELECT FileName FROM #Files;

    OPEN file_cursor;
    FETCH NEXT FROM file_cursor INTO @File;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @FullFilePath = @FullYearPath + @File;

        PRINT 'Importing: ' + @FullFilePath;

        -- Rows before
        SELECT @Before = COUNT(*) FROM dbo.tests;

        -- Timer start
        SET @Start = SYSDATETIME();

        -- BULK INSERT
        SET @SQL = '
        BULK INSERT dbo.tests
        FROM ''' + @FullFilePath + '''
        WITH (
            FIRSTROW = 2,              -- skip header row
            FIELDTERMINATOR = '','',   -- CSV
            ROWTERMINATOR  = ''0x0A'', -- use ''\r\n'' if needed
            TABLOCK
        );';

        EXEC(@SQL);

        -- Timer end
        SET @End = SYSDATETIME();
        SET @Ms = DATEDIFF(ms, @Start, @End);

        -- Rows after
        SELECT @After = COUNT(*) FROM dbo.tests;
        SET @Inserted = @After - @Before;

        -- Log
        INSERT INTO #ImportLog (YearFolder, FileName, RowsInserted, Milliseconds)
        VALUES (@YearFolder, @File, @Inserted, @Ms);

        PRINT '  ? Rows inserted: ' + CAST(@Inserted AS VARCHAR(20));
        PRINT '  ? Time (ms):     ' + CAST(@Ms AS VARCHAR(20));

        FETCH NEXT FROM file_cursor INTO @File;
    END

    CLOSE file_cursor;
    DEALLOCATE file_cursor;

NextYear:
    FETCH NEXT FROM year_cursor INTO @YearFolder;
END

CLOSE year_cursor;
DEALLOCATE year_cursor;

SET @OverallEnd = SYSDATETIME();
SET @TotalMs = DATEDIFF(ms, @OverallStart, @OverallEnd);

PRINT '==============================';
PRINT 'TOTAL IMPORT TIME (ms): ' + CAST(@TotalMs AS VARCHAR(20));
PRINT '==============================';


/* ============================================================
   5 — Final output
   ============================================================ */

-- File-by-file results
SELECT YearFolder, FileName, RowsInserted, Milliseconds
FROM #ImportLog
ORDER BY YearFolder, FileName;

-- Total rows in table
SELECT COUNT(*) AS TotalRows
FROM dbo.tests;

-- Overall elapsed time
SELECT @TotalMs / 1000.0 AS TotalSeconds;

