#!/bin/bash
#
# Check Net Filter Connection Track Table Usage
# ===
#
# DESCRIPTION:
#   This plugin provides a method for monitoring the percentage used of the nf_conntrack hash
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#
# Copyright 2014 Yieldbot, Inc  <devops@yieldbot.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

# CLI Options
while getopts ':w:c:' OPT; do
  case $OPT in
    w)  WARN=$OPTARG;;
    c)  CRIT=$OPTARG;;
  esac
done

WARN=${WARN:=100}
CRIT=${CRIT:=100}

# Get the max connections
MAX=$(sysctl net.netfilter.nf_conntrack_max | awk '{ print $3 }')

# Get the current connections
CURR=$(sysctl net.netfilter.nf_conntrack_count | awk '{ print $3 }')

# Percent usage of conncetions
PERCENT=$(echo "scale=3; $CURR / $MAX *100" | bc -l | cut -d "." -f1)

# If percent isnt defined set it to 0
PERCENT=${PERCENT:=0}

if [[ $PERCENT -ge $CRIT ]] ; then
  echo "NETFILTER CONNTRACK CRITICAL - $PERCENT"
  exit 2
elif [[ $PERCENT -ge $WARN ]] ; then
  echo "NETFILTER CONNTRACK WARNING - $PERCENT"
  exit 1
else
  echo "NETFILTER CONNTRACK OK - $PERCENT"
  exit 0
fi
