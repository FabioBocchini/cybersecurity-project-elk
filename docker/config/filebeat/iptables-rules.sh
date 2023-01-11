#!/usr/bin/env /bin/bash

# Flush preexisting rules
iptables --flush

# Log all packets
iptables -A FORWARD -j NFLOG --nflog-prefix "FORWARD: " --nflog-group 1
iptables -A INPUT -j NFLOG --nflog-prefix "INPUT: " --nflog-group 1
iptables -A OUTPUT -j NFLOG --nflog-prefix "OUTPUT: " --nflog-group 1

# Default policy
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# # Allow established inbound connections
# iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# # Allow icmp
# iptables -A INPUT -p icmp -j ACCEPT

# # Allow all loopback traffic
# iptables -A INPUT -i lo -j ACCEPT

# # Allow inbound SSH connection
# iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT

# # Allow inbound HTTPS connection
# iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
