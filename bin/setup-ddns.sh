#!/bin/sh

if [ -z "$1" ]; then
    echo "usage: $0 ddns-domain.example.com"
    exit 1
fi

DOMAIN=$1
DIR=$(dirname $(dirname "$0"))/config/named
mkdir -p "$DIR"
cd "$DIR"
DIR=$(pwd)
BASENAME=$(dnssec-keygen -a HMAC-MD5 -b 512 -n HOST "$DOMAIN")
KEY=$(awk '/Key/{print $2}' "$BASENAME.private")
ln -s "$BASENAME.key" "$DOMAIN.key"
ln -s "$BASENAME.private" "$DOMAIN.private"
touch "$DOMAIN.key.conf"
chmod 640 "$DOMAIN.key.conf"
chgrp bind "$DOMAIN.key.conf" || :
cat >"$DOMAIN.key.conf" <<EOF
key "$DOMAIN" {
    algorithm hmac-md5;
    secret "$KEY";
};
EOF

cat >"named.conf.$DOMAIN" <<EOF
include "$DIR/$DOMAIN.key.conf";
zone "$DOMAIN" {
    type master;
    file "/var/cache/bind/$DOMAIN.zone";
    allow-query { any; };
    //allow-transfer { secondary; };
    //allow-update { key "$DOMAIN"; };
    update-policy {
        grant $DOMAIN wildcard *.$DOMAIN. A;
        grant $DOMAIN wildcard *.$DOMAIN. AAAA;
        grant $DOMAIN wildcard *.$DOMAIN. TXT;
    };
};
EOF
if [ ! -f "$DOMAIN.zone" ]; then
    cat >"$DOMAIN.zone" <<EOF
\$TTL	1d
@	IN    SOA    ns.example.com. root.example.com. (
	1		; Serial
	1h		; Refresh
	15m		; Retry
	1w		; Expire
	1h )		; Negative Cache TTL
	IN	NS	ns.example.com.
EOF
fi

echo "Please edit SOA and NS of $DOMAIN.zone and copy to /var/cache/bind/$DOMAIN.zone"
echo "Please include named.conf.$DOMAIN from your named.conf"
