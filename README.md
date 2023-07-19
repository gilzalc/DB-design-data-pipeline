# end-to-end pipeline of data processing:

This project aims to demonstrate the end-to-end process of data processing, from raw data extraction to loading the data into a PostgreSQL database. The data processing pipeline uses Apache Airflow, an open-source platform to author, schedule, and monitor workflows programmatically. The data is then stored in a PostgreSQL database, and various SQL queries are executed to perform data analysis and generate insights.


## contains:
- Create_DB.sql - Designing, normalization, and creation of the schemes 

- enrollment.csv - the data extracted from the zip file (originally)

- enrollment_query.sql - query to check the integrity

- queries_2.sql, queries_3.sql - data analysis and aggregation queries, to generate insights

- manager.py- The data processing pipeline, orchestrated by Airflow, that "extracts" the data from the zip file, transforms it to the normalized scheme, builds the db, loads it to the server, and then queries the db for further insights using psycopg2 (integration library to PostgreSQL)
