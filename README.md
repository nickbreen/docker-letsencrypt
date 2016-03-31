
# Usage

Run an instance. E.g.

```
le:
  build: .
  volumes:
    - /certs # mount this from the haproxy
    - /var/www # mount this from the web server
  environment:
    CRON_D_LE: |
      @monthly root le renew | logger
```

The service remains running for `cron`.

Then `exec` into the container and run `le` to invoke letsencrypt.

```
docker exec le le --email webmaster@example.com --domains www.example.com,example.com
```

Default configuration is set in `$XDG_CONFIG_HOME/letsencrypt/cli.sh`:

- "webroot" authentication requiring the web server's docroot volume mounted
  at `/var/www` (which can be overridden with `--webroot-path`).
- "combined" installation requiring the directory at `/certs`, typically this is
  a volume mounted from `dockercloud/haproxy`.

**Note** as of writing `dockercloud/haproxy:1.2.1` (and earlier) requires
re-deployment to pickup the new certificates, `/reload.sh` does not.
