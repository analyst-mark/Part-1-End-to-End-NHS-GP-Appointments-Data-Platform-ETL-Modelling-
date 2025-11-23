USE NHS_DataWarehouse_v2;
GO

/* 0 — Drop and recreate table cleanly */
IF OBJECT_ID('dbo.test') IS NOT NULL
    DROP TABLE dbo.test;

CREATE TABLE dbo.test(
    name varchar(100),
    age  varchar(10)
);


/* 1 — Folder path (with trailing backslash) */
DECLARE @FolderPath NVARCHAR(500) = 
    N'C:\Users\mark\Desktop\Part-1-End-to-End-NHS-GP-Appointments-Data-Platform-ETL-Modelling-\scripts\1 Bronze\test v2 - multiple import and update\';


/* 2 — Load file list */
IF OBJECT_ID('tempdb..#Files') IS NOT NULL DROP TABLE #Files;
IF OBJECT_ID('tempdb..#ImportLog') IS NOT NULL DROP TABLE #ImportLog;

CREATE TABLE #Files (FileName NVARCHAR(255));
CREATE TABLE #ImportLog (FileName NVARCHAR(255), RowsInserted INT);

DECLARE @Cmd NVARCHAR(1000) =
    N'dir /b "' + @FolderPath + N'*.csv"';

PRINT @Cmd;

INSERT INTO #Files (FileName)
EXEC master..xp_cmdshell @Cmd;

DELETE FROM #Files
WHERE FileName IS NULL OR FileName NOT LIKE '%.csv';

SELECT * FROM #Files;   -- confirm you see Book1.csv, Book2.csv etc.


/* 3 — Bulk insert each file */
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

    SELECT @Before = COUNT(*) FROM dbo.test;

    SET @SQL = N'
        BULK INSERT dbo.test
        FROM ''' + @FullPath + N'''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            TABLOCK
        );';

    PRINT @SQL;
    EXEC (@SQL);

    SELECT @After = COUNT(*) FROM dbo.test;
    SET @Inserted = @After - @Before;

    INSERT INTO #ImportLog (FileName, RowsInserted)
    VALUES (@FileName, @Inserted);

    PRINT 'Rows inserted: ' + CAST(@Inserted AS VARCHAR(20));

    FETCH NEXT FROM file_cursor INTO @FileName;
END

CLOSE file_cursor;
DEALLOCATE file_cursor;


/* 4 — Results */
SELECT FileName, RowsInserted FROM #ImportLog;
SELECT COUNT(*) AS TotalFinalRows FROM dbo.test;

SELECT * FROM dbo.test;
