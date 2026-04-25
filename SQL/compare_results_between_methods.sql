USE TashlumimDB;
GO
SELECT TOP 100
    r.data_id,
    r.targil_id,

    MAX(CASE WHEN r.method = 'sql' THEN r.result END) AS Result_SQL,
    MAX(CASE WHEN r.method = 'CSharp_Bulk' THEN r.result END) AS Result_CSharp,
    MAX(CASE WHEN r.method = 'Python_eval' THEN r.result END) AS Result_Python_eval,
    MAX(CASE WHEN r.method = 'Python_pandas_vec' THEN r.result END) AS Result_Python_vec,

   -- Comparison checks (with tolerance)
    CASE 
        WHEN ABS(ISNULL(MAX(CASE WHEN r.method = 'sql' THEN r.result END),0) -
                 ISNULL(MAX(CASE WHEN r.method = 'CSharp_Bulk' THEN r.result END),0)) < 0.0001
        THEN 1 ELSE 0 
    END AS Is_SQL_vs_CSharp,

    CASE 
        WHEN ABS(ISNULL(MAX(CASE WHEN r.method = 'sql' THEN r.result END),0) -
                 ISNULL(MAX(CASE WHEN r.method = 'Python_eval' THEN r.result END),0)) < 0.0001
        THEN 1 ELSE 0 
    END AS Is_SQL_vs_Python_eval,

    CASE 
        WHEN ABS(ISNULL(MAX(CASE WHEN r.method = 'sql' THEN r.result END),0) -
                 ISNULL(MAX(CASE WHEN r.method = 'Python_pandas_vec' THEN r.result END),0)) < 0.0001
        THEN 1 ELSE 0 
    END AS Is_SQL_vs_Python_vec

FROM t_results r
GROUP BY r.data_id, r.targil_id
ORDER BY r.data_id, r.targil_id;