#!/bin/bash

###############################
##  INSTALLPKG UNINSTALLER   ##
###############################

# Author Henri Shustak
# ©2007 Lucid Information Systems Limited
# Licenced Under the GNU GPL
# http://www.lucidsystems.org

function exit_error {
    echo "Sorry an during unistall, please manually uninstall, or try again."
    exit -127
}

function exit_success {
    echo "InstallPKG Successfully Uninstalled"
    exit 0
}

clear

echo "You must be an administrator to remove the InstallPGK Software"

# Remove InstallPKG Software
sudo rm -f /sbin/installpkg
if [ $? != 0 ] ; then
    exit_error
fi

# Remove Man Page
sudo rm -f /usr/share/man/man1/installpkg.1
if [ $? != 0 ] ; then
    exit_error
fi

# Remove Receipt
sudo rm -Rf /Library/Receipts/InstallPKG.pkg
if [ $? != 0 ] ; then
    exit_error
fi

exit_success


