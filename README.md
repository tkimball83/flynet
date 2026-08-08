# flynet

Ansible deployment of BotNATS IRC workers and NATS cluster

## Usage

```sh
make
source venv/bin/activate
ansible-playbook playbooks/flynet/flynats.yml
ansible-playbook playbooks/flynet/flybots.yml
ansible-playbook playbooks/flynet/info.yml
```

## Destroy

This permanently deletes both apps and their volumes.

```sh
ansible-playbook playbooks/flynet/destroy.yml
```

## Debugging

```sh
flyctl logs -a <app>
flyctl machine exec <machine-id> -a <app> <command>
flyctl machines list -a <app>
flyctl status -a <app>
```
