# Democracy Index Analysis – Alternative 2

**A modular analysis pipeline of global Democracy Index data, using Python, PostgreSQL, and Tableau for structured data transformation, querying, and visualization.**

This is the **second alternative** of the Democracy Index project. For the first alternative that is entirely based on Python and Jupyter, see:\
[Alternative 1 – Python + Jupyter](https://github.com/Dan131O/Democracy_Index_Analysis_Alternative1)

---

## How to View This Project

Depending on your interest, you can explore this project in the following ways:

1. **Full technical pipeline:**

   Includes:
   - CSV-to-PostgreSQL table creation via Python\
     → [`csv_to_sql_tables.py`](./csv_to_sql_tables.py)
   - Data cleaning and transformation using SQL\
     → [`data_manipulation.sql`](./data_manipulation.sql)
   - Interactive visualizations with Tableau\
     → [`visualizations.twbx`](./visualizations.twbx)  
     
     Use this option if you're interested in the data-processing pipeline, code, or want to explore/customize the dashboard in Tableau.

2. **Visualization summary only:**
   - Open [`Tableau_Story.pdf`](./Tableau_Story.pdf) to view the interactive dashboard story exported from Tableau Public

3. **Interpretation and written analysis:**
   - See the report in [Alternative 1 – PDF Report](https://github.com/Dan131O/Democracy_Index_Analysis_Alternative1/blob/main/Project_Report.pdf)\
     Offers written interpretation of the results and detailed commentary

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

## Example Insights

- **Democracy vs. Press Freedom:** Positive correlation with Pearson *r* ≈ 0.8
- **Democracy vs. Life Expectancy:** Moderate correlation with *r* ≈ 0.6
- **Democracy vs. Education Spending:** Weaker correlation, *r* ≈ 0.4
- Aggregated by regime type: population shares, press freedom extremes, and development indicators per regime

---

## Tested Environment

- **Last updated:** Jul 12, 2025  
- **Environment:**  
  • Python 3.11  
  • PostgreSQL 16 (executed via pgAdmin 4)  
  • Tableau Public 2024.3  
- **OS compatibility:** Developed and tested on Windows; expected to run on Unix/macOS as well


---

## Repository Structure

```
.
├── Input_Datasets/                   # Raw CSV datasets
│   ├── Democracy_Index_2006_2023.csv
│   ├── Population.csv
│   ├── Press_Freedom.csv
│   ├── Life_expectancy.csv
│   └── Education.csv
├── csv_to_sql_tables.py              # All Python transformations
├── data_manipulation.sql             # All SQL transformations
├── Files_SQL_to_Tableau/             # Output CSVs exported from PostgreSQL for Tableau
├── visualizations.twbx               # Tableau workbook
├── Tableau_Story.pdf                 # Exported Tableau story
├── requirements.txt                  # Required Python packages
└── README.md                         # You are here
```

---

## How to Reproduce

### A) Setup Environment

1. **Clone the repository**
   ```bash
   git clone https://github.com/Dan131O/Democracy_Index_Analysis_Alternative2.git
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

3. **Install required Python packages**
   ```bash
   pip install -r requirements.txt
   ```

4. **Ensure PostgreSQL and pgAdmin are installed**

   - PostgreSQL version: 16  
   - pgAdmin version: 4  
   - Create a PostgreSQL database named: `Democracy_Index_Portfolio`

5. **Adjust credentials** for connecting with Python to your PostgreSQL database in [`csv_to_sql_tables.py`](./csv_to_sql_tables.py)
   ```python
   dbname = 'Democracy_Index_Portfolio'  # your PostgreSQL database name
   user = 'postgres'                     # your username
   password = 'your_password_here'       # your password
   host = 'localhost'                    # the host, if necessary ('localhost' is the default name)
   port = '5432'                         # the port, if necessary ('5432' is the default port)
   ```

6. **Run the Python script**
   ```bash
   python csv_to_sql_tables.py
   ```
   This script:
   - Reads all raw CSVs from [`Input_Datasets/`](./Input_Datasets)
   - Cleans headers and maps data types
   - Automatically creates and populates PostgreSQL tables

7. **Run the SQL script**
   - Open [`data_manipulation.sql`](./data_manipulation.sql) in pgAdmin or your preferred SQL editor
   - Run all queries
   - This will:
     - Clean and join the base tables
     - Aggregate metrics
     - Produce multiple new summary tables
   - These final summary tables have to be **manually exported to `.csv`** and saved in [`Files_SQL_to_Tableau/`](./Files_SQL_to_Tableau)  
     *(This step is necessary because Tableau Public cannot connect directly to SQL databases.)*

8. **Explore in Tableau**

   You have two options:

   - **Open the prebuilt dashboard**  
     → [`visualizations.twbx`](./visualizations.twbx)  
     Fully designed Tableau story; all visuals and filters are pre-configured.  
     *(Use Tableau Public Desktop to open.)*

   - **Build your own dashboard from scratch**  
     → Use the `.csv` files in [`Final_csv_for_Tableau/`](./Final_csv_for_Tableau)  
     Import them into Tableau manually and recreate the visualizations.


---

## Data Sources

Complete dataset references are documented in:

- [Alternative 1 – PDF Report](https://github.com/Dan131O/Democracy_Index_Analysis_Alternative1/blob/main/Project_Report.pdf)

---

## Contact

Questions, feedback or collaboration ideas are welcome via email ([daniel.ourinson@web.de](mailto\:daniel.ourinson@web.de)) or [LinkedIn](https://www.linkedin.com/in/daniel-ourinson-phd-200755143/).\
Feel free to reach out directly if you'd like to discuss the project or suggest improvements.

---

*This repository is part of my personal portfolio. For more projects, please visit* [*Dan131O/portfolio*](https://github.com/Dan131O/portfolio)\*.

