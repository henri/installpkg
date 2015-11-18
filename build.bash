#!/bin/bash

# Script to build OS X package install from installpkg core source code
#
# Copyright (C)2011 - Henri Shustak
# Released under the GUN GPL v3 or later
# Lucid Information Systems
# http://www.lucidsystems.org
#
# v1.1 : initial release
#


# establish some varibles
package_version="${1}"
parent_directory=`dirname "${0}"`
parent_direcotry_uid=`ls -nld "${parent_directory}" | awk '{print $3}'`
input_package="${parent_directory}/InstallPKG.pkg"
tmp_working_directory=`mktemp -d /tmp/build_installpkg_XXXXXXXX`
tmp_installpkg_build_dir="${tmp_working_directory}/installpkg"
disk_image_src_dir="${tmp_installpkg_build_dir}"
output_package="${tmp_installpkg_build_dir}/InstallPKG.pkg"
make_file_template_for_package_building="${parent_directory}/Makefile_template"
make_file_for_package_building="${parent_directory}/Makefile"
output_diskimage_name="installpkg"
output_diskimage_path="${parent_directory}/builds/${output_diskimage_name}_v${package_version}.dmg"
realitive_output_diskimage_path="./builds/${output_diskimage_name}_v${package_version}.dmg"
clean_up_pkg_file="YES"
export exit_value=0

# list of additional files to copy to the disk image
additional_files_to_include_within_diskimage=( "InstallPKG-Uninstall.bash" "extras" )

# functions
function clean_exit {
    rm -rf "${tmp_working_directory}"
    rm -f "${make_file_for_package_building}"
    if [ -e "${input_package}" ] && [ "${clean_up_pkg_file}" == "YES" ] ; then
        rm -rf "${input_package}"
    fi
    exit ${exit_value}
}

# perform some basic checks
# -------------------------

if [ "$1" == "" ] ; then
        echo "Usage : build.bash <build_version_number>"
        echo "        eg. : ./build.bash 0.0.9"
        exit -1
fi

# check we are running as root
current_user=`whoami`
if [ "${current_user}" != "root" ] ; then
    echo "Luggage requires superuser privileges to build the package."
    echo "Please run this script as root."
    export exit_value=-1
    clean_exit
fi

# check that luggage (maybe installed) - must be a better approach
if ! [ -d /usr/local/share/luggage ] ; then
    echo "This script requires that you have luggage installed on your system."
    echo "Download luggage from : https://github.com/unixorn/luggage"
    echo "For more information : http://luggage.apesseekingknowledge.net"
    export exit_value=-1
    clean_exit
fi

# prepare to build the package the package
cd "${parent_directory}"
if [ $? != 0 ] ; then
    echo "  ERROR : Unable to change working directory to the parent directory of this script."
    echo "          Build has been canceled."
    export exit_value=-1
    clean_exit
fi

# if a previous package build exits (from previous run) then remove this
if [ -e "${input_package}" ] ; then 
    rm -R "${input_package}"
    if [ $? != 0 ] ; then
        echo ""
        echo "    ERROR! : Failed during removal of previous package."
        echo ""
        export exit_value=-1
        clean_exit
    fi
fi

# perform check incase an existing disk image already exists.
if [ -e "${output_diskimage_path}" ] ; then
        echo ""
        echo -n "Overwrite exiting disk image? [y/N] : "
        read instructions
        if [ "${instructions}" != "y" ] && [ "${instructions}" != "yes" ] && [ "${instructions}" != "YES" ] ; then
                echo "Disk image creation aborted."
                export exit_value=-1
                clean_exit
        fi
        echo -n "Removing exiting disk image..."
        rm $output_diskimage_path
        if [ $? != 0 ] ; then 
            echo "    ERROR!: Unable to remove the old disk image!"
            export exit_value=-1
            clean_exit
        fi
        echo "done."
        echo ""
fi

# remove any exisiting make file....
if [ -f "${make_file_for_package_building}" ] ; then 
    rm "${make_file_for_package_building}"
    if [ $? != 0 ] ; then 
        echo "   ERROR! : Unable to remove package make file (do not worry template is not being removed)"
        export exit_value=-1
        clean_exit
    fi
fi

# create the make file from the template
sed s/XXXXXXXXX/${package_version}/g "${make_file_template_for_package_building}" > "${make_file_for_package_building}"
if [ $? != 0 ] ; then 
    echo "    ERROR!: InstallPGK setting version in make file failed!"
    export exit_value=-1
    clean_exit
fi

# make the package (using the luggage)
# -------------------------
make pkg
if [ $? != 0 ] ; then
    echo ""
    echo "    ERROR! : Failed during new package creation."
    echo ""
    export exit_value=-1
    clean_exit
fi

echo ""
echo "---------------------------------------------------------------------------------------"
echo " Package for InstallPKG was successfully created from the InstallPKG core source code. "
echo "---------------------------------------------------------------------------------------"
echo ""


# prepare for disk image building
# --------------------------------

# allow anyone to look inside the tempoary building directory.
chmod 755 "${tmp_working_directory}"

# generate the dmg output directory
mkdir -p "${tmp_installpkg_build_dir}"
if [ $? != 0 ] ; then 
    echo "    ERROR!: Unable to generate the dmg output directory!"
    export exit_value=-1
    clean_exit
fi

# copy the package from the build directory into the output directory
echo "Copying package...."
cp -r "${input_package}" "${output_package}"
if [ $? != 0 ] ; then 
    echo "    ERROR!: Unable to copy the install package to the dmg build directory!"
    export exit_value=-1
    clean_exit
fi

echo "Coping extras...."
# copy each items listed in the settings from the install_components directory
for to_copy in "${additional_files_to_include_within_diskimage[@]}" ; do
    cp -r "${parent_directory}/install_components/${to_copy}" "${tmp_installpkg_build_dir}/"
    if [ $? != 0 ] ; then 
        echo "    ERROR!: Unable to copy the additional component \" ${to_copy} \" to the dmg build directory!"
        export exit_value=-1
        clean_exit
    fi
done

# generate disk image from the temporary build directory
echo -n "Building disk image"
hdiutil create -srcfolder "${disk_image_src_dir}" -fs HFS+ -volname installpkg -uid 99 -gid 99 -mode 755 -partitionType Apple_HFS -format UDZO -copyuid root "${output_diskimage_path}"
return_value=$?
if [ $return_value -ne 0 ] ; then
        echo "ERROR! : Creating disk image!"
        echo ""
        exit $retrun_value
fi

# set the owner for this disk image to be the same as the parent directory
chown ${parent_direcotry_uid} "${output_diskimage_path}"
if [ $? != 0 ] ; then 
    echo "    ERROR!: Unable to set the ownership of the output .dmg"
    export exit_value=-1
    clean_exit
fi

# generate latest version link
rm -f ./installpkg_latest.dmg
ln -s "${realitive_output_diskimage_path}" ./installpkg_latest.dmg 
if [ $? != 0 ] ; then 
    echo "    ERROR!: while generating latest version link"
    export exit_value=-1
    clean_exit
fi

echo ""
echo "---------------------------------------------------------------------------------------"
echo " Output image \"installpkg_v${package_version}.dmg\" is ready for collection from the builds direcotry "
echo "---------------------------------------------------------------------------------------"
echo ""


# exit cleanly
# --------------------------------
export exit_value=0
clean_exit


