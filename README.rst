=================
LagFactory script
=================

Goal
====

This bash script uses `Netem <http://www.linux-foundation.org/en/Net:Netem>`_ to simulate delay and packet loss to a given target.

Using it
========


You need first to edit parameters at the start of the script to specify the network interfaces and target ::

	 IFACE="eth0 eth2" # Input and output interface to simulate lag in INPUT and OUTPUT
	 TARGET="192.168.1.0/24" # Host or network to apply lag on


Then, you will simply need to run as root something like ::

	 lagfactory.sh start 4000 2
	  DELAY : 4000 ms
	  LOSS : 2%
 
This will simulate a delay of 4 sec (plus or minus 2 sec) for all packets going to ''192.168.1.0/24'' via ''eth0'' and coming back from ''192.168.1.0/24'' via ''eth2''. There is also a 2 percent packet loss on these packets.


To ease administrator work, SSH trafic is not affected by this modification of network property.
