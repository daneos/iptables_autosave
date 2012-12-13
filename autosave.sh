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
	mv $savefile $savefile.bak
	mv $tmpfile $savefile
	diff $oldfile $newfile | mail -s "iptables autosave: $(cat /etc/hostname): saved new iptables rules" root
fi

exit