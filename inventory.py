#!/usr/bin/env python3
import json
import subprocess

# Define hosts
#workers = ["worker1", "worker2", "worker3", "worker4"]
workers = ["worker2"]
controller = "controller"

inventory = {
    "controller": {
        "hosts": []
    },
    "workers": {
        "hosts": []
    },
    "_meta": {
        "hostvars": {}
    }
}

# Get IP from 1Password
def get_ip(hostname):
    return subprocess.check_output(
        ["op", "read", f"op://Airflow/{hostname}/password"]
    ).decode().strip()

# Populate workers
for w in workers:
    ip = get_ip(w)
    inventory["workers"]["hosts"].append(w)
    inventory["_meta"]["hostvars"][w] = {
        "ansible_host": ip,
        "ansible_user": "moka",
        "ansible_ssh_private_key_file": "/home/rida/.ssh/airflow_ansible",
        "ansible_python_interpreter": "/usr/bin/python3.8"
    }

# Add controller
ip = get_ip(controller)
inventory["controller"]["hosts"].append(controller)
inventory["_meta"]["hostvars"][controller] = {
    "ansible_host": ip,
    "ansible_user": "moka",
    "ansible_ssh_private_key_file": "/home/rida/.ssh/airflow_ansible",
    "ansible_python_interpreter": "/usr/bin/python3.8"
}

print(json.dumps(inventory, indent=2))
