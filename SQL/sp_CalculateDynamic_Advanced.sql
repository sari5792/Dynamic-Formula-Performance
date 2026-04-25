CREATE OR ALTER PROCEDURE  sp_CalculateDynamic_Advanced
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @targil_id INT, @formula VARCHAR(MAX), @tnai VARCHAR(MAX), @false_formula VARCHAR(MAX);
    DECLARE @startTime DATETIME2, @endTime DATETIME2;
    DECLARE @sql NVARCHAR(MAX);

    -- Cursor for iterating through dynamic formulas
    DECLARE formula_cursor CURSOR FOR 
    SELECT targil_id, targil, tnai, targil_false FROM t_targil;

    OPEN formula_cursor;
    FETCH NEXT FROM formula_cursor INTO @targil_id, @formula, @tnai, @false_formula;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @startTime = SYSDATETIME();

        -- Build the dynamic SQL. 
        -- Note: We use @CurrentTargilID as a placeholder inside the string
        IF @tnai IS NULL OR @tnai = ''
            SET @sql = N'INSERT INTO t_results (data_id, targil_id, method, result) 
                        SELECT data_id, @CurrentTargilID, ''SQL'', CAST(' + @formula + N' AS FLOAT) FROM t_data';
        ELSE
            SET @sql = N'INSERT INTO t_results (data_id, targil_id, method, result) 
                        SELECT data_id, @CurrentTargilID, ''SQL'', 
                        CASE WHEN ' + @tnai + N' THEN CAST(' + @formula + N' AS FLOAT) 
                             ELSE CAST(' + @false_formula + N' AS FLOAT) END FROM t_data';

        -- FIX: Passing the @targil_id variable into the dynamic scope as @CurrentTargilID
        EXEC sp_executesql @sql, N'@CurrentTargilID INT', @CurrentTargilID = @targil_id;

        SET @endTime = SYSDATETIME();
        
        -- Logging performance
        INSERT INTO t_log (targil_id, method, run_time)
        VALUES (@targil_id, 'SQL', CAST(DATEDIFF(MILLISECOND, @startTime, @endTime) AS FLOAT) / 1000.0);

        FETCH NEXT FROM formula_cursor INTO @targil_id, @formula, @tnai, @false_formula;
    END

    CLOSE formula_cursor;
    DEALLOCATE formula_cursor;
END;
-- Exec the procedura 
EXEC sp_CalculateDynamic_Advanced;