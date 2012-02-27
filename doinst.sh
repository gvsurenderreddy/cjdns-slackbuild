config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

preserve_perms() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ -e $OLD ]; then
    cp -a $OLD ${NEW}.incoming
    cat $NEW > ${NEW}.incoming
    mv ${NEW}.incoming $NEW
  fi
  config $NEW
}

schema_install() {
  SCHEMA="$1"
  GCONF_CONFIG_SOURCE="xml::etc/gconf/gconf.xml.defaults" \
  chroot . gconftool-2 --makefile-install-rule \
    /etc/gconf/schemas/$SCHEMA \
    1>/dev/null
}

mk_cjdns_user(){
	if [ ! -x /etc/cjdns ] ;then
		mkdir -p /etc/cjdns
	fi
	useradd cjdns -r -M -U -d /etc/cjdns -s /bin/bash
}

if ! id cjdns ;then
	if $FULLAUTO ;then mk_cjdns_user ;else
		ehco 'user cjdns does not exist. it is required for cjdns to run.'
	fi #FULLAUTO
fi

preserve_perms etc/rc.d/rc.cjdns.new
config etc/cjdns/cjdroute.conf.new
