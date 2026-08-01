# flynet

Ansible deployment of BotNATS IRC workers and NATS cluster

## Usage

```sh
source venv/bin/activate
ansible-playbook playbooks/flynet/build.yml
ansible-playbook playbooks/flynet/info.yml
ansible-playbook playbooks/flynet/destroy.yml
```
