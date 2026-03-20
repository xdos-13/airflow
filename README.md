## To launch ansible
```bash
ansible-playbook -i <inventory_path> <Playbook_path> -K
```
`-K` is used when sudo access is needed, you will be prompted to enter the sudo pwd at the script's launch.
Add -vvv vor verbose output.

## Playbooks
`playbook/deploy_controller.yml` if the playbook for an airflow controller (.resp `deploy_worker` for airflow workers).

`setup.yml` calls the two previous playbooks, controller then worker to do a full setup. Otherwise, the other playbooks can used independently in any order.
## Inventories
Two inventories exist, a manual one `inventory.ini` and a python script that uses 1password to get IPs `inventory.py`. The workers and controller IPs can be changed in 1password Airflow vault.

P.S: Verify the ssh key used by ansible, the config has mine configured so if used on another machine, it wont work.

