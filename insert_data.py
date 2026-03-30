import mysql.connector
import csv
from tqdm import tqdm
from pprint import pprint
# customers.csv headers customer_id,first_name,last_name,email,phone,street,city,state,zip,birthdate

BULK_CREATE_BATCH_SIZE = 5_000

def get_conn(database="Pharmacydb"):
    if database=="Pharmacydb":
        conn = mysql.connector.connect(
            host="192.168.1.179",
            port=3306,
            user="root",
            password="example",
            database="Pharmacydb"
        )
    else:
        print("Returning conn without Database")
        conn = mysql.connector.connect(
            host="192.168.1.179",
            port=3306,
            user="root",
            password="example",
        )
    # conn = mysql.connector.connect(
    #     host="localhost",
    #     port=3326,
    #     user="root",
    #     password="example",
    #     database="Pharmacydb"
    # )
    return conn

def recreate_db():
    print("recreating database...")
    try:
        conn = get_conn()
        cursor = conn.cursor()

        with open("forward_engineered.sql", "r") as f:
            sql_script = f.read().split(';')

        # print(sql_script)
        try:
            for q in sql_script:
                if q.startswith("--"):
                    continue
                if q.strip() != '':
                    cursor.execute(q)
        except Exception as e:
            print(e)
            print(q)
    except:
        conn = get_conn(database='noDB')
        cursor = conn.cursor()

        with open("forward_engineered.sql", "r") as f:
            sql_script = f.read().split(';')

        # print(sql_script)
        try:
            for q in sql_script:
                if q.startswith("--"):
                    continue
                if q.strip() != '':
                    cursor.execute(q)
        except Exception as e:
            print(e)
            print(q)
    conn.commit()
    cursor.close()
    conn.close()

    del conn
    del cursor
    print("recreating database... done")



def insert_customer_data():
    # Connect to MySQL
    conn = get_conn()
    csv_headers = "customer_id,first_name,last_name,email,phone,street,city,state,zip,birthdate".split(',')
    csv_name = "customer.csv"
    cursor = conn.cursor()

    rows_inserted = 0

    with open(csv_name) as f:
        total_rows = sum(1 for _ in f) - 1  # minus header
    # Open CSV file
    with open(csv_name, 'r', newline='\n') as csvfile:
        reader = csv.DictReader(csvfile, fieldnames=csv_headers)
        next(reader, None)

        values = list()
        for row in tqdm(reader, total=total_rows, desc=f"Processing {csv_name}"):

            columns = csv_headers
            column_names = ", ".join(columns)
            placeholders = ", ".join(["%s"] * len(columns))

            sql = f"INSERT INTO Customer ({column_names}) VALUES ({placeholders})"

            values.append(tuple(row[col] for col in columns))

            if len(values)==BULK_CREATE_BATCH_SIZE:
                cursor.executemany(sql, values)
                conn.commit()
                # print(cursor.rowcount, "rows inserted")
                rows_inserted = rows_inserted + cursor.rowcount
                del values
                values = list()

        cursor.executemany(sql, values)
        conn.commit()
        rows_inserted = rows_inserted + cursor.rowcount

        print(rows_inserted, "rows inserted")

        # Close connection
        cursor.close()
        conn.close()
    del conn
    del cursor

def insert_employee_data():
    conn = get_conn()
    cursor = conn.cursor()

    csv_name = "employee.csv"
    employee_csv_headers = "employee_id,first_name,last_name,email,phone,role,hire_date".split(',')

    with open(csv_name) as f:
        total_rows = sum(1 for _ in f) - 1  # minus header
    # Open CSV file
    with open(csv_name, 'r', newline='\n') as csvfile:
        reader = csv.DictReader(csvfile, fieldnames=employee_csv_headers)
        next(reader, None)
        for row in tqdm(reader, total=total_rows, desc=f"Processing {csv_name}"):
            columns = ", ".join(row.keys())  # id, name, age
            placeholders = ", ".join(["%s"] * len(row))  # %s, %s, %s
            values = list(row.values())
            # print(values, "values", type(values[0]))
            values[0] = int(values[0])
            values = tuple(values)

            sql = f"INSERT INTO Employee ({columns}) VALUES {values}"
            cursor.execute(sql, row)

            # Commit changes
            conn.commit()

        # Close connection
        cursor.close()
        conn.close()
    del conn
    del cursor

def insert_product_data():
    conn = get_conn()
    cursor = conn.cursor()

    csv_name = "Pharmacy_Products.csv"
    csv_headers = "name,packaging,price,discounted_price,discount_percentage".split(',')
    rows_inserted = 0

    with open(csv_name) as f:
        total_rows = sum(1 for _ in f) - 1  # minus header
    # Open CSV file
    with open(csv_name, 'r', newline='\n') as csvfile:
        reader = csv.DictReader(csvfile, fieldnames=csv_headers)
        next(reader, None)

        values = list()
        drug_id = 1
        for row in tqdm(reader, total=total_rows, desc=f"Processing {csv_name}"):
            columns = ['drug_id'] + csv_headers
            column_names = ", ".join(columns)
            placeholders = ", ".join(["%s"] * len(columns))

            sql = f"INSERT INTO Drug ({column_names}) VALUES ({placeholders})"

            values.append(tuple([drug_id] + [row[col] for col in columns if col!='drug_id']))

            if len(values)==BULK_CREATE_BATCH_SIZE:
                cursor.executemany(sql, values)
                conn.commit()
                # print(cursor.rowcount, "rows inserted")
                rows_inserted = rows_inserted + cursor.rowcount
                del values
                values = list()

            drug_id = drug_id + 1

        cursor.executemany(sql, values)
        conn.commit()
        rows_inserted = rows_inserted + cursor.rowcount

        print(rows_inserted, "rows inserted")

        # Close connection
        cursor.close()
        conn.close()
    del conn
    del cursor

def insert_prescription_data():
    conn = get_conn()
    cursor = conn.cursor()

    csv_name = "prescription.csv"
    csv_headers = "prescription_id,customer_id,doctor_name,issue_date,valid_until,notes".split(',')
    rows_inserted = 0
    with open(csv_name) as f:
        total_rows = sum(1 for _ in f) - 1  # minus header
    # Open CSV file
    with open(csv_name, 'r', newline='\n') as csvfile:
        reader = csv.DictReader(csvfile, fieldnames=csv_headers)
        next(reader, None)
        values = list()
        for row in tqdm(reader, total=total_rows, desc=f"Processing {csv_name}"):

            columns = csv_headers
            column_names = ", ".join(columns)
            placeholders = ", ".join(["%s"] * len(columns))

            sql = f"INSERT INTO Prescription ({column_names}) VALUES ({placeholders})"

            values.append(tuple(row[col] for col in columns))

            if len(values)==BULK_CREATE_BATCH_SIZE:
                cursor.executemany(sql, values)
                conn.commit()
                # print(cursor.rowcount, "rows inserted")
                rows_inserted = rows_inserted + cursor.rowcount
                del values
                values = list()

        cursor.executemany(sql, values)
        conn.commit()
        rows_inserted = rows_inserted + cursor.rowcount

        print(rows_inserted, "rows inserted")


        # Close connection
        cursor.close()
        conn.close()
    del conn
    del cursor

def insert_prescription_item_data():
    conn = get_conn()
    cursor = conn.cursor()

    csv_name = "prescription_items.csv"
    csv_headers = "prescription_item_id,prescription_id,drug_id,prescribed_quantity".split(',')
    rows_inserted = 0
    with open(csv_name) as f:
        total_rows = sum(1 for _ in f) - 1  # minus header
    # Open CSV file
    with open(csv_name, 'r', newline='\n') as csvfile:
        reader = csv.DictReader(csvfile, fieldnames=csv_headers)
        next(reader, None)
        values = list()
        for row in tqdm(reader, total=total_rows, desc=f"Processing {csv_name}"):

            columns = csv_headers
            column_names = ", ".join(columns)
            placeholders = ", ".join(["%s"] * len(columns))

            sql = f"INSERT INTO Prescription_Drug ({column_names}) VALUES ({placeholders})"

            values.append(tuple(row[col] for col in columns))

            if len(values)==BULK_CREATE_BATCH_SIZE:
                cursor.executemany(sql, values)
                conn.commit()
                # print(cursor.rowcount, "rows inserted")
                rows_inserted = rows_inserted + cursor.rowcount
                del values
                values = list()

        cursor.executemany(sql, values)
        conn.commit()
        rows_inserted = rows_inserted + cursor.rowcount

        print(rows_inserted, "rows inserted")


        # Close connection
        cursor.close()
        conn.close()
    del conn
    del cursor

def insert_order_data():
    conn = get_conn()
    cursor = conn.cursor()
    csv_name = "order.csv"
    csv_headers = "order_id,customer_id,employee_id,prescription_id,order_date,status,payment_method,items_count,subtotal,tax_amount,shipping_fee,total_amount".split(',')
    rows_inserted = 0
    with open(csv_name) as f:
        total_rows = sum(1 for _ in f) - 1  # minus header
    # Open CSV file
    with open(csv_name, 'r', newline='\n') as csvfile:
        reader = csv.DictReader(csvfile, fieldnames=csv_headers)
        next(reader, None)
        values = list()
        for row in tqdm(reader, total=total_rows, desc=f"Processing {csv_name}"):

            columns = csv_headers
            column_names = ", ".join(columns)
            placeholders = ", ".join(["%s"] * len(columns))

            sql = f"INSERT INTO Orders ({column_names}) VALUES ({placeholders})"

            values.append(tuple(row[col] for col in columns))

            if len(values)==BULK_CREATE_BATCH_SIZE:
                cursor.executemany(sql, values)
                conn.commit()
                # print(cursor.rowcount, "rows inserted")
                rows_inserted = rows_inserted + cursor.rowcount
                del values
                values = list()

        cursor.executemany(sql, values)
        conn.commit()
        rows_inserted = rows_inserted + cursor.rowcount

        print(rows_inserted, "rows inserted")


        # Close connection
        cursor.close()
        conn.close()
    del conn
    del cursor

recreate_db()
insert_customer_data()
insert_employee_data()
insert_product_data()
insert_prescription_data()
insert_prescription_item_data()
insert_order_data()