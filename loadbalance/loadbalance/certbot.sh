#!/bin/bash
	clear
	printf "	
			######################
			#   SSL By Certbot   #
			######################
"
	sudo yum install epel-release -y
	sudo yum install certbot -y
	sudo systemctl stop haproxy
	echo -n "Do you have 2 Domain name(y/n): "
	read have
	if [ "$have" = 'y' ]
	then
	echo -n "Your Domain name(A Record): "
	read Record
        echo -n "Your Domain name(CName): "
        read CName
<<<<<<< HEAD
        sudo certbot certonly --standalone --preferred-challenges http --http-01-port 80 -d $CName -d $Record
=======
>>>>>>> 9d1c8267ec35f71a7d7029d79f9a59af4a93ef9e
	else
	echo -n "(A)Record OR (C)Name: "
	read OR
	
	if [ "OR" = 'A' ]
	then
        echo -n "Your Domain name(A Record): "
        read Record
<<<<<<< HEAD
	sudo certbot certonly --standalone --preferred-challenges http --http-01-port 80 -d $Record
	else
        echo -n "Your Domain name(CName): "
        read CName
	sudo certbot certonly --standalone --preferred-challenges http --http-01-port 80 -d $CName
=======
	else
        echo -n "Your Domain name(CName): "
        read CName
>>>>>>> 9d1c8267ec35f71a7d7029d79f9a59af4a93ef9e
	fi
	fi

	sleep 2
	echo "A Record: "$Record
	echo "CName: "$CName
<<<<<<< HEAD
=======
	sudo certbot certonly --standalone --preferred-challenges http --http-01-port 80 -d $CName -d $Record
>>>>>>> 9d1c8267ec35f71a7d7029d79f9a59af4a93ef9e
	sudo ls /etc/letsencrypt/live/$CName
	
	sleep 5
	sudo mkdir -p /etc/haproxy/certs
	DOMAIN=$CName sudo -E bash -c 'cat /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/letsencrypt/live/$DOMAIN/privkey.pem > /etc/haproxy/certs/$DOMAIN.pem'
	sudo chmod -R go-rwx /etc/haproxy/certs
	echo "Finish"
