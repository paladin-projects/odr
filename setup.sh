#!/bin/bash

echo "Onsite Data Recorder Setup Utility"

echo "Checking prerequisites..."
PREREQ=(tar bzip2 find ssh ssh-keygen crontab awk sed bc logger sort uniq)
L1="            "
L2="                   "
for i in ${PREREQ[*]}; do
    P=`which $i 2>/dev/null`
    if [[ $P == *"bin"* ]]; then
        printf "%s %s %s %s %s\n" $i "${L1:${#i}}" $P "${L2:${#P}}" $S
    else
        echo "Command $i not found"
        exit 1
    fi
done

echo "Checking SSH public key..."
if [ -f "$HOME/.ssh/odr.pub" ]; then
    echo "SSH keys was found"
else
    echo "Generating SSH key..."
    ssh-keygen -q -t rsa -N '' -f ~/.ssh/odr <<<y 2>&1 >/dev/null
fi

echo "Checking SSH config..."
if [ -f "$HOME/.ssh/config" ]; then
    echo "SSH config was found"
else
    echo "Generating SSH config..."
    echo "Host *" > ~/.ssh/config
    echo "    ControlMaster auto" >> ~/.ssh/config
    echo "    ControlPath ~/.ssh/odr-%r@%h:%p" >> ~/.ssh/config
    echo "    ControlPersist yes" >> ~/.ssh/config
    echo "    IdentityFile ~/.ssh/odr" >> ~/.ssh/config
fi

echo "Check target array for SSH key registration with showsshkey command."
echo "If the key is not registered, please register it manually with setsshkey command."
echo "Use contents of ~/.ssh/odr.pub file."

echo "Checking existing crontab entries..."
CRONTAB=`crontab -l 2>/dev/null`
ret=$?
if [ $ret -eq 1 ]; then
    echo "No crontab entries found, adding ODR default entries"
    crontab odr-crontab
elif [ $ret -eq 0 && `echo "$CRONTAB" | grep -q "storecalc.sh"` ]; then
    echo "ODR crontab entries found, skipping"
fi

# Prepare Web Server configs - separate for Apache and Nginx/Angie
if [ -f "/etc/apache2/apache2.conf" ]; then
    echo "Apache web server found"
    sed -e "s|%%HOME%%|$HOME|" apache2-odr-http.conf > odr-http.conf
    echo "Configuration file for Apache web server prepared: odr-http.conf."
    echo "Edit it as needed."
    echo "Put it into /etc/apache2/sites-available/odr-http.conf and enable it with sudo a2ensite odr-http.conf"
    echo "Then restart Apache web server with systemctl restart apache2."
elif [ -f "/etc/nginx/nginx.conf" ]; then
    echo "Nginx web server found"
    sed -e "s|%%HOME%%|$HOME|" nginx-odr-http.conf > odr-http.conf
    echo "Configuration file for Nginx web server prepared: odr-http.conf."
    echo "Edit it as needed."
    echo "Put it into /etc/nginx/sites-available/odr-http.conf and enable it with sudo ln -s /etc/nginx/sites-available/odr-http.conf /etc/nginx/sites-enabled/"
    echo "Then restart Nginx web server with systemctl restart nginx."
elif [ -f "/etc/angie/angie.conf" ]; then
    echo "Angie web server found"
    # Prepare Angie configs
else
    echo "No known web servers found"
fi
