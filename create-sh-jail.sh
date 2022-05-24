#!/bin/sh

# This script will create an empty jail using BastilleBSD
# and provision it with minimum required structure to
# enable shell access by root, to make it useful you will
# need to copy more stuff into the jail.

# Usage: ./sh-jail.sh /full/path/to/jail

if [ -z $1 ] || [ -z $2 ]; then
  printf "Usage: ${0} /full/path/to/your/jail ip.ad.dr.ess [interface]\n"
  exit 1
fi

cleanup() {
  if [ -d "${path}/root" ]; then
    printf "Cleaning up"
    /usr/local/bin/bastille destroy $name
    ifconfig $iface delete $ip
  fi
}

path=$1
ip=$2
iface="bastille0"
name=`basename $path`

if [ ! -z $3 ]; then
  #TODO check with ifconfig that this exists `ifconfig grep $3`
  iface=$3
  printf "Using specified interface ${iface}\n"
fi

if [ ! -d $path ] && [ ! -f $path/jail.conf ]; then
  printf "Creating Bastille jail ${name}\n"
  /usr/local/bin/bastille create -E $name
  if [ ! $? ]; then
    printf "Failed to create jail\n"
    cleanup()
    exit 1
  fi
fi

printf "Creating folders in jail\n"
for d in bin etc lib libexec root usr/share/misc
do
  if [ ! -d "${path}/root/${d}" ]; then
    mkdir -p "${path}/root/${d}"
    if [ ! $? ]; then
      printf "Failed to create folder ${path}/root/${d}\n"
      cleanup()
      exit 1
    fi
  fi
done

printf "Copying minimum required files from host to the jail\n"
for f in bin/sh etc/resolv.conf lib/libc.so.7 lib/libedit.so.8 lib/libncursesw.so.9 libexec/ld-elf.so.1 usr/share/misc/termcap
do
  cp "/${f}" "$path/root/$f"
  if [ ! $? ]; then
    printf "Failed to copy file ${f} to ${path}/root/${f}\n"
    cleanup()
    exit 1
  fi
done

printf "Setting passwd db so root can login to the jail\n"
echo "root::0:0::0:0:Charlie &:/root:/bin/sh" > $path/root/etc/master.passwd
pwd_mkdb -d $path/root/etc -p $path/root/etc/master.passwd
if [ ! $? ]; then
  printf "Failed to create passwd db\n"
  cleanup()
  exit 1
fi

printf "Modifying ${path}/jail.conf\n"
sed -i '' "s/}/\n#  mount\.devfs;\n  exec\.clean;\n  exec\.start = '\/bin\/sh';\n  exec\.release = '\/sbin\/ifconfig $iface delete ${ip}';\n\n  interface = $iface;\n  ip4\.addr = ${ip};\n  ip6 = disable;\n}/" "${path}/jail.conf"

printf "Adding the jail IP to ${iface}"
ifconfig $iface add $ip

printf "\n\nDone\nCheck jail.conf is correct:\n\n"
cat $path/jail.conf
printf "\n\nYou may start the jail shell via bastille start ${name}\n\n"
