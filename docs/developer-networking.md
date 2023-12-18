# Developer Networking Setup

This document is specific to the Mac environment, since that's generally what Green River uses, but most of the steps are platform agnostic, and the concepts can be extended to any environment.

Networking and mail delivery mostly exists as dependencies external to CAS, and shared with the warehouse.

To easily access the application, you'll want to add the following line to `/etc/hosts` on your host machine.

```
127.0.0.1 boston-cas.dev.test
```

## Mail
Mail delivery is done through [MailHog, please see documentation in the Warehouse](https://github.com/greenriver/hmis-warehouse/blob/stable/docs/mailhog/developer-mail.md)

## DNS
DNS is handled by [Traefik, please see documentation in the Warehouse](https://github.com/greenriver/hmis-warehouse/blob/6a4100102293a21d7d0d8d31e0a6ec18728d39ce/docs/traefik/developer-network.md)

### DIRENV

If not already set up, install DIRENV. You will need to allow the changes after updating the file.

```
brew install direnv
direnv allow
```

Append your `.envrc` with the following 

```
export FQDN=boston-cas.dev.test
export TRAEFIK_ENABLED=true
```

Allow the file changes through direnv
```
direnv allow
```
For direnv to work properly it needs to be hooked into the shell. Each shell has its own extension mechanism. Complete the [setup instructions](https://direnv.net/docs/hook.html) for  your shell.