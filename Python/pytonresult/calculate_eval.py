import pyodbc
import time
import math

server = 'localhost\\SQLEXPRESS' 
database = 'TashlumimDB'
conn_str = f'DRIVER={{SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes;'

def run_python_dynamic_calc():
    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        cursor.fast_executemany = True
        
        cursor.execute("SELECT targil_id, targil, tnai, targil_false FROM t_targil")
        formulas = cursor.fetchall()
        
        batch_size = 100000  # Adjust batch size based on memory and performance needs

        for f_id, formula, tnai, f_formula in formulas:
            print(f"Processing Formula ID {f_id}...")
            results_to_save = []
            
            # --- Calculation ---
            calc_start = time.time()
            cursor.execute("SELECT data_id, a, b, c, d FROM t_data")
            
            for d_id, a, b, c, d in cursor:
                context = {"a": a, "b": b, "c": c, "d": d, "sqrt": math.sqrt, "log": math.log, "abs": abs}
                try:
                    if tnai:
                        condition = eval(tnai, {"__builtins__": None}, context)
                        res = eval(formula if condition else f_formula, {"__builtins__": None}, context)
                    else:
                        res = eval(formula, {"__builtins__": None}, context)
                except:
                    res = None
                
                if res is not None:
                    results_to_save.append((d_id, f_id, 'Python_eval', float(res)))
            
            calc_duration = time.time() - calc_start
            print(f"Calculation finished in {calc_duration:.2f}s. Starting write...")

            # --- Write Step (in Batches) ---
            write_start = time.time()
            
            # Dividing the large list into smaller batches
            for i in range(0, len(results_to_save), batch_size):
                batch = results_to_save[i:i + batch_size]
                cursor.executemany(
                    "INSERT INTO t_results (data_id, targil_id, method, result) VALUES (?, ?, ?, ?)",
                    batch
                )
                print(f"  Inserted {i + len(batch)} / {len(results_to_save)} rows...")

            write_duration = time.time() - write_start
            total_duration = calc_duration + write_duration
            
            # Registration in log
            cursor.execute(
                "INSERT INTO t_log (targil_id, method, run_time, calc_time, write_time) VALUES (?, ?, ?, ?, ?)",
                (f_id, 'Python_eval', total_duration, calc_duration, write_duration)
            )
            
            conn.commit()
            print(f"Formula {f_id} Total: {total_duration:.2f}s (Calc: {calc_duration:.2f}s, Write: {write_duration:.2f}s)")

        cursor.close()
        conn.close()
        print("Done!")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    run_python_dynamic_calc()