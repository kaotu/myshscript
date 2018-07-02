!#/bin/bash

	clear
	printf "    
			####################
        	        #    loadBalance   #
                	####################
"                  
	echo -n "Enter IP DNS Name1: "
	read Name1
	cat >> /etc/hosts <<-EOF
	$Name1	
	EOF

	echo  -n "Enter IP DNS Name2: "
	read Name2
	cat >> /etc/hosts <<-EOF
	$Name2
	EOF
	echo
	echo "nginx1 hostname: $Name1"
	echo "nginx2 hostname: $Name2"
		
	echo "Installing haproxy..."	
	sleep 5	

	sudo yum -y install haproxy
	sudo mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
	sudo cp haproxy_SSL.cfg /etc/haproxy/

	sleep 5
	echo -n "Enter IP server1: "
        read server1
        echo  -n "Enter IP server2: "
        read server2
	echo -n "Enter your Site: "
	read Site
        sudo cat >> /etc/haproxy/haproxy_SSL.cfg <<-EOF
	frontend www-https
   	    bind *:443 ssl crt /etc/haproxy/certs/$Site.pem
   	    reqadd X-Forwarded-Proto:\ https
   	    acl letsencrypt-acl path_beg /.well-known/acme-challenge/
   	    use_backend letsencrypt-backend if letsencrypt-acl
   	    default_backend www-backend

	#---------------------------------------------------------------------
	# BackEnd roundrobin as balance algorithm
	#---------------------------------------------------------------------
        	backend app-main
             	balance roundrobin                                     #Balance algorithm
             	option httpchk HEAD / HTTP/1.1\r\nHost:\ localhost    #Check the server app
             	server nginx1 $server1:80 check                         #Nginx1
             	server nginx2 $server2:80 check                         #Nginx2
	#SSL
	backend www-backend
		redirect scheme https if !{ ssl_fc }
   		server nginx1 $server1:80 check
   		server nginx2 $server2:80 check

	backend letsencrypt-backend
   		server letsencrypt 127.0.0.1:54321
	EOF
	
	echo "server1 is: $server1"
        echo "server2 is: $server2"

	sleep 5
	
	echo "rsyslog.conf"
        sudo mv /etc/rsyslog.conf /etc/rsyslog.conf.org
        sudo cp rsyslog.conf /etc/
        echo -n "Do you want to use a specific IP?(y/n): "
        read use
        if [ "$use" = 'y' ]
        then
        echo -n "Enter specific IP: "
        read IP
        sudo echo '$'UDPServerAddress $IP  >> /etc/rsyslog.conf
        fi

        sudo cat >> /etc/rsyslog.d/haproxy.conf <<-EOF
	local2.=info     /var/log/haproxy-access.log    #For Access Log
	local2.notice    /var/log/haproxy-info.log      #For Service Info - Backend, loadbalancer
	EOF
	
	sleep 3

	sudo systemctl restart rsyslog
	sudo systemctl start haproxy
	sudo systemctl enable haproxy
	echo "Finish"
