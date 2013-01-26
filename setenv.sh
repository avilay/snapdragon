#!/bin/bash
for line in $(cat .env)
do
	export $line
done
export APTG=avilay
echo $APTG
