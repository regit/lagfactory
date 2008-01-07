#! /bin/bash
# 
# This script uses Netem (http://www.linux-foundation.org/en/Net:Netem) to simulate 
# lag and packet loss on traffic going and coming from a selected network.
#
# Copyright (C) 2008 INL
# Written by Éric Leblond <eric@inl.fr>
#            Vincent Deffontaines <vincent@inl.fr>
# INL http://www.inl.fr/
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


IFACE="eth0 eth2" # Input and output interface to simulate lag in INPUT and OUTPUT
DELAY="3000"  # delay in ms
VAR="2000"  # delay in ms
BANDWITH="200kbit" # bp of simulated link
PERCENTLOSS="2%" # Percent of packet loss
TARGET="0.0.0.0/0" # Host or network to apply lag on

if [ -n "$2" ]; then
  DELAY=$2
  echo "DELAY : $DELAY ms"
fi

if [ -n "$3" ]; then
  PERCENTLOSS="$3%"
  echo "LOSS : $PERCENTLOSS"
fi


do_start() {

for IIF in ${IFACE}; do
tc qdisc add dev ${IIF} root handle 1: prio
tc qdisc add dev ${IIF} parent 1:3 handle 30: netem \
  delay ${DELAY}ms ${VAR}ms loss ${PERCENTLOSS} 33.33%
 
tc qdisc add dev ${IIF} parent 30:1 tbf rate ${BANDWITH} buffer 1600 limit 3000

tc filter add dev ${IIF} protocol ip parent 1:0 prio 3 handle 5000 fw flowid 1:3

done;

  /sbin/iptables -A POSTROUTING -t mangle -d ${TARGET} -j MARK --set-mark 5000
  /sbin/iptables -A POSTROUTING -t mangle -s ${TARGET} -j MARK --set-mark 5000
  /sbin/iptables -A POSTROUTING -t mangle -d ${TARGET} -p tcp --dport 22 -j MARK --set-mark 0
  /sbin/iptables -A POSTROUTING -t mangle -s ${TARGET} -p tcp --sport 22 -j MARK --set-mark 0

}

do_stop() {

for IIF in ${IFACE}; do
  tc qdisc del dev ${IIF} root
done;

  /sbin/iptables -D POSTROUTING -t mangle -d ${TARGET} -j MARK --set-mark 5000
  /sbin/iptables -D POSTROUTING -t mangle -s ${TARGET} -j MARK --set-mark 5000
  /sbin/iptables -D POSTROUTING -t mangle -d ${TARGET} -p tcp --dport 22 -j MARK --set-mark 0
  /sbin/iptables -D POSTROUTING -t mangle -s ${TARGET} -p tcp --sport 22 -j MARK --set-mark 0
  
}

case "$1" in
  start)
    do_start
    ;;
  stop)
    do_stop
    ;;
  restart)
    do_stop
    do_start
    ;;
  *)
    echo "Usage : netem.sh start|stop [ \$DELAY [ \$LOSS ] ]"
    echo "  DELAY in ms, LOSS in %"
    ;;
esac
