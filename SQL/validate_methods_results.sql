
USE TashlumimDB;
GO
-- If there is 0 row,The methods result are the same.
SELECT *
FROM (
    SELECT 
        r.data_id,
        r.targil_id,

        MAX(CASE WHEN r.method = 'sql' THEN r.result END) AS SQL_Result,
        MAX(CASE WHEN r.method = 'CSharp_Bulk' THEN r.result END) AS CSharp_Result,
        MAX(CASE WHEN r.method = 'Python_eval' THEN r.result END) AS Python_eval_Result,
        MAX(CASE WHEN r.method = 'Python_pandas_vec' THEN r.result END) AS Python_vec_Result

    FROM t_results r
    GROUP BY r.data_id, r.targil_id
) x
WHERE 
    ABS(ISNULL(SQL_Result,0) - ISNULL(CSharp_Result,0)) > 0.0001
 OR ABS(ISNULL(SQL_Result,0) - ISNULL(Python_eval_Result,0)) > 0.0001
 OR ABS(ISNULL(SQL_Result,0) - ISNULL(Python_vec_Result,0)) > 0.0001;