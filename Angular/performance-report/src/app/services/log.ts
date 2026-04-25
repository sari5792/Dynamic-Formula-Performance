import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Log {
  targil_id: number;
  method: string;
  run_time: number;
  calc_time: number;
  write_time: number;
}

@Injectable({
  providedIn: 'root'
})
export class LogService {

  private apiUrl = 'http://localhost:5004/api/logs';

  constructor(private http: HttpClient) {}

  getLogs(): Observable<Log[]> {
    return this.http.get<Log[]>(this.apiUrl);
  }
}