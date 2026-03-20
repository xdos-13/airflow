from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime

with DAG(
    dag_id="test",
    start_date=datetime(2024,1,1),
    schedule="@hourly",
    catchup=False
):

    t1 = BashOperator(
        task_id="test_task",
        bash_command="echo hello from worker",
        queue="default"
    )