from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def task_a(): print("Task A")
def task_b(): print("Task B")
def task_c(): print("Task C")

with DAG(
    dag_id="sequential_tasks",
    start_date=datetime(2026, 3, 9),
    schedule=None,
    catchup=False,
) as dag:
    a = PythonOperator(task_id="task_a", python_callable=task_a)
    b = PythonOperator(task_id="task_b", python_callable=task_b)
    c = PythonOperator(task_id="task_c", python_callable=task_c)

    a >> b >> c  # sequential
