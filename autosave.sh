#!/bin/bash

savefile="/etc/iptables/rules"
oldfile=$(mktemp)
newfile=$(mktemp)
tmpfile=$(mktemp)

trap 'rm $newfile $oldfile $tmpfile' EXIT

cat $savefile | sed -e "/^#.*/ d" -e "/^:.*/ s/\[[0-9:]*\]//" > $oldfile
iptables-save | sed -e "/^#.*/ d" -e "/^:.*/ s/\[[0-9:]*\]//" > $newfile

if [ -n "$(cmp $oldfile $newfile)" ]; then
	iptables-save > $tmpfile
	cp $savefile $savefile.bak || { echo "Cannot make backup file."; exit 1; }
	mv $tmpfile $savefile || { echo "Cannot move temp file to $savefile"; exit 1; }
	diff $oldfile $newfile | mail -s "iptables autosave: $(cat /etc/hostname): saved new iptables rules" root
fi

exit