import pymysql

try:
    with open("c:\\capstone\\sql\\schema.sql", "r", encoding="utf-8") as f:
        sql_file = f.read()

    conn = pymysql.connect(
        host="capstone-db.cfw4cygk4dks.ap-northeast-2.rds.amazonaws.com",
        user="admin", 
        password="Shko0502@daum.net", 
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
