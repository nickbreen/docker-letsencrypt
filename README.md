
Example:

```
le:
  image: nickbreen/letsencrypt
  volumes:
    - "/etc/letsencrypt"
    - "/var/lib/letsencrypt"
    - "/certs" # this could be the volume from the haproxy
    - "/var/www" # this should be a volume from the webserver
```
