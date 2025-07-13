# Democracy Index Analysis – Alternative 2

**A modular analysis pipeline of global Democracy Index data, using Python, PostgreSQL, and Tableau for structured data transformation, querying, and visualization.**

This is the **second alternative** of the Democracy Index project. For the first alternative that is entirely based on Python and Jupyter, see:  
[Alternative 1 – Python + Jupyter](https://github.com/Dan131O/Democracy_Index_Analysis_Alternative1)  

---

## How to View This Project

Depending on your interest, you can explore this project in the following ways:

1. **Full technical pipeline:**

   Includes:
   - CSV-to-PostgreSQL table creation via Python  
   → `csv_to_sql_tables.py`
   - Data cleaning and transformation using SQL  
   → `data_manipulation.sql`
   - Interactive visualizations with Tableau  
   → `visualizations.twbx`

   Use this option if you're interested in the data-processing pipeline, code, or want to explore/customize the dashboard in Tableau.

2. **Visualization summary only:**

   - Open `Tableau_Story.pdf` to view the interactive dashboard story exported from Tableau Public.

3. **Interpretation and written analysis:**

   - See the report in [Alternative 1 – PDF Report](https://github.com/Dan131O/Democracy_Index_Analysis_Alternative1/blob/main/Project_Report.pdf)  
   - Offers written interpretation of the results and detailed commentary.

---

## Project Overview

This project evaluates the relationship between the **Economist’s Democracy Index** and several key indicators:

- **Press Freedom Score**
- **Life Expectancy**
- **Education Spending (% of GDP)**
- **Population**

The main goal is to test the hypothesis:

> *Countries with higher democracy scores exhibit better press freedom, longer life expectancy, and higher educational investments.*

---

## Core Analytical Steps

1. **Python script `csv_to_postgresql.py`:**
   - Reads `.csv` datasets from `Input_DI/`
   - Cleans column names and detects data types
   - Creates and populates SQL tables in PostgreSQL

2. **SQL script `SQL_Portfolio_Democracy_Index.sql`:**
   - Cleans and standardizes all PostgreSQL tables
   - Joins datasets by country and year
   - Aggregates indicators by regime type
   - Creates summary tables for Tableau

3. **Tableau Public Dashboard:**
   - Final tables exported manually to `.csv`
   - Visualized in `Portfolio_DemocracyIndex_Final.twbx`
   - Story PDF in `Portfolio_DemocracyIndex_Story.pdf`

---

## Example Insights

- **Democracy vs. Press Freedom:** Positive correlation with Pearson *r* ≈ 0.8
- **Democracy vs. Life Expectancy:** Moderate correlation with *r* ≈ 0.6
- **Democracy vs. Education Spending:** Weaker correlation, *r* ≈ 0.4
- Aggregated by regime type: population shares, press freedom extremes, and development indicators per regime

---

## Tested Environment

- **Last updated:** Jul 12, 2025  
- **Tested with Python versions:** 3.10 – 3.13  
- **OS compatibility:** Developed and tested on Windows; should work on Unix/macOS systems as well

---

## Repository Structure
```
.
├── csv_to_postgresql.py                # Python ETL script
├── SQL_Portfolio_Democracy_Index.sql  # All SQL transformations
├── Input_DI/                           # Raw CSV datasets
│   ├── Democracy_Index_2006_2023.csv
│   ├── Population.csv
│   ├── Press_Freedom.csv
│   ├── Life_expectancy.csv
│   └── Education.csv
├── Final_csv_for_Tableau/             # Output CSVs exported from PostgreSQL
├── Portfolio_DemocracyIndex_Final.twbx # Tableau workbook
├── Portfolio_DemocracyIndex_Story.pdf  # Exported Tableau story
├── requirements.txt                    # Required Python packages
└── README.md                           # You are here
```

---

## How to Reproduce

### A) Setup Environment

1. **Clone the repository**
```bash
git clone https://github.com/USERNAME/Democracy_Index_Analysis_Alternative2.git
cd Democracy_Index_Analysis_Alternative2
```

2. **Create and activate virtual environment**
```bash
python -m venv venv
# Windows:
.\venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate
```

3. **Install required packages**
```bash
pip install -r requirements.txt
```

### B) Prepare PostgreSQL
- Install PostgreSQL (if not already)
- Create a database named `Democracy_Index_Portfolio`
- Adjust credentials in `csv_to_postgresql.py` if needed

### C) Run Python Script
```bash
python csv_to_postgresql.py
```

### D) Run SQL Script
- Open `SQL_Portfolio_Democracy_Index.sql` in pgAdmin or a SQL editor
- Execute all queries to generate cleaned, joined, and aggregated tables

### E) Load into Tableau
- Open `Portfolio_DemocracyIndex_Final.twbx` using Tableau Public
- Alternatively, review `Portfolio_DemocracyIndex_Story.pdf` as a quick overview

---

## Data Sources

Complete dataset references are documented in:

- `csv_to_postgresql.py` (during ETL process)
- `SQL_Portfolio_Democracy_Index.sql` (during SQL joins)
- `Portfolio_DemocracyIndex_Story.pdf` (with data source footnotes)

---

## Contact

Questions, feedback or collaboration ideas are welcome via email (daniel.ourinson@web.de) or [LinkedIn](https://www.linkedin.com/in/daniel-ourinson-phd-200755143/).  
Feel free to reach out directly if you'd like to discuss the project or suggest improvements.

---

*This repository is part of my personal portfolio. For more projects, please visit* [*Dan131O/portfolio*](https://github.com/Dan131O/portfolio)*.

