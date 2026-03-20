from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def print_num(n): print(f"Number: {n}")

with DAG(
    dag_id="parallel_tasks",
    start_date=datetime(2026, 3, 9),
    schedule=None,
    catchup=False,
) as dag:
    t1 = PythonOperator(task_id="print_1", python_callable=lambda: print_num(1))
    t2 = PythonOperator(task_id="print_2", python_callable=lambda: print_num(2))
    t3 = PythonOperator(task_id="print_3", python_callable=lambda: print_num(3))

    # parallel execution
    [t1, t2, t3]
