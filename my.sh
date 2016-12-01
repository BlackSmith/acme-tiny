#!/bin/bash

DOMAIN=$1
shift
ALIASES=$@
KEY=$(mktemp -u -p /etc/letsencrypt/archive/$DOMAIN/ XXX)

openssl genrsa 4096 > $KEY.key
if [ "$ALIASES" ]; then
   ALT=""
   for it in $ALIASES; do
     ALT="DNS:$it,$ALT"
   done
   openssl req -new -sha256 -key $KEY.key -subj "/" -reqexts SAN -config <(cat /etc/pki/tls/openssl.cnf <(printf "[SAN]\nsubjectAltName=${ALT}DNS:$DOMAIN")) > $KEY.csr
else
  openssl req -new -sha256 -key $KEY.key -subj "/CN=$DOMAIN" > $KEY.csr
fi
python /root/acme-tiny/acme_tiny.py --account-key /root/acme-tiny/account.key --csr $KEY.csr --acme-dir /var/www/html/.well-known/acme-challenge/ > $KEY-cert.pem || exit
[ -f /tmp/intermediate.pem ] && [ "$(find /tmp/intermediate.pem -mmin +10)" ] || wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > /tmp/intermediate.pem
cat $KEY-cert.pem /tmp/intermediate.pem > $KEY-fullchain.pem

if [ -f $KEY-fullchain.pem ]; then
  rm -f /etc/letsencrypt/live/$DOMAIN/*.pem
  ln -s $KEY.key /etc/letsencrypt/live/$DOMAIN/privkey.pem
  ln -s $KEY-cert.pem /etc/letsencrypt/live/$DOMAIN/cert.pem
  ln -s $KEY-fullchain.pem /etc/letsencrypt/live/$DOMAIN/fullchain.pem
fi

