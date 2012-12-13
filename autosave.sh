#!/bin/bash

savefile="/etc/iptables/rules"
oldfile=$(mktemp)
newfile=$(mktemp)

cat $savefile | sed -e "/^#.*/ d" -e "s/\[[0-9:]*\]//" > $oldfile
iptables-save | sed -e "/^#.*/ d" -e "s/\[[0-9:]*\]//" > $newfile
diffout=$(diff $oldfile $newfile)

if [ -n "$diffout" ]; then
	iptables-save > $savefile
	printf "diff output:\n$diffout" | mail -s "iptables autosave: $(cat /etc/hostname): saved new iptables rules" root@localhost
fi

rm $newfile $oldfile