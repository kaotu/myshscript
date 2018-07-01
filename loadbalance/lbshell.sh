!#/bin/bash

	clear
	printf "    
			####################
        	        #    loadBalance   #
                	####################
"                  
	echo  -n "Enter IP DNS Name1: "
	read Name1
	cat >> /etc/hosts <<EOF
           $Name1
	EOF

	echo  -n "Enter IP DNS Name2: "
	read Name2
	cat >> /etc/hosts <<EOF
	   $Name2
	EOF
	echo "nginx1 hostname: $Name1"
	echo "nginx2 hostname: $Name2"	
	
	sleep 10

	sudo yum -y install haproxy
	cd /etc/haproxy/
	sudo mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
	cd
	sudo mv haproxy.cfg /etc/haproxy/

	sleep 5
	
	echo -n "Enter IP server1: "
	read server1
	cat >> /etc/haproxy/haproxy.cfg <<EOF
	backend app-main
    		balance roundrobin                                     #Balance algorithm
    		option httpchk HEAD / HTTP/1.1\r\nHost:\ localhost    #Check the server app$
    		server nginx1 $server1:80 check                 	#Nginx1
	EOF

	echo  -n "Enter IP server2: "
	read server2
	cat >> /etc/haproxy/haproxy.cfg <<EOF
    		server nginx2 $server2:80 check                 	#Nginx2
	EOF	
	echo "server1 is: $server1"
        echo "server2 is: $server2"
	
	sleep 10

	sudo mv /etc/rsyslog.conf /etc/rsyslog.conf.org
	sudo cp rsyslog.conf /etc/rsyslog.conf
        echo -n "Do you want to use a specific IP?(y/n)"
        if [ "$IP = 'y' ]
        then
        
	sleep 5
        echo "Enter specific IP:"
        read IP
        cat >> /etc/rsyslog.conf <<EOF
        $UDPServerAddress $IP
        EOF
	fi

	sudo cat > /etc/rsyslog.d/haproxt.conf <<EOF
	local2.=info     /var/log/haproxy-access.log    #For Access Log
	local2.notice    /var/log/haproxy-info.log      #For Service Info - Backend, loadbalancer 
	EOF
	
	sleep 5

	sudo systemctl restart rsyslog
	sudo systemctl start haproxy
	sudo systemctl enable haproxy
