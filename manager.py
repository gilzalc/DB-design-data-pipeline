"""
This file is a Python script that processes a CSV file from a zip archive,
creates and populates tables in a PostgreSQL database, and runs a query.
The CSV file is processed to separate the data into separate CSV files
for each table using primary keys defined for each table.
The script then creates and populates tables in the PostgreSQL
database by iterating through each table and inserting each row from
the corresponding CSV file into the table.
 Finally, the script runs a query from a SQL file on the populated database.
"""

from io import TextIOWrapper
from zipfile import ZipFile
import pandas as pd
import csv
import psycopg2

COUNTRY_COLS = [0, 1, 2, 3]
UNI_COLS = [1] + [i for i in range(4, 15)]
YearData_COLS = [4, 15, 16]
NUM_ROWS = 17
# define tables and primary keys
tables = {'Country': COUNTRY_COLS,
          'University': UNI_COLS,
          'YearData': YearData_COLS}
primary_keys = {'Country': ['countrycode'], 'University': ['iau_id1'],
                'YearData': ['iau_id1', 'year']}


# return the list of all tables
def get_names():
    return ["Country", "University", "YearData"]


def process_file():
    df = process_enrollment()
    # output the data to separate csv files for each table
    for table in tables:
        outfile = open(table + ".csv", 'w', encoding='UTF8')
        relevant_rows = df.iloc[:, (tables[table])].drop_duplicates(
            subset=primary_keys[table],
            keep='last')
        relevant_rows.to_csv(table + ".csv", index=False)
        outfile.close()


def process_enrollment():
    outfile = open("enrollment.csv", 'w', encoding='UTF8')
    outWriter = csv.writer(outfile, delimiter=",", quoting=csv.QUOTE_MINIMAL)
    # read in the csv file from zip archive
    with ZipFile('enrollment.zip') as zf:
        with zf.open('enrollment.csv') as f:
            # process the data
            reader = csv.reader(TextIOWrapper(f, 'utf-8'))
            for row in reader:
                new_row = [row[i] for i in range(NUM_ROWS)]
                outWriter.writerow(new_row)
            f.close()
            df = pd.read_csv("enrollment.csv",
                             dtype={'students5_estimated': 'Int64',
                                    'divisions': 'Int64', 'yrclosed': 'Int64',
                                    'foundedyr': 'Int64'},
                             quoting=csv.QUOTE_MINIMAL)
            df['orig_name'] = df['orig_name'].str.replace("'", "")
            return df


def create_tables(con):
    with con.cursor() as cur:
        with open("create.sql", "r") as f:
            create_sql = f.read()
        cur.execute(create_sql)
    con.commit()


def import_data(con):
    # Open a cursor to perform database operations
    cur = con.cursor()

    # Iterate through each table
    for table in get_names():
        # Open the CSV file for the table
        with open(table + ".csv", "r") as f:
            # Create a CSV reader
            reader = csv.reader(f)

            # Skip the header row
            next(reader)

            # Iterate through each row and insert it into the database
            for row in reader:
                # Build the INSERT query
                placeholders = ",".join(["%s"] * len(row))
                sql = f"INSERT INTO {table} VALUES ({placeholders})"

                # Execute the INSERT query
                cur.execute(sql, row)

    # Commit the changes
    con.commit()


def exp_query(con):
    with con.cursor() as cur:
        with open("enrollment_query.sql", "r") as f:
            query = f.read()
        cur.execute(query)
    con.commit()


if __name__ == "__main__":
    process_file()
    conn = psycopg2.connect(host="localhost", database="postgres",
                            user="gilzalc", password="*********")
    create_tables(conn)
    import_data(conn)
    conn.close()
