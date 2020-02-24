#!/bin/bash

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

echo "Apply terraform config"

terraform apply -var-file="config.tfvars" -auto-approve

