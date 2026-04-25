# Dynamic Formula Performance Comparison

## Overview
This project compares different approaches for calculating dynamic formulas on large datasets.

Technologies used:
- SQL Server (Dynamic SQL)
- C# (.NET with Bulk Insert)
- Python (eval)
- Python (pandas vectorization)
- Angular (UI dashboard)

---

##  Project Structure

```
Dynamic-Formula-Performance/
│
├── SQL/
│   ├── create_db_script.sql
│   ├── sp_CalculateDynamic_Advanced.sql
│   ├── validate_methods_results.sql
│   └── compare_results_between_methods.sql
│
├── C#/CSharpCalc
│
├── Python/pytonresult
│   ├── calculate_eval.py
│   └── calculate_pandas2.py
│
├── API/ReportApi
│
├── Angular/performance-report
│
└── Docs/
    ├── performance_report.pdf
    └── screenshots/
```

---

##  How to Run

### 1. Setup Database
Run:
- create_db_script.sql – creates schema and inserts data  

---

### 2. Run Calculations

#### SQL
- sp_CalculateDynamic_Advanced.sql – creates and runs the stored procedure  

#### C#
- Calculates formulas outside the database  
- Uses SqlBulkCopy for fast writing  
- Measures calculation and write time  

#### Python

```bash
python calculate_eval.py
python calculate_pandas2.py
```
---

### 3. API

```bash
dotnet run
```
---
### 4. Angular UI
```bash
cd Angular/performance-report
npm install
ng serve
```
Open:
http://localhost:4200


---

##  Results Validation
Run:

- compare_results_between_methods.sql – shows differences  
- validate_methods_results.sql – should return 0  

---

##  Docs
Contains:
- Performance report  
- Screenshots
-  View report: https://drive.google.com/file/d/1oWboO6pejs7MCgoImQvoA8OXK8bUwkKA/view?usp=sharing
  
## Viewing Results

The Angular dashboard is available at:
http://localhost:4200 (when running locally)

For convenience, the project also includes:
- A full performance report (Docs/performance_report.pdf)
- Screenshots of the results (Docs/screenshots)

These allow reviewing the results without running the project.

