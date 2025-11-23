/* ============================================================
   (Run once) Enable xp_cmdshell if not already enabled
   ============================================================ */
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO


/* ============================================================
   CONFIG: Folder containing your 6 CSV files
   ============================================================ */
DECLARE @FolderPath NVARCHAR(500) = 
    N'C:\Users\mark\Desktop\Part-1-End-to-End-NHS-GP-Appointments-Data-Platform-ETL-Modelling-\datasets\2025\';


/* ============================================================
   1 — Clear target table (assumes dbo.tests already created)
   ============================================================ */
TRUNCATE TABLE dbo.tests;


/* ============================================================
   2 — Get list of CSV files in the folder
   ============================================================ */
IF OBJECT_ID('tempdb..#Files') IS NOT NULL
    DROP TABLE #Files;

CREATE TABLE #Files (
    FileName NVARCHAR(255)
);

DECLARE @Cmd NVARCHAR(1000) =
    N'dir /b "' + @FolderPath + N'*.csv"';

INSERT INTO #Files (FileName)
EXEC master..xp_cmdshell @Cmd;

-- Clean nulls / junk
DELETE FROM #Files
WHERE FileName IS NULL
   OR FileName NOT LIKE '%.csv';


/* ============================================================
   3 — Loop over each file and BULK INSERT into dbo.tests
   ============================================================ */
DECLARE 
    @FileName  NVARCHAR(255),
    @FullPath  NVARCHAR(1000),
    @SQL       NVARCHAR(MAX);

DECLARE file_cursor CURSOR FAST_FORWARD FOR
    SELECT FileName
    FROM #Files;

OPEN file_cursor;
FETCH NEXT FROM file_cursor INTO @FileName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @FullPath = @FolderPath + @FileName;

    PRINT 'Importing: ' + @FullPath;

    SET @SQL = N'
        BULK INSERT dbo.tests
        FROM ' + QUOTENAME(@FullPath, '''') + N'
        WITH (
            FIRSTROW = 2,              -- skip header
            FIELDTERMINATOR = '','',   -- CSV
            ROWTERMINATOR = ''0x0A'',  -- LF; use ''\r\n'' if needed
            TABLOCK
        );';

    EXEC (@SQL);

    FETCH NEXT FROM file_cursor INTO @FileName;
END

CLOSE file_cursor;
DEALLOCATE file_cursor;


/* ============================================================
   4 — Quick tests / sanity checks
   ============================================================ */
SELECT COUNT(*)
FROM dbo.tests;



