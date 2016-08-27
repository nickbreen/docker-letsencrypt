FROM nickbreen/cron:v2.0.0

MAINTAINER Nick Breen <nick@foobar.net.nz>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y jq python-pip letsencrypt && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && apt-get clean

COPY letsencrypt-combined-installer/ /opt/letsencrypt-combined-installer/

COPY ini /etc/opt/letsencrypt/

RUN pip install -e /opt/letsencrypt-combined-installer/

RUN TMP=$(mktemp -d) && cd $TMP && \
    letsencrypt --help letsencrypt-combined:combined && \
    letsencrypt --help letsencrypt-combined:dockercloud && \
    (openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 90 -nodes -subj '/CN=test.example.com/OU=Test/O=Example/C=US' && \
    letsencrypt -vvv --config /etc/opt/letsencrypt/install.ini install \
        --cert-path cert.pem \
        --key-path key.pem \
        --domains test.example.com \
        --letsencrypt-combined:combined-path . || cat letsencrypt.log && \
    test -s test.example.com.pem ) && \
    cd && rm -rf $TMP
