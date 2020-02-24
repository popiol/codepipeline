#!/bin/bash

app_ver=`git branch | grep '*' | cut -d ' ' -f 2`

cd terraform/lambda

for fun in `find . -maxdepth 1 -mindepth 1 -type d | sed "s/^\.\///" | tr '\n' ' '`
do
	echo "Prepare lambda function $fun"
	rm $fun.zip
	cd $fun
	cp lib.zip ../$fun.zip
	zip ../$fun.zip *py
	cd ..
done

cd ..

echo "Set app_ver = $app_ver"

app=`grep "app=" config.tfvars | cut -d '=' -f 2 | sed "s/^\"\|\"$//g"`
sed -i "s/^app_ver=.*$/app_ver=\"${app_ver}\"/" config.tfvars
sed -i "s/^app_id=.*$/app_id=\"${app}_${app_ver}\"/" config.tfvars
sed -i "s/\"AppVer\":\"[^\"]*\"/\"AppVer\":\"${app_ver}\"/" config.tfvars

echo "Apply terraform config"

terraform apply -var-file="config.tfvars" -auto-approve

