# Create CLASH chain
iptables -t nat -N CLASH

# Bypass private IP address ranges
iptables -t nat -A CLASH -d 10.0.0.0/8 -j RETURN
iptables -t nat -A CLASH -d 127.0.0.0/8 -j RETURN
iptables -t nat -A CLASH -d 169.254.0.0/16 -j RETURN
iptables -t nat -A CLASH -d 172.16.0.0/12 -j RETURN
iptables -t nat -A CLASH -d 192.168.0.0/16 -j RETURN
iptables -t nat -A CLASH -d 224.0.0.0/4 -j RETURN
iptables -t nat -A CLASH -d 240.0.0.0/4 -j RETURN

# Redirect all TCP traffic to 8890 port, where Clash listens
iptables -t nat -A CLASH -p tcp -j REDIRECT --to-ports 9280
iptables -t nat -A PREROUTING -p tcp -j CLASH

