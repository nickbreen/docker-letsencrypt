#!/bin/bash

. $LE_DIR/venv/bin/activate

exec certbot "${@}"
