#!/bin/sh
# Script that changes piratebox.conf that it 
#  works with the mesh setup


if [ -z $1 ] ; then
   echo << EOM 
      Usage:  mesh_configure.sh <piratebox.conf> <enable|disable> <baseip>
       
       enable requires baseIP, which is used for DHCP-Setup
       disable resets configuration back to 192.168.1.x
EOM
fi

PIRATEBOX_CONF=$1
BASEIP=$3

. $1 

if [ "$2" = "enable" ] ; then

  eval $(echo "$BASEIP" | awk '{print "IP1="$1";IP2="$2";IP3="$3";IP4="$4}' FS=.)
  MESH_NET="$IP1"."$IP2"."$IP3"
  MESH_IP=$IP4
  MESH_START_DHCP=$(( $IP4 + 5 ))
  MESH_END_DHCP=$(( $MESH_START_DHCP + 30 ))

  sed "s:NET=$NET:NET=$MESH_NET"               -i  $PIRATEBOX_CONF
  sed "s:NETMASK=$NETMASK:NETMASK=255.0.0.0"   -i  $PIRATEBOX_CONF
  sed "s:IP_SHORT=$IP_SHORT:IP_SHORT=$MESH_IP" -i  $PIRATEBOX_CONF
  sed "s:START_LEASE=$START_LEASE:START_LEASE=$MESH_START_DHCP" -i  $PIRATEBOX_CONF
  sed "s:END_LEASE=$END_LEASE:END_LEASE=$MESH_END_DHCP" -i  $PIRATEBOX_CONF

  DNSMASQ_CONFG=-d  $PIRATEBOX_CONF
  DNSMASQ_CONFG=$DNSMASQ_CONFG/dnsmasq_default.conf
  sed "#dhcp-authoritative:dhcp-authoritative" -i $DNSMASQ_CONFG
fi


if [ "$2" = "disable"  ] ; then
  
  NEW_NET=192.168.77
  [ "$OPENWRT" = "yes" ] && NEW_NET=192.168.1

  sed "s:NET=$NET:NET=$NEW_NET"                   -i  $PIRATEBOX_CONF
  sed "s:NETMASK=$NETMASK:NETMASK=255.255.255.0"  -i  $PIRATEBOX_CONF
  sed "s:IP_SHORT=$IP_SHORT:IP_SHORT=1" 	  -i  $PIRATEBOX_CONF
  sed "s:START_LEASE=$START_LEASE:START_LEASE=10" -i  $PIRATEBOX_CONF
  sed "s:END_LEASE=$END_LEASE:END_LEASE=250"      -i  $PIRATEBOX_CONF

  DNSMASQ_CONFG=-d  $PIRATEBOX_CONF
  DNSMASQ_CONFG=$DNSMASQ_CONFG/dnsmasq_default.conf
  sed "dhcp-authoritative:#dhcp-authoritative" -i $DNSMASQ_CONFG

fi
