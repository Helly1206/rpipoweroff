#!/bin/bash
NAME="rpipoweroff"
OPTDIR="/opt"
OPTLOC="$OPTDIR/$NAME"
DEBFOLDER="debian"
ETCDIR="/etc"
ETCLOC=$ETCDIR
SERVICEDIR="$ETCDIR/systemd/system"
SERVICESCRIPT="$NAME.service"
INSTALL="/usr/bin/install -c"
INSTALL_DATA="$INSTALL -m 644"

if [ "$EUID" -ne 0 ]
then
	echo "Please execute as root ('sudo install.sh' or 'sudo make install')"
	exit
fi

if [ "$1" == "-u" ] || [ "$1" == "-U" ]
then
	echo "$NAME uninstall script"
	
	echo "Uninstalling daemon $NAME"
	systemctl stop "$SERVICESCRIPT"
	systemctl disable "$SERVICESCRIPT"
	if [ -e "$SERVICEDIR/$SERVICESCRIPT" ]; then rm -f "$SERVICEDIR/$SERVICESCRIPT"; fi

    echo "Removing files"
    if [ -d "$OPTLOC" ]; then
        rm -rf "$OPTLOC"
    fi

elif [ "$1" == "-h" ] || [ "$1" == "-H" ]
then
	echo "Usage:"
	echo "  <no argument>: install $NAME"
	echo "  -u/ -U       : uninstall $NAME"
	echo "  -h/ -H       : this help file"
	echo "  -d/ -D       : build debian package"
	echo "  -c/ -C       : Cleanup compiled files in install folder"
elif [ "$1" == "-c" ] || [ "$1" == "-C" ]
then
	echo "$NAME Deleting compiled files in install folder"
	rm -f ./*.deb
	rm -rf "$DEBFOLDER"/$NAME
	rm -rf "$DEBFOLDER"/.debhelper
	rm -f "$DEBFOLDER"/files
	rm -f "$DEBFOLDER"/files.new
	rm -f "$DEBFOLDER"/$NAME.*
elif [ "$1" == "-d" ] || [ "$1" == "-D" ]
then
	echo "$NAME build debian package"
	fakeroot debian/rules clean binary
	mv ../*.deb .
else
	echo "$NAME install script"
	
    if [ ! -d "$OPTLOC" ]; then
        mkdir "$OPTLOC"
    fi
    cp -r ".$OPTLOC/." "$OPTLOC/"
    
    echo "Installing daemon $NAME"
	read -p "Do you want to install an automatic startup service for $NAME (Y/n)? " -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Nn]$ ]]
	then
		echo "Skipping install automatic startup service for $NAME"
	else
		echo "Install automatic startup service for $NAME"
		$INSTALL_DATA ".$SERVICEDIR/$SERVICESCRIPT" "$SERVICEDIR/$SERVICESCRIPT"

		systemctl enable $SERVICESCRIPT
		systemctl start $SERVICESCRIPT
	fi
fi
