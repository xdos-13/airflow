from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from datetime import datetime
import duckdb

def python_task():
    total = 0
    for _ in range(20):
        total += sum(range(50_000_000))
    print("Python task total sum:", total)

def duckdb_task():
    con = duckdb.connect(database=':memory:')
    con.execute("CREATE TABLE t AS SELECT range::int AS id FROM range(50_000_000)")
    result = con.execute("SELECT SUM(id) FROM t").fetchall()
    print("DuckDB sum:", result[0][0])

with DAG(
    dag_id="load_test_flow",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
) as dag:

    python_compute = PythonOperator(
        task_id="python_task",
        python_callable=python_task,
    )

    bash_loop = BashOperator(
        task_id="bash_task",
        bash_command="""
        for i in {1..10}; do
            echo "Bash iteration $i"
            sleep 1
        done
        """,
    )

    duckdb_compute = PythonOperator(
        task_id="duckdb_task",
        python_callable=duckdb_task,
    )

    python_compute >> bash_loop >> duckdb_compute