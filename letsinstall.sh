#!/bin/bash

# TODO refactor this as an installer plugin!

for D in "${@}"; do
  echo Authenticating $D
  /opt/letsencrypt/letsencrypt-auto certonly --domains $D
  echo Installing $D
  cat /etc/letsencrypt/live/$D/{privkey,cert}.pem > /certs/$D.pem;
done;
