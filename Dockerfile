FROM nickbreen/cron:v2.0.0

MAINTAINER Nick Breen <nick@foobar.net.nz>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y jq python-pip letsencrypt && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && apt-get clean
