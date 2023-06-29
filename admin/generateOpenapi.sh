#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "usage: $0 inputFile"
  exit 1
fi

if [ -d "./src/openapi" ]; then 
  rm -rf "./src/openapi"
fi 

mkdir "./src/openapi"

openapi-generator-cli generate -i "$1" -g typescript-angular -o './src/openapi' -p ngVersion=15.0.1 -p stringEnums=true
