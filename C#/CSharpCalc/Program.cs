using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Collections.Generic;

namespace DynamicFormulaEngine
{
    class Program
    {
        static string connectionString =
            "Server=localhost\\SQLEXPRESS;Database=TashlumimDB;Trusted_Connection=True;";

        static void Main()
        {
            Console.WriteLine("==== START ====");

            var formulas = GetFormulas();

            foreach (var formula in formulas)
            {
                ProcessFormulaBulk(formula);
            }

            Console.WriteLine("==== END ====");
        }

        // ===============================
        // MAIN PROCESS
        // ===============================
        static void ProcessFormulaBulk(Targil formula)
        {
            Console.WriteLine($"Processing formula {formula.Id}");

            Stopwatch total = Stopwatch.StartNew();
            Stopwatch calc = new Stopwatch();
            Stopwatch write = new Stopwatch();

            DataTable resultsTable = CreateResultsTable();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                SqlCommand cmd = new SqlCommand("SELECT data_id, a, b, c, d FROM t_data", conn);
                SqlDataReader reader = cmd.ExecuteReader();

                DataTable computeTable = new DataTable();

                calc.Start();

                while (reader.Read())
                {
                    int dataId = reader.GetInt32(0);
                    double a = reader.GetDouble(1);
                    double b = reader.GetDouble(2);
                    double c = reader.GetDouble(3);
                    double d = reader.GetDouble(4);

                    string expression = BuildExpression(formula, a, b, c, d);

                    object result;

                    try
                    {
                        result = computeTable.Compute(expression, "");
                    }
                    catch
                    {
                        result = DBNull.Value;
                    }

                    resultsTable.Rows.Add(dataId, formula.Id, "CSharp_Bulk", result);
                }

                calc.Stop();
            }

            // ===============================
            // BULK INSERT
            // ===============================
            write.Start();

            using (SqlBulkCopy bulk = new SqlBulkCopy(connectionString))
            {
                bulk.DestinationTableName = "t_results";
                bulk.BatchSize = 10000;
                bulk.BulkCopyTimeout = 0;
                bulk.EnableStreaming = true;

                bulk.ColumnMappings.Add("data_id", "data_id");
                bulk.ColumnMappings.Add("targil_id", "targil_id");
                bulk.ColumnMappings.Add("method", "method");
                bulk.ColumnMappings.Add("result", "result");

                bulk.WriteToServer(resultsTable);
            }

            write.Stop();
            total.Stop();

            InsertLog(formula.Id, "CSharp_Bulk",
                total.Elapsed.TotalSeconds,
                calc.Elapsed.TotalSeconds,
                write.Elapsed.TotalSeconds);

            Console.WriteLine($"Done formula {formula.Id} | Time: {total.Elapsed.TotalSeconds}s");
        }

        // ===============================
        // LOAD FORMULAS
        // ===============================
        static List<Targil> GetFormulas()
        {
            var list = new List<Targil>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                SqlCommand cmd = new SqlCommand("SELECT * FROM t_targil", conn);
                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    list.Add(new Targil
                    {
                        Id = reader.GetInt32(0),
                        Expression = reader.GetString(1),
                        Condition = reader.IsDBNull(2) ? null : reader.GetString(2),
                        FalseExpression = reader.IsDBNull(3) ? null : reader.GetString(3)
                    });
                }
            }

            return list;
        }

        // ===============================
        // BUILD EXPRESSION
        // ===============================
        static string BuildExpression(Targil t, double a, double b, double c, double d)
        {
            string expr = t.Expression;

            if (!string.IsNullOrEmpty(t.Condition))
            {
                bool condition = EvaluateCondition(t.Condition, a, b, c, d);
                expr = condition ? t.Expression : t.FalseExpression;
            }

            return expr
                .Replace("a", a.ToString(System.Globalization.CultureInfo.InvariantCulture))
                .Replace("b", b.ToString(System.Globalization.CultureInfo.InvariantCulture))
                .Replace("c", c.ToString(System.Globalization.CultureInfo.InvariantCulture))
                .Replace("d", d.ToString(System.Globalization.CultureInfo.InvariantCulture));
        }

        // ===============================
        // CONDITION
        // ===============================
        static bool EvaluateCondition(string condition, double a, double b, double c, double d)
        {
            string expr = condition
                .Replace("a", a.ToString(System.Globalization.CultureInfo.InvariantCulture))
                .Replace("b", b.ToString(System.Globalization.CultureInfo.InvariantCulture))
                .Replace("c", c.ToString(System.Globalization.CultureInfo.InvariantCulture))
                .Replace("d", d.ToString(System.Globalization.CultureInfo.InvariantCulture));

            DataTable dt = new DataTable();

            try
            {
                return Convert.ToBoolean(dt.Compute(expr, ""));
            }
            catch
            {
                return false;
            }
        }

        // ===============================
        // RESULTS TABLE (IN MEMORY)
        // ===============================
        static DataTable CreateResultsTable()
        {
            DataTable table = new DataTable();

            table.Columns.Add("data_id", typeof(int));
            table.Columns.Add("targil_id", typeof(int));
            table.Columns.Add("method", typeof(string));
            table.Columns.Add("result", typeof(double));

            return table;
        }

        // ===============================
        // LOG INSERT
        // ===============================
        static void InsertLog(int targilId, string method, double run, double calc, double write)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO t_log (targil_id, method, run_time, calc_time, write_time)
                    VALUES (@targil_id, @method, @run, @calc, @write)", conn);

                cmd.Parameters.AddWithValue("@targil_id", targilId);
                cmd.Parameters.AddWithValue("@method", method);
                cmd.Parameters.AddWithValue("@run", run);
                cmd.Parameters.AddWithValue("@calc", calc);
                cmd.Parameters.AddWithValue("@write", write);

                cmd.ExecuteNonQuery();
            }
        }
    }

    // ===============================
    // MODEL
    // ===============================
    class Targil
    {
        public int Id { get; set; }
        public string Expression { get; set; }
        public string Condition { get; set; }
        public string FalseExpression { get; set; }
    }
}