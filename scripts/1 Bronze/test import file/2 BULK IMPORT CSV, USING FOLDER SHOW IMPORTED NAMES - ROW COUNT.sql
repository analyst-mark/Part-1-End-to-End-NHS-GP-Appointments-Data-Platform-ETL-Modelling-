/* ============================================================
   0 — (Already done previously) Enable xp_cmdshell
   ============================================================ */


DECLARE @FolderPath NVARCHAR(500) = 
    N'C:\Users\mark\Desktop\Part-1-End-to-End-NHS-GP-Appointments-Data-Platform-ETL-Modelling-\datasets\2025\';


/* ============================================================
   1 — Clear target table
   ============================================================ */
TRUNCATE TABLE dbo.tests;


/* ============================================================
   2 — Get list of CSV files to process
   ============================================================ */
IF OBJECT_ID('tempdb..#Files') IS NOT NULL DROP TABLE #Files;
IF OBJECT_ID('tempdb..#ImportLog') IS NOT NULL DROP TABLE #ImportLog;

CREATE TABLE #Files (FileName NVARCHAR(255));

CREATE TABLE #ImportLog (
    FileName NVARCHAR(255),
    RowsInserted INT
);

DECLARE @Cmd NVARCHAR(1000) =
    N'dir /b "' + @FolderPath + N'*.csv"';

INSERT INTO #Files (FileName)
EXEC master..xp_cmdshell @Cmd;

DELETE FROM #Files
WHERE FileName IS NULL OR FileName NOT LIKE '%.csv';


/* ============================================================
   3 — Import each file WITH row count tracking
   ============================================================ */
DECLARE 
    @FileName  NVARCHAR(255),
    @FullPath  NVARCHAR(1000),
    @SQL       NVARCHAR(MAX),
    @Before    INT,
    @After     INT,
    @Inserted  INT;

DECLARE file_cursor CURSOR FAST_FORWARD FOR
    SELECT FileName FROM #Files;

OPEN file_cursor;
FETCH NEXT FROM file_cursor INTO @FileName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @FullPath = @FolderPath + @FileName;

    PRINT 'Importing: ' + @FullPath;

    -- Count rows before insert
    SELECT @Before = COUNT(*) FROM dbo.tests;

    -- Run BULK INSERT
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

    -- Count after
    SELECT @After = COUNT(*) FROM dbo.tests;

    -- Difference = rows inserted
    SET @Inserted = @After - @Before;

    INSERT INTO #ImportLog (FileName, RowsInserted)
    VALUES (@FileName, @Inserted);

    PRINT '  ? Rows inserted: ' + CAST(@Inserted AS VARCHAR(20));

    FETCH NEXT FROM file_cursor INTO @FileName;
END

CLOSE file_cursor;
DEALLOCATE file_cursor;


/* ============================================================
   4 — Show results
   ============================================================ */

-- File-by-file insert summary
SELECT FileName, RowsInserted
FROM #ImportLog;

-- Final total rows in table
SELECT COUNT(*) AS TotalFinalRows
FROM dbo.tests;
