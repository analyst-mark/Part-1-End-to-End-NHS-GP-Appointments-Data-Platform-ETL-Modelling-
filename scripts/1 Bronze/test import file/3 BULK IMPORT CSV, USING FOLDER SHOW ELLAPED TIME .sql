/* ============================================================
   CONFIG: Folder containing your CSV files
   ============================================================ */
DECLARE @FolderPath NVARCHAR(500) = 
    N'C:\Users\mark\Desktop\Part-1-End-to-End-NHS-GP-Appointments-Data-Platform-ETL-Modelling-\datasets\2025\';


/* ============================================================
   1 — Clear target table
   ============================================================ */
TRUNCATE TABLE dbo.tests;


/* ============================================================
   2 — Prep file list + log table
   ============================================================ */
IF OBJECT_ID('tempdb..#Files') IS NOT NULL DROP TABLE #Files;
IF OBJECT_ID('tempdb..#ImportLog') IS NOT NULL DROP TABLE #ImportLog;

CREATE TABLE #Files (FileName NVARCHAR(255));

CREATE TABLE #ImportLog (
    FileName      NVARCHAR(255),
    RowsInserted  INT,
    Milliseconds  INT
);

DECLARE @Cmd NVARCHAR(1000) =
    N'dir /b "' + @FolderPath + N'*.csv"';

INSERT INTO #Files (FileName)
EXEC master..xp_cmdshell @Cmd;

DELETE FROM #Files
WHERE FileName IS NULL OR FileName NOT LIKE '%.csv';


/* ============================================================
   3 — Loop each file: import + count rows + measure time
   ============================================================ */
DECLARE 
    @FileName   NVARCHAR(255),
    @FullPath   NVARCHAR(1000),
    @SQL        NVARCHAR(MAX),
    @Before     INT,
    @After      INT,
    @Inserted   INT,
    @Start      DATETIME2(7),
    @End        DATETIME2(7),
    @Ms         INT,
    @OverallStart DATETIME2(7),
    @OverallEnd   DATETIME2(7),
    @TotalMs      INT;

DECLARE file_cursor CURSOR FAST_FORWARD FOR
    SELECT FileName FROM #Files;

-- Start overall timer
SET @OverallStart = SYSDATETIME();

OPEN file_cursor;
FETCH NEXT FROM file_cursor INTO @FileName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @FullPath = @FolderPath + @FileName;
    PRINT 'Importing: ' + @FullPath;

    -- Count before
    SELECT @Before = COUNT(*) FROM dbo.tests;

    -- Start timer for this file
    SET @Start = SYSDATETIME();

    -- Execute BULK INSERT
    SET @SQL = N'
        BULK INSERT dbo.tests
        FROM ' + QUOTENAME(@FullPath, '''') + N'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0A'',
            TABLOCK
        );';

    EXEC (@SQL);

    -- Stop timer for this file
    SET @End = SYSDATETIME();

    -- Milliseconds elapsed for this file
    SET @Ms = DATEDIFF(ms, @Start, @End);

    -- Rows inserted
    SELECT @After = COUNT(*) FROM dbo.tests;
    SET @Inserted = @After - @Before;

    -- Log results
    INSERT INTO #ImportLog (FileName, RowsInserted, Milliseconds)
    VALUES (@FileName, @Inserted, @Ms);

    PRINT '  → Rows inserted: ' + CAST(@Inserted AS VARCHAR(20));
    PRINT '  → Time (ms):     ' + CAST(@Ms AS VARCHAR(20));

    FETCH NEXT FROM file_cursor INTO @FileName;
END

CLOSE file_cursor;
DEALLOCATE file_cursor;

-- Stop overall timer
SET @OverallEnd = SYSDATETIME();
SET @TotalMs = DATEDIFF(ms, @OverallStart, @OverallEnd);

PRINT '==============================';
PRINT 'Total import time (ms): ' + CAST(@TotalMs AS VARCHAR(20));
PRINT '==============================';


/* ============================================================
   4 — Show results
   ============================================================ */

-- File-by-file results
SELECT FileName, RowsInserted, Milliseconds
FROM #ImportLog;

-- Final total row count
SELECT COUNT(*) AS TotalFinalRows
FROM dbo.tests;

-- Overall elapsed time
SELECT @TotalMs AS TotalMilliseconds;
