# Onsite Data Recorder
Onsite Data Recorder is a suite of scripts to collect performance data and configuration from a set of devices.

# Installation
1. Create a user to run scripts.
2. Download the latest version of the script from the [GitHub repository](https://github.com/paladin-projects/odr).
3. Unpack the downloaded archive. Move the contents to the home directory of the user created in step 1.
4. Run `setup.sh` script. It will check for prerequisites, generate SSH keys and SSH config file, add crontab default entries, and prepare HTTP server configuration (Apache or Nginx/Angie).

# Setup Devices
## 3PAR/Primera/Alletra9K/AlletraMP
1. Create user with "browse" role:
```
createuser odr default service
```
2. Login as the user created in step 1.
3. Add ODR public SSH key with `setsshkey -add` command.

## Brocade switch
1. Create user with "user" role
```
userconfig --add odr -r user -d "Onsite Data Recorder"
```
Provide password when prompted.

2. Upload SSH public key to the switch.
```
sshutil importpubkey
```

# Setup ODR
1. Make sure you can connect to device with SSH using public key.
2. If user on a device is different from the one running ODR, set it in .ssh/config file.
3. Edit crontab to add ODR cron jobs.
```
crontab -e
```
Add the following lines to the end of the file:
```
# ODR cron jobs for 3PAR/Primera/Alletra9K/AlletraMP
0 */4 * * * ~/bin/getperf.sh <serial number> <ip-address>

# ODR cron jobs for Brocade switch
0 */4 * * * ~/bin/getperf-brocade.sh <serial number> <ip-address>
```
4. Place generated odr-http.conf file to HTTP server configuration directory. Reload HTTP server.
