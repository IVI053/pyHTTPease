#!/bin/sh
BASEDIR=$(dirname $0)
cd $BASEDIR
/usr/bin/python pyHTTPease.py
echo
echo
read -p "Press [Enter] to close..."