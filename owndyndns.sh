#!/bin/bash

TMPDIR="/tmp/owndyndns"
OWNDNSKEY="/etc/owndns.key"
OWNDNS="https://dns.aware.ro"
IPECHO="https://ipecho.aware.ro"

log(){
	echo "$(date +'%Y/%m/%d %H:%M:%S'):: $1" >> "${TMPDIR}"/owndyndns.log
}

get_user_agent(){
	local owndyndns_package="owndyndns"
	echo "$owndyndns_package/$(dpkg-query -f '${Version}' -W $owndyndns_package)"
}

get_public_ip(){
	wget -U "$(get_user_agent)" -O- "$IPECHO" 2>/dev/null
}

get_key(){
	if [ ! -f $OWNDNSKEY ]; then
		log "No key found, please create one in $OWNDNSKEY"
		echo "No key found, please create one in $OWNDNSKEY" >&2
		exit 1
	fi
	cat $OWNDNSKEY
}

dynamic_dns_iteration(){
	touch "${TMPDIR}/old"
	if ! get_public_ip | tee "${TMPDIR}/new" | diff "${TMPDIR}/old" - ; then
		log "IP changed old: $(cat "${TMPDIR}/old") new: $(cat "${TMPDIR}/new")"
		cat "${TMPDIR}/new" > "${TMPDIR}/old"
		curl -A "$(get_user_agent)" "$OWNDNS/$(get_key)/chip/$1/$(cat "${TMPDIR}/new")/"
	fi
}

add_dynamic_dns_entry(){
	local ip="$(get_public_ip)"
	echo "$ip" > "${TMPDIR}/old"
	curl -A "$(get_user_agent)" "$OWNDNS/$(get_key)/add/$1/A/$(cat "${TMPDIR}/old")/"
}

add_and_cron(){
	mkdir -p "${TMPDIR}"
	touch "${TMPDIR}"/{old,new}
	add_dynamic_dns_entry "$1"
	echo "*/5 * * * * root $(realpath $0) iteration $1" > /etc/cron.d/owndyndns
}

cron(){
	mkdir -p "${TMPDIR}"
	touch "${TMPDIR}"/{old,new}
	echo "*/5 * * * * root $(realpath $0) iteration $1" > /etc/cron.d/owndyndns
}

case "$1" in
	iteration) dynamic_dns_iteration "$2" ;;
	add) add_dynamic_dns_entry "$2" ;;
	cron) cron "$2" ;;
	setup) add_and_cron "$2" ;;
	*) echo "Usage: $0 {iteration|add|cron|setup} <domain>" >&2 ;;
esac