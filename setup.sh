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

echo "Checking for configuration file..."
if [ ! -d "$HOME/.config/odr"]; then
        mkdir -p $HOME/.config/odr
fi
if [ -f "$HOME/.config/odr/odr.conf"]; then
        echo "Configuration file exists. Please, check ~/.config/odr/odr.conf contents and apply changes as needed"
else
        cp ./odr.conf $HOME/.config/odr
        echo "Default configuration file copied to ~/.config/odr/odr.conf. Please, check its contents and apply changes as needed"
fi

echo "Checking SSH public key..."
if [ -f "$HOME/.ssh/odr.pub" ]; then
    echo "SSH keys was found"
else
    echo "Generating SSH key..."
    ssh-keygen -q -t rsa -N '' -f ~/.ssh/odr <<<y 2>&1 >/dev/null
fi

echo "Checking SSH config..."
if [ -f "$HOME/.ssh/config" ]; then
    echo "SSH config was found. Please, check ~/.ssh/config file and apply changes as needed"
else
    echo "Generating SSH config..."
    echo "Host *" > ~/.ssh/config
    echo "    ControlMaster auto" >> ~/.ssh/config
    echo "    ControlPath ~/.ssh/odr-%r@%h:%p" >> ~/.ssh/config
    echo "    ControlPersist yes" >> ~/.ssh/config
    echo "    IdentityFile ~/.ssh/odr" >> ~/.ssh/config
fi

echo "Check target 3PAR/Primera/Alletra9K/AlletraMP array for SSH public key registration with 'showsshkey' command."
echo "If the key is not registered, please register it manually with 'setsshkey' command."
echo "Use contents of ~/.ssh/odr.pub file."

echo "For Brocade switch check that SSH public key is imported with 'sshutil showpubkeys' command."
echo "If the key is not registered, please, import the key with 'sshutil importpubkey' command."
echo "Use contents of ~/.ssh/odr.pub file."

echo "Checking bin directory..."
if [ ! -d ~/.local/bin ]; then
	echo "Creating ~/.local/bin"
	mkdir -p ~/.local/bin
else
	echo "Using ~/.local/bin"
fi

echo "Checking scripts..."
for i in `ls -1 ./bin` ; do
	ii=`which $i`
	ret=$?
	if [ $ret -eq 0 -a -n $ii ]; then
		cmp -s $i $ii
		ret=$?
	fi
	if [ $ret -eq 1 ]; then
		echo "Copying $i to ~/.local/bin"
		cp $i ~/.local/bin
	fi
done

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
    echo "Then restart Apache web server with 'systemctl restart apache2'."
elif [ -f "/etc/nginx/nginx.conf" -o -f "/etc/angie/angie.conf"]; then
    echo "Nginx/Angie web server found"
    sed -e "s|%%HOME%%|$HOME|" nginx-odr-http.conf > odr-http.conf
    echo "Configuration file for Nginx/Angie web server prepared: odr-http.conf."
    echo "Edit it as needed."
    echo "Put it into /etc/nginx/sites-available/odr-http.conf (for Nginx) or /etc/angie/sites-available/odr-http.conf (for Angie)"
	echo "Enable site with 'ln -s /etc/nginx/sites-available/odr-http.conf /etc/nginx/sites-enabled/' (Nginx) or 'ln -s /etc/angie/sites-available/odr-http.conf /etc/angie/sites-enabled/'"
    echo "Then restart Nginx/Angie web server with 'systemctl restart nginx' or 'systemctl restart angie'."
else
    echo "No known web servers found. Prepare site configuration manually"
fi
