# flynet

Ansible deployment of BotNATS IRC workers and NATS cluster

## Usage

```sh
source venv/bin/activate
ansible-playbook playbooks/flynet/build.yml
ansible-playbook playbooks/flynet/info.yml
ansible-playbook playbooks/flynet/destroy.yml
```

## Debugging

```sh
flyctl logs -a <app>
flyctl machine exec <machine-id> -a <app> <command>
flyctl machines list -a <app>
flyctl status -a <app>
```
