
# Usage

Run an instance. E.g.

```
le:
  build: nickbreen/letsencrypt
  environment:
    CRON_D_LE: |
      @monthly root le renew | logger
```

The service remains running for `cron`.

Then `exec` into the container and invoke letsencrypt.

```
docker exec le le --help
```
