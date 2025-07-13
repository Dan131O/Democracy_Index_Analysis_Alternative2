# Author: Daniel Ourinson
# Last updated: Jul 12, 2025
# Tested python version: 3.11 

"""
"PYTHON PART" OF THE SECOND VERSION OF THE DATA ANALYSIS OF THE DEMOCRACY INDEX
"""


# Import necessary libraries
import pandas as pd  # For data manipulation and analysis           
import psycopg2      # For interaction with PostgreSQL databases             
import re            # For regular expression operations 


"""
Function below creates a PostgreSQL table from a CSV file with a custom delimiter, sanitizes column names,
and inserts the data into the table.

Parameters:
csv_file_path (str): Path to the CSV file
table_name (str): Name of the table to be created in PostgreSQL
dbname (str): Name of the PostgreSQL database
user (str): PostgreSQL username
password (str): PostgreSQL password
host (str): Host address for PostgreSQL (default is 'localhost')
port (str): Port number for PostgreSQL (default is '5432')
delimiter (str): The delimiter used in the CSV file (default is ',')
"""

def create_table_from_csv(csv_file_path, table_name, dbname, user, password, delimiter, host='localhost', port='5432'):
    
    # Step 1: Load the CSV file into a Pandas DataFrame using the specified delimiter
    # In this case, the quotechar='"' ensures that Pandas treats everything between double quotes as a single field, even if it contains commas or other delimiters.
    df = pd.read_csv(csv_file_path, delimiter=delimiter, quotechar='"')
    
    # Print the first few rows of the DataFrame to check if the CSV data is loaded properly
    print(df.head())

    # Step 2: Function to map Pandas data types to PostgreSQL data types
    def map_data_types(dtype):
        # Check if the data type is an integer (e.g., int64) and map to PostgreSQL's INT type
        if pd.api.types.is_integer_dtype(dtype):
            return 'INT'
        # Check if the data type is a float (e.g., float64) and map to PostgreSQL's FLOAT type
        elif pd.api.types.is_float_dtype(dtype):
            return 'FLOAT'
        # Check if the data type is an object (typically for strings) and map to PostgreSQL's VARCHAR
        elif pd.api.types.is_object_dtype(dtype):
            return 'VARCHAR'
        # Check if the data type is a datetime and map to PostgreSQL's TIMESTAMP type
        elif pd.api.types.is_datetime64_any_dtype(dtype):
            return 'TIMESTAMP'
        # Fallback to TEXT type for any other data types
        else:
            return 'TEXT'

    # Step 3: Sanitize column names (remove spaces and special characters)
    def sanitize_column_name(col_name):
        # Use regular expressions to remove non-alphanumeric characters from column names
        return re.sub(r'\W+', '', col_name)

    # Get the original column names from the DataFrame
    original_columns = df.columns
    # Sanitize the column names by applying the sanitize_column_name function to each column
    sanitized_columns = [sanitize_column_name(col) for col in original_columns]
    
    # Map the data types for each column using the map_data_types function and store them in a list
    types = [map_data_types(df[col].dtype) for col in original_columns]

    # Step 4: Convert DataFrame rows to a list of tuples to prepare for insertion into PostgreSQL
    # .values returns a numpy array of the data, and .tolist() converts it into a list of lists
    data_to_insert = df.values.tolist()

    # Step 5: Connect to the PostgreSQL database using the connection parameters
    conn = psycopg2.connect(
        dbname=dbname,        # Name of the PostgreSQL database
        user=user,            # PostgreSQL username
        password=password,    # PostgreSQL password
        host=host,            # Host address (default is 'localhost')
        port=port             # Port number (default is '5432')
    )

    # Step 6: Create a cursor object to execute SQL commands
    cur = conn.cursor()

    # Step 7: Dynamically create the table based on the sanitized column headers and inferred data types
    create_table_query = f'''
    CREATE TABLE IF NOT EXISTS {table_name} (
        {', '.join([f'"{col}" {typ}' for col, typ in zip(sanitized_columns, types)])}
    );
    '''
    
    # Print the generated SQL create table query for debugging purposes
    print(f"Create Table Query for {table_name}: {create_table_query}")

    # Execute the create table query to create the table in PostgreSQL
    cur.execute(create_table_query)
    # Commit the transaction to make sure the table is created
    conn.commit()

    # Step 8: Automatically insert data into the table using the original column headers
    insert_query = f'''
    INSERT INTO {table_name} ({', '.join([f'"{col}"' for col in sanitized_columns])}) 
    VALUES ({', '.join(['%s'] * len(sanitized_columns))});
    '''
    
    # Print the generated SQL insert query for debugging purposes
    print(f"Insert Query for {table_name}: {insert_query}")

    # Step 9: Use executemany to insert all rows from the DataFrame into the PostgreSQL table
    cur.executemany(insert_query, data_to_insert)

    # Commit the transaction to ensure the data is inserted
    conn.commit()

    # Step 10: Close the cursor and the database connection
    cur.close()
    conn.close()

    # Print a success message indicating that the CSV data has been inserted successfully
    print(f"CSV data inserted into PostgreSQL table '{table_name}' successfully!")


# Array with paths of the datasets 
paths_datasets = [
    '.\Input_Dataset\Democracy_Index_2006_2023.csv', # Democracy Index
    '.\Input_Dataset\Population.csv', # Population
    '.\Input_Dataset\Press_Freedom.csv', # Press freedom score
    '.\Input_Dataset\Life_expectancy.csv', # Life expectancy
    '.\Input_Dataset\Education.csv' # Education spending
]


# Array with table names matching the array "paths_datasets"
table_names = [
    'Democracy_Index', # Democracy Index
    'Population', # Population
    'Press_Freedom', # Press freedom score
    'Life_Expectancy', # Life expectancy
    'Education' # Education spending
]

# Array with delimeters matching the array "paths_datasets"
delimiters = [
    ',', # Democracy Index
    '","', # Population
    ';', # Press freedom score
    '","', # Life expectancy
    ',' # Education spending
]

# Utilization of function "create_table_from_csv" using a for loop to run all datasets 
for ind, val in enumerate(paths_datasets): 
    create_table_from_csv(
        csv_file_path=paths_datasets[ind],
        table_name=table_names[ind],
        dbname='Democracy_Index_Portfolio',        # Replace with your database name
        user='postgres',      # Replace with your PostgreSQL username
        password='',   # Replace with your PostgreSQL password (here left blank for security reasons)
        delimiter=delimiters[ind]   # Specify the correct delimiter for the CSV
    )