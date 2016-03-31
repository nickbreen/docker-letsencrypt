#!/bin/bash

. /opt/letsencrypt-$LE_VER/venv/bin/activate

exec letsencrypt "${@}"
