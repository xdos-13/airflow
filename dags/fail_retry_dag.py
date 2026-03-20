from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def fail_task():
    raise Exception("Intentional failure")

with DAG(
    dag_id="retry_task_dag",
    start_date=datetime(2026, 3, 9),
    schedule=None,
    catchup=False,
) as dag:
    task = PythonOperator(
        task_id="fail_and_retry",
        python_callable=fail_task,
        retries=3,
        retry_delay=None
    )
