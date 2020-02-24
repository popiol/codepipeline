#!/bin/bash

source ../config.tfvars

echo "App ID = $app_id"

for fun in `find . -maxdepth 1 -mindepth 1 -type d | sed "s/^\.\///" | tr '\n' ' '`
do
	echo "Prepare lambda function $fun"
	rm $fun.zip
	cd $fun
	cp lib.zip ../$fun.zip
	zip ../$fun.zip *py
	cd ..
	aws lambda update-function-code --function-name ${app_id}_${fun} --zip-file fileb://$fun.zip
done

