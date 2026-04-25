using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Collections.Generic;

namespace ReportApi
{
    [ApiController]
    [Route("api/[controller]")]
    public class LogsController : ControllerBase
    {
        private readonly string connectionString =
            "Server=localhost\\SQLEXPRESS;Database=TashlumimDB;Trusted_Connection=True;TrustServerCertificate=True;";

        [HttpGet]
        public IEnumerable<Log> GetLogs()
        {
            var logs = new List<Log>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                var cmd = new SqlCommand(@"
                    SELECT targil_id, method, run_time, calc_time, write_time
                    FROM t_log", conn);

                var reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    var targilId = reader.GetInt32(0);
                    var method = reader.IsDBNull(1) ? null : reader.GetString(1);
                    var runTime = reader.IsDBNull(2) ? 0.0 : reader.GetDouble(2);
                    var calcTime = reader.IsDBNull(3) ? 0.0 : reader.GetDouble(3);
                    var writeTime = reader.IsDBNull(4) ? 0.0 : reader.GetDouble(4);

                    logs.Add(new Log
                    {
                        targil_id = targilId,
                        method = method,
                        run_time = runTime,
                        calc_time = calcTime,
                        write_time = writeTime
                    });
                }
            }

            return logs;
        }
    }
}
