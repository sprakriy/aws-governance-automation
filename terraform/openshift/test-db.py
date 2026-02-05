import cx_Oracle
import os

# These come from the OpenShift Secret we created!
user = os.environ.get('DB_USER')
pw = os.environ.get('DB_PASSWORD')
dsn = os.environ.get('DB_ENDPOINT')

try:
    # Connect to the RDS instance
    connection = cx_Oracle.connect(user, pw, dsn)
    print("✅ SUCCESS: 10 Years of Oracle experience meets OpenShift!")
    print("Database Version:", connection.version)
    connection.close()
except Exception as e:
    print("❌ FAILURE: Could not connect.")
    print(e)