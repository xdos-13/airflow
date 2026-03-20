from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def push_value(ti):
    ti.xcom_push(key="value", value=42)

def pull_value(ti):
    v = ti.xcom_pull(key="value", task_ids="push_task")
    print(f"Pulled value: {v}")

with DAG(
    dag_id="xcom_example",
    start_date=datetime(2026, 3, 9),
    schedule=None,
    catchup=False,
) as dag:
    push_task = PythonOperator(task_id="push_task", python_callable=push_value)
    pull_task = PythonOperator(task_id="pull_task", python_callable=pull_value)

    push_task >> pull_task
