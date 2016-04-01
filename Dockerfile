FROM nickbreen/cron:v1.0.0

MAINTAINER Nick Breen <nick@foobar.net.nz>

# Derived from https://letsencrypt.org/getting-started/
# Then re-derived from https://letsencrypt.readthedocs.org/en/latest/contributing.html

ENV LE_VER=0.4.2

RUN curl -LsSf https://github.com/letsencrypt/letsencrypt/archive/v$LE_VER.tar.gz | tar zx -C /opt

RUN /opt/letsencrypt-$LE_VER/letsencrypt-auto-source/letsencrypt-auto --os-packages-only

RUN cd /opt/letsencrypt-$LE_VER && tools/venv.sh

ENV COMB_VER=1.0.0-beta1

RUN curl -LsSf https://github.com/nickbreen/letsencrypt-combined-installer/archive/v$COMB_VER.tar.gz | tar zx -C /opt

RUN . /opt/letsencrypt-$LE_VER/venv/bin/activate && cd /opt/letsencrypt-combined-installer-$COMB_VER && python setup.py install

ENV XDG_CONFIG_HOME=/etc/opt

COPY *.ini $XDG_CONFIG_HOME/letsencrypt/

COPY le.sh /usr/local/bin/le

# Test
RUN TMP=$(mktemp -d) && cd $TMP && \
    le --help letsencrypt-combined:combined && \
    (openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 90 -nodes -subj '/CN=example.com/O=Test/C=NZ' && \
    le -vvv --config /etc/opt/letsencrypt/install.ini install \
        --cert-path cert.pem \
        --key-path key.pem \
        --domains example.com \
        --letsencrypt-combined:combined-path . && \
    test -s example.com.pem ) || \
    ( cat /var/log/letsencrypt/letsencrypt.log && false ) && \
    cd && rm -rf $TMP
