import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NgChartsModule } from 'ng2-charts';
import { LogService, Log } from '../services/log';

@Component({
  selector: 'app-report',
  standalone: true,
  imports: [CommonModule, NgChartsModule],
  templateUrl: './report.html',
  styleUrls: ['./report.css']
})
export class ReportComponent implements OnInit {

  logs: Log[] = [];
  chartData: any = {
    labels: [],
    datasets: []
  };
  chartOptions: any = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      x: { stacked: false },
      y: { beginAtZero: true }
    }
  };

  constructor(private logService: LogService) {}

  ngOnInit(): void {
    this.logService.getLogs().subscribe((data: any) => {
      console.log('Raw data:', data);
      if (Array.isArray(data)) {
        this.logs = data;
      } else if (data && data.logs && Array.isArray(data.logs)) {
        this.logs = data.logs;
      } else {
        console.error('Unexpected data format:', data);
      }
      console.log('Logs array:', this.logs);
      this.buildChart();
    });
  }

  buildChart() {
    const methods = [...new Set(this.logs.map(x => x.method))];

    this.chartData = {
      labels: methods,
      datasets: [
        {
          label: 'Run Time',
          data: methods.map(m =>
            this.logs
              .filter(x => x.method === m)
              .reduce((sum, x) => sum + x.run_time, 0)
          )
        }
      ]
    };
  }
}