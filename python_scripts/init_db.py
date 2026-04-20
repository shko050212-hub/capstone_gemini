import pymysql
import os
import platform

IS_WINDOWS = platform.system().lower() == "windows"
schema_path = "c:\\capstone\\sql\\schema.sql" if IS_WINDOWS else "/home/ec2-user/capstone_gemini/sql/schema.sql"

try:
    with open(schema_path, "r", encoding="utf-8") as f:
        sql_file = f.read()

    conn = pymysql.connect(
        host="capstone-db.cfw4cygk4dks.ap-northeast-2.rds.amazonaws.com",
        user="admin", 
        password="1234", 
        db="testdb", 
        port=3306
    )
    cursor = conn.cursor()
    
    statements = sql_file.split(";")
    for stmt in statements:
        if stmt.strip():
            cursor.execute(stmt)

    conn.commit()
    conn.close()
    print("RDS DB Init Success")
except Exception as e:
    print("RDS Init Error:", e)
