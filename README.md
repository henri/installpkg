#  InstallPKG  #

[![download](http://lucidsystems.tk/images/multi/download.png)](http://www.lucid.systems/download/installpkg) [![download](http://lucidsystems.tk/images/multi/apple_package.png)](http://www.lucid.systems/download/installpkg)

Download the latest version (a compiled package installer) via the following URL : 
http://www.lucid.systems/download/installpkg

InstallPKG is a wrapper to the 'installer' tool on Mac OS X systems. The functionality is focused on allowing you to quickly and easily install multiple packages to the current boot drive.  InstallPKG is released under the [GNU GPL licence][8].

Usage Examples
--------------
Full usage information and usage examples are available once installed by typing : 

    man installpkg

Basic usage example to install all .pkg and .mpkg files found within a specific directory :

    installpkg /path/to/directory/of/packages/*

Copies the "printers.dmg" from the volume called "usb", ejects the volume and then installs of all .mpkg and .pkg which are on the root level of the disk image volume :

    installpkg -hice /Volumes/usb/printers.dmg

Download the printers.pkg from the specified URL and then commence with installation of that package.

    installpkg -u installpkg http://example.com/installers/printers.pkg

Dependinceies
-------------
A typical Mac OS X installation will have the dependinces. The exception to this rule is wget which is required with the -u flag. Support for the -u "install from URL" flag is provided by wget. If you do not have wget installed on your system and you would rather not install the developer tools, then [download wget for OS X as a package][3]. It is possible to install wget in a number of ways. A handful of installation approaches for wget on OS X are listed below :
 * [rudix (pre-built wget binary with install package for OS X)][3] (installation path : /usr/local/bin/wget)
 * [homebrew][2]
 * [macports][1]
 * [pkgsrc][7]

Upgrade
---------
Once installed (along with wget), you can use installpkg to update installpkg with the following command : 

    installpkg -iuh http://lucid.systems/download/installpkg

If you would prefer to not install wget on your system then download the latest version manually and then run the InstallPKG again to update to the latest version.
Should you be using InstallPKG within your own installer(s) then download the latest version and then replace your older InstallPKG.pkg with the new InstallPKG.pkg.

Rootless Mode 
-------------------
OS 10.11 (El Capitan) rootless note. Version 0.2.0 of installpkg is the first version which is compatible with 10.11 systems which have rootless mode enabled. 
  * [Additional details regrding rootless mode on Mac OS 10.11][6]


Building InstallPKG from source
-----------------------------------
Use this GitHub project to build (requires [luggage][4]) the OS X package installer for InstallPKG or [download][5] the .dmg file which is also available from github. Pull requests to add useful features or bug fixes are welcome.


Contributing
------------
Comments and suggestions regarding the InstallPKG project are very welcome. 

If you have an new feature or bug fix, fork the project create a new branch and then issue a pull request via GitHub.


  [1]: https://www.macports.org
  [2]: http://brew.sh
  [3]: http://rudix.org/packages/wget.html
  [4]: https://github.com/unixorn/luggage
  [5]: http://www.lucid.systems/download/installpkg
  [6]: https://georgegarside.com/blog/osx/package-incompatible-installer/
  [7]: https://pkgsrc.joyent.com/install-on-osx/
  [8]: https://www.gnu.org/copyleft/gpl-3.0.html
  
  
