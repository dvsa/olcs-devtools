#!/bin/bash

if [ -f "composer.json" ]; then
	if [ -d ./vendor/olcs ]; then
		# iterate each vendor/olcs* symlink, and remove alos if a .bak exists then restore it
		for line in $(find ./vendor/olcs -type l); do
			echo "Remove symlink: $line"
			rm "$line"
			if [ -d $line.bak ]; then
				mv $line.bak $line
			fi
		done
	fi

	if [ -f composer.phar ]; then
		php composer.phar update
	else
		composer update
	fi

	if [ -d ./vendor/olcs ]; then
		# iterate each vendor/olcs* directory, if a directory exists in parent with same name, then .bak it and symlink it
		for line in $(find ./vendor/olcs -maxdepth 1 -mindepth 1 -type d); do
			dirname=$(basename $line)
			if [ "$dirname" == "OlcsCommon" ]; then
				dirname="olcs-common"
			fi

			if [ -d ../$dirname ]; then
				echo "Create symlink: $line"
				mv $line $line.bak
				ln -s ../../../$dirname $line
			fi
		done
	fi
else
	echo "No composer.json found!!!"
fi