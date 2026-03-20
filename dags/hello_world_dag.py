from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def hello():
    print("Hello Airflow!")

with DAG(
    dag_id="hello_world",
    start_date=datetime(2026, 3, 9),
    schedule=None,
    catchup=False,
) as dag:
    task = PythonOperator(
        task_id="say_hello",
        python_callable=hello,
    )
