#!/bin/bash
# using work from http://blog.justin.kelly.org.au/nginx-domain-setup-script/
# Info
# ---
# script can run with the domain as a command line input
# `sudo ./nginx_domain.sh my_domain.com` or without and
# the script will prompt the user for input

#config
if [ -a confix.sh ]
    then
        . confix.sh
else
    . config_default.sh
fi

if [ -z "$1" ]
then

        #user input
        echo -e "Enter domain name:"
        read DOMAIN
        echo "Creating Nginx domain settings for: $DOMAIN"

        if [ -z "$DOMAIN" ]
        then
                echo "Domain required"
                exit 1
        fi
fi

if [ -z "$DOMAIN" ]
then
        DOMAIN=$1
fi

(
cat <<EOF
server {
        listen 80;
        server_name $DOMAIN www.$DOMAIN api.$DOMAIN admin.$DOMAIN;
        root $web_root/$DOMAIN/public;
        index  index.php index.html index.htm;
        access_log $web_root/$DOMAIN/log/access_log.txt;
        error_log $web_root/$DOMAIN/log/error_log.txt error;

        location / {
           try_files $uri $uri/ @rewrite;
        }
        location @rewrite {
            rewrite ^(.*)$ /index.php;
        }
        location ~ /\.ht {
                deny all;
        }
       include php.conf;
}
EOF
) >  $config_dir/sites-available/$DOMAIN.conf

echo "Making web directories"
mkdir -p $web_root/"$DOMAIN"
mkdir -p $web_root/"$DOMAIN"/{public,private,log,backup}
ln -s $config_dir/sites-available/"$DOMAIN".conf $config_dir/sites-enabled/"$DOMAIN".conf
/etc/init.d/nginx reload
echo "Nginx - reload"
chown -R www-data:www-data $web_root/"$DOMAIN"
chmod 755 $web_root/"$DOMAIN"/public
echo "Permissions have been set"
echo "$DOMAIN has been setup"