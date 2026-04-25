import pyodbc
import pandas as pd
import time
import math
import numpy as np

conn_str = (
    "DRIVER={SQL Server};"
    "SERVER=localhost\\SQLEXPRESS;"
    "DATABASE=TashlumimDB;"
    "Trusted_Connection=yes;"
)

try:
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    print("Loading data and formulas...")
    df_data = pd.read_sql("SELECT data_id, a, b, c, d FROM t_data", conn)
    df_formulas = pd.read_sql("SELECT targil_id, targil, tnai, targil_false FROM t_targil", conn)

    safe_dict = {"sqrt": np.sqrt, "log": np.log, "abs": np.abs} # CHANGED: Using numpy math for vectors
    all_results = []
    formula_stats = {} # CHANGED: Dictionary to store calc_time per formula

    # --- CALCULATION PHASE ---
    print(f"Starting calculation for {len(df_data)} rows...")
    
    for _, f in df_formulas.iterrows():
        calc_start = time.time() # START CALC MEASUREMENT
        
        context = {
            "a": df_data["a"], "b": df_data["b"], "c": df_data["c"], "d": df_data["d"], 
            **safe_dict
        }

        try:
            if pd.isna(f["tnai"]) or f["tnai"] == "":
                result_series = eval(f["targil"], {"__builtins__": None}, context)
            else:
                condition = eval(f["tnai"], {"__builtins__": None}, context)
                result_series = np.where(
                    condition,
                    eval(f["targil"], {"__builtins__": None}, context),
                    eval(f["targil_false"], {"__builtins__": None}, context)
                )
            
            temp_df = pd.DataFrame({
                "data_id": df_data["data_id"],
                "targil_id": f["targil_id"],
                "method": "Python_pandas_vec",
                "result": result_series
            })
            all_results.append(temp_df)
            
            calc_end = time.time()
            # CHANGED: Store only calc duration for now
            formula_stats[f["targil_id"]] = calc_end - calc_start 
            print(f"Formula {f['targil_id']} calculated in {formula_stats[f['targil_id']]:.4f}s")
            
        except Exception as e:
            print(f"Error calculating formula {f['targil_id']}: {e}")

    # --- DATA INSERTION PHASE ---
    final_df = pd.concat(all_results, ignore_index=True)
    data_to_insert = final_df.values.tolist()

    print(f"Inserting {len(data_to_insert)} total result rows...")
    write_start = time.time() # START WRITE MEASUREMENT
    
    cursor.fast_executemany = True
    chunk_size = 1000000 # Adjusted for stability
    for i in range(0, len(data_to_insert), chunk_size):
        chunk = data_to_insert[i : i + chunk_size]
        cursor.executemany(
            "INSERT INTO t_results (data_id, targil_id, method, result) VALUES (?, ?, ?, ?)",
            chunk
        )
        conn.commit()
    
    write_end = time.time()
    total_write_time = write_end - write_start # TOTAL WRITE DURATION
    
    # CHANGED: Write time per formula is total_write_time divided by number of formulas
    write_time_per_formula = total_write_time / len(df_formulas)

    # --- LOGGING PHASE (FINAL) ---
    # CHANGED: Now we insert into t_log with all three time components
    for f_id, calc_duration in formula_stats.items():
        total_run_time = calc_duration + write_time_per_formula
        cursor.execute(
            """INSERT INTO t_log (targil_id, method, run_time, calc_time, write_time) 
               VALUES (?, ?, ?, ?, ?)""",
            (int(f_id), "Python_pandas_vec", total_run_time, calc_duration, write_time_per_formula)
        )
    
    conn.commit()
    print(f"✔ Process completed. Avg Write per formula: {write_time_per_formula:.4f}s")
    conn.close()

except Exception as global_e:
    print(f"Critical Global Error: {global_e}")