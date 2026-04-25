# Dynamic Formula Performance Comparison

## 📌 Overview
This project compares different approaches for calculating dynamic formulas on large datasets.

The system evaluates performance across multiple technologies:
- SQL Server (Dynamic SQL)
- C# (.NET with Bulk Insert)
- Python (eval)
- Python (pandas vectorization)
- Angular (UI dashboard)
---
## 🧱 Project Structure
Dynamic-Formula-Performance/
│
├── SQL/ # Database scripts
│ ├── create_db_script.sql
│ ├── sp_CalculateDynamic_Advanced.sql
| ├── validate_methods_results.sql
│ └── compare_results_between_methods.sql
│
├── C#/CSharpCalc # C# calculation engine (Bulk)
│
├── Python/pytonresult
│ ├── calculate_eval.py
│ └── calculate_pandas2.py
│
├── API/ReportApi # .NET Web API
│
├── Angular/performance-report # UI dashboard
│
└── Docs/
├── performance_report.pdf
└── screenshots/

---
## ⚙️ How to Run
### 1. Setup Database
Run SQL scripts in this order:
1. create_db_script.sql - creates the database schema (tables) and populates it with initial data
### 2. Run Calculations
#### SQL
Run stored procedure:
1. sp_CalculateDynamic_Advanced.sql – defines the stored procedure sp_CalculateDynamic_Advanced and runs it to calculate results
---
#### C#
Run the C# console application:
- Calculates dynamic formulas outside the database
- Uses Bulk Insert (`SqlBulkCopy`) to efficiently write results into the database
- Separates calculation time and write time for performance analysis
---
#### Python
Run both scripts:
```bash
python calculate_eval.py
python calculate_pandas2.py

### 3 API
The .NET Web API is responsible for exposing performance data collected from the different calculation methods.
It retrieves data from the database (t_log table) and provides it through REST endpoints.
To run the API:
dotnet run

### 4. Run Angular UI
The Angular application consumes this API to display results in tables and charts.
Go to the Angular project:
cd Angular/performance-report
Install dependencies:
npm install
Run the app:
ng serve
Open in browser:
**http://localhost:4200**

## 5 ## 🔍 Results Validation
To verify that all calculation methods produce identical results, run the following queries:
- compare_results_between_methods.sql – compares results between different methods and displays any differences  
- validate_methods_results.sql – should return 0 if all methods produce identical results  
These queries ensure correctness and consistency across all implementations.

---
## 6 DOCS
Contains screenshots and an explanation file
