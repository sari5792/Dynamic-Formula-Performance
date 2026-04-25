namespace ReportApi
{
    public class Log
    {
        public int targil_id { get; set; }
        public string? method { get; set; }
        public double run_time { get; set; }
        public double calc_time { get; set; }
        public double write_time { get; set; }
    }
}
