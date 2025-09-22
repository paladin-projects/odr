#!/bin/bash
# Get configuration file directly from controller without using SP
# by mcwees at hpe dot com
# started at 03.08.2020
# v 0.4 - Add showcage -all command @Tzong
# v 0.3 - Add doctype header to out file
# v 0.2 - 2>&1 redirect added
# v 0.1 - initial version

# Get config
. $HOME/.config/odr/odr.conf

commands=("controlencryption status" \
"controlrecoveryauth status" \
"servicenode status" \
"showauthparam" \
"showbattery" \
"showcim" \
"showdate" \
"showdomain -d" \
"showflashcache" \
"showhost -chap" \
"showhost -d" \
"showiscsisession" \
"showiscsisession -d" \
"showlicense" \
"shownet" \
"shownet -d" \
"shownode -d" \
"shownode -i" \
"shownode -verbose" \
"showpeer" \
"showport" \
"showport -c" \
"showport -i" \
"showport -iscsi" \
"showport -iscsiname" \
"showport -par" \
"showport -rc" \
"showport -rcip" \
"showport -sfp" \
"showport -sfp -d" \
"showport -sfp -ddm" \
"showportarp" \
"showportdev dcbx -d" \
"showportdev lldp" \
"showportisns" \
"showrcopy -d" \
"showrcopy -qw targets" \
"showsched -all" \
"showsnmpmgr" \
"showsr" \
"showsralertcrit" \
"showsys -d" \
"showsys -param" \
"showsys -space" \
"showsysmgr" \
"showsysmgr -l" \
"showtask -t 4" \
"showtoc" \
"showversion -b -a" \
"showwsapi" \
"showwsapisession" \
"showcage -d" \
"showcage -all" \
"showcage -sfp" \
"showcage -sfp -d" \
"showcage -sfp -ddm" \
"showpd" \
"showpd -c" \
"showpd -i" \
"showpd -s" \
"showcpg" \
"showcpg -d" \
"showcpg -r" \
"showcpg -s" \
"showcpg -sag" \
"showcpg -sdg" \
"showdomainset" \
"showfed" \
"showflashcache -vvset \*" \
"showhostset" \
"showld" \
"showld -d" \
"showqos" \
"showspace" \
"showspace -cpg \*" \
"showspace -p -devtype NL" \
"showtarget" \
"showtarget -lun all" \
"showtemplate" \
"showvasa" \
"showvlun" \
"showvv" \
"showvv -allkeys" \
"showvv -cpgalloc" \
"showvv -d" \
"showvv -p -prov dds" \
"showvv -pol" \
"showvv -r" \
"showvv -s" \
"showvv -showcols Name,Comment" \
"showvvcpg" \
"showvvolsc" \
"showvvolvm -sc sys:all -d" \
"showvvolvm -sc sys:all -rcopy -vv" \
"showvvset" \
"showvvset -allkeys" \
"srcpgspace -hourly -btsecs -12h" \
"srvvspace -hourly -btsecs -12h")

SN=`$CLI $CLIUSER@$1 showsys -d | grep "Serial Number" | \
	sed -e "s/^.*://" -e "s/^ *//"`
DATE="some-date"

# HTML header
echo "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">
<HTML><head>
<META http-equiv='content-type' content='text/html; charset=UTF-8'>
<TITLE>CONFIG ($SN)</TITLE>
<style type=text/css>
a {font-size: 10pt}
</style>
</head>
<body><pre><a id=top name=top></a>
<table cellpadding=0>
 <tr><td><b>StoreServ $SN Configuration file</b></td></tr>
 <tr><td><br></td></tr>
 <tr><td><b>Table Of Contents</b></td></tr>
</table>
<table cellpadding=0>
 <tr><th><u>NODE INFO</u></th>
     <th><u>CAGE INFO</u></th>
     <th><u>VOLUME INFO</u></th>
 </tr>
  <TR>
    <TD width=250><A href="#controlencryptionstatus">controlencryption status</A></TD>
    <TD width=250><A href="#showcaged">showcage -d</A></TD>
    <TD width=250><A href="#showcageall">showcage -all</A></TD>
    <TD width=250><A href="#showcpg">showcpg</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#controlrecoveryauthstatus">controlrecoveryauth status</A></TD>
    <TD width=250><A href="#showcagesfp">showcage -sfp</A></TD>
    <TD width=250><A href="#showcpgd">showcpg -d</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#servicenodestatus">servicenode status</A></TD>
    <TD width=250><A href="#showcagesfpd">showcage -sfp -d</A></TD>
    <TD width=250><A href="#showcpgr">showcpg -r</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showauthparam">showauthparam</A></TD>
    <TD width=250><A href="#showcagesfpddm">showcage -sfp -ddm</A></TD>
    <TD width=250><A href="#showcpgs">showcpg -s</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showbattery">showbattery</A></TD>
    <TD width=250><A href="#showpd">showpd</A></TD>
    <TD width=250><A href="#showcpgsag">showcpg -sag</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showcim">showcim</A></TD>
    <TD width=250><A href="#showpdc">showpd -c</A></TD>
    <TD width=250><A href="#showcpgsdg">showcpg -sdg</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showdate">showdate</A></TD>
    <TD width=250><A href="#showpdi">showpd -i</A></TD>
    <TD width=250><A href="#showdomainset">showdomainset</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showdomaind">showdomain -d</A></TD>
    <TD width=250><A href="#showpds">showpd -s</A></TD>
    <TD width=250><A href="#showfed">showfed</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showflashcache">showflashcache</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showflashcachevvset">showflashcache -vvset *</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showhostchap">showhost -chap</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showhostset">showhostset</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showhostd">showhost -d</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showld">showld</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showiscsisession">showiscsisession</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showldd">showld -d</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showiscsisessiond">showiscsisession -d</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showqos">showqos</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showlicense">showlicense</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showspace">showspace</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#shownet">shownet</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showspacecpg">showspace -cpg *</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#shownetd">shownet -d</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showspacepdevtypeNL">showspace -p -devtype NL</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#shownoded">shownode -d</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showtarget">showtarget</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#shownodei">shownode -i</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showtargetlunall">showtarget -lun all</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#shownodeverbose">shownode -verbose</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showtemplate">showtemplate</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showpeer">showpeer</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvasa">showvasa</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showport">showport</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvlun">showvlun</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportc">showport -c</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvv">showvv</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showporti">showport -i</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvallkeys">showvv -allkeys</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportiscsi">showport -iscsi</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvcpgalloc">showvv -cpgalloc</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportiscsiname">showport -iscsiname</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvd">showvv -d</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportpar">showport -par</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvpprovdds">showvv -p -prov dds</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportrc">showport -rc</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvpol">showvv -pol</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportrcip">showport -rcip</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvr">showvv -r</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportsfp">showport -sfp</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvs">showvv -s</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportsfpd">showport -sfp -d</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvshowcolsNameComment">showvv -showcols Name,Comment</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportsfpddm">showport -sfp -ddm</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvcpg">showvvcpg</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportarp">showportarp</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvolsc">showvvolsc</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportdevdcbxd">showportdev dcbx -d</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvolvmscsysalld">showvvolvm -sc sys:all -d</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportdevlldp">showportdev lldp</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvolvmscsysallrcopyvv">showvvolvm -sc sys:all -rcopy -vv</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportisns">showportisns</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvset">showvvset</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showrcopyd">showrcopy -d</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#srcpgspacehourlybtsecs12h">srcpgspace -hourly -btsecs -12h</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showrcopyqwtargets">showrcopy -qw targets</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#srvvspacehourlybtsecs12h">srvvspace -hourly -btsecs -12h</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showschedall">showsched -all</A></TD>
    <TD width=250></TD>
    <TD width=250><A href="#showvvsetallkeys">showvvset -allkeys</A></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showsnmpmgr">showsnmpmgr</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showsr">showsr</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showsralertcrit">showsralertcrit</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showsysd">showsys -d</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showsysparam">showsys -param</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showsysspace">showsys -space</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showsysmgr">showsysmgr</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showsysmgrl">showsysmgr -l</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showtaskt4">showtask -t 4</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showtoc">showtoc</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showversionba">showversion -b -a</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showwsapi">showwsapi</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showwsapisession">showwsapisession</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
  <TR>
    <TD width=250><A href="#showportdevfortargetports">showportdev for target ports</A></TD>
    <TD width=250></TD>
    <TD width=250></TD>
  </TR>
</TABLE><BR>
"


for i in ${!commands[*]}
do
	link=`echo ${commands[$i]} | sed -e "s/ //g" -e "s/-//g"`
	echo
	echo "<a href='#top'>top</a><a name=$link></a>"
	echo "   ----- ${commands[$i]} -----"
	$CLI $CLIUSER@$1 ${commands[$i]} 2>&1
done

echo "
</pre>
</body></html>
"
