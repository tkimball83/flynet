# flynet

Flynet deploys a group of stateless
[BotNATS](https://github.com/tkimball83/botnats) IRC workers and a private Core
NATS cluster on Fly.io. There are no Eggdrop userfiles, volumes, hubs, or
durable NATS streams.

BotNATS behavior and development documentation live in its own repository.
This repository owns only the Fly.io inventory, secrets, and deployment
playbooks.

## Configuration

Each BotNATS instance receives an immutable TOML file rendered from
`playbooks/flynet/templates/bot.toml.j2`. It contains bot identity, IRC and NATS
servers, and timeouts. Channels exist only in ephemeral runtime state after an
authorized `JOIN`. Secrets are environment variables and are never written
to the TOML file.

Create these encrypted SSM parameters before deployment:

```text
/flyio/api/token
/flyio/org/slug
/flyio/flynet/nats/token
/flyio/flynet/irc/totp/secret
```

The NATS token authenticates bot connections to the private NATS service. The
TOTP secret provisions an authenticator app without ever crossing IRC.
This EFnet deployment explicitly disables IRC certificate verification because
the active server pool largely uses self-signed certificates; the connections
remain encrypted.

## Development

```sh
make
make test
```

The deployment pins an immutable `ghcr.io/tkimball83/botnats:sha-*` image from
GHCR so Ansible can reliably detect and roll out BotNATS revisions.

## Deployment

```sh
source venv/bin/activate
ansible-playbook playbooks/flynet/build.yml
```

The build creates three private, volume-free NATS nodes in `ord`, `fra`, and
`iad`, then the bot apps. The servers form a full-mesh Core NATS cluster over
authenticated routes, and every bot is configured with all three stable node
addresses. Losing one NATS machine or app leaves two client endpoints and their
route intact. Because Core NATS has no durable state, volumes are unnecessary;
the online bots resynchronize their in-memory state after reconnecting. No
public IP allocation is required by the deployment.

Inspect or destroy the deployment with:

```sh
ansible-playbook playbooks/flynet/info.yml
ansible-playbook playbooks/flynet/destroy.yml
```

## IRC authorization and commands

Open the decrypted `/flyio/flynet/irc/totp/secret` SecureString in AWS Systems
Manager Parameter Store and add it to an authenticator as a time-based SHA-1
entry with six digits and a 30-second period. Use `BotNATS` as the issuer and
`flynet` as the account name.

Commands are accepted only by private message. Authenticate with the current
six-digit code from the enrolled authenticator:

```text
/msg vhagar AUTH <totp-code>
```

Authorization is bound to the exact IRC nick, user, and host for one hour. The
TOTP step is claimed through Core NATS so it cannot be reused against another
bot. Successful authentication also requests ops for that exact identity in
every managed channel where it is present. The supported commands are:

```text
DEOP <channel> <nick>
JOIN <channel> [key]
OP <channel> <nick>
PART <channel>
STATUS
HELP
```

Authenticating to any one bot authorizes the exact IRC identity on every bot for
the session. `OP` and `DEOP` can target the requester or another current channel
member. An opped provider verifies the requester has an active session before
changing the target's mode. Channel state is broadcast through NATS and included
in subsequent state exchanges.

When a bot is kicked or receives a channel-ban rejection, it requests an unban
through NATS using its exact advertised IRC identity. An opped peer removes the
matching standard ban mask, and the normal join loop returns the bot to the
channel.
