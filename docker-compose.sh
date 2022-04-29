#!/bin/bash

# Functions
Help()
{
   # Display Help
   echo "Create docker-compose.yml file for devcontainer call."
   echo
   echo "Syntax: scriptTemplate [-P|-N|h|s:service|v:version|w:workspace|V]"
   echo "options:"
   echo "P     For Python image."
   echo "N     For Node image."
   echo "h     Print this Help."
   echo "s     Service name."
   echo "v     Python version 3.10|3.9|3.8|3.6."
   echo "w     Workspace."
   echo "V     Print script version and exit."
   echo
}

BASEDIR=$(dirname "$0")

Python() 
{
cp $BASEDIR/python/Dockerfile $WORKSPACE_FOLDER/.devcontainer
service="
  $SERVICE:
    build:
      context: .
      args:
        VARIANT: '$VARIANT'
        NODE_VERSION: 'lts/*'
    <<: *shared-variables
"
}

Node() 
{
cp $BASEDIR/node/Dockerfile $WORKSPACE_FOLDER/.devcontainer
service="
  $SERVICE:
    build:
      context: .
      args:
        VARIANT: '$VARIANT'
    <<: *shared-variables
"
}

# Process the input options. Option are required.
if [[ ! $@ =~ ^\-.+ ]]
then
  Help
  exit;
fi

# Get the options
while getopts "hv:PNs:w:V" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      v) # Enter a variant
         VARIANT=$OPTARG;;
      P)
         IMAGE="Python";;
      N)
         IMAGE="Node";;
      s)
         SERVICE=`echo $OPTARG | tr '[:upper:]' '[:lower:]'`;;
      w)
         WORKSPACE_FOLDER=$OPTARG;;
      V) # Script Version
         echo "0.1.0"
         exit;;
      ?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

if [[ -z $VARIANT || -z $IMAGE ]]; 
then 
    echo "Missing options"
    exit;
fi

case $IMAGE in
  Python)
    Python $VARIANT $SERVICE $BASEDIR $WORKSPACE_FOLDER;;
  Node)
    Node $VARIANT $SERVICE $BASEDIR $WORKSPACE_FOLDER;;
esac

file="
version: '3.4'

x-shared-variables: &shared-variables
  volumes:
    # Mount the root folder that contains .git
    - $WORKSPACE_FOLDER:/workspace/$SERVICE:cached
    - /etc/localtime:/etc/localtime:cached
    - /etc/hosts:/etc/hosts:cached
    - $HOME/.ssh/:/home/vscode/.ssh:cached
  logging:
    driver: 'json-file'
    options:
      max-size: 500M
  command: /bin/sh -c 'while sleep 1000; do :; done'

services:
  $service
"

if [ ! -d $WORKSPACE_FOLDER/.devcontainer ]; 
then
  mkdir $WORKSPACE_FOLDER/.devcontainer;
fi

echo "$file" > $WORKSPACE_FOLDER/.devcontainer/docker-compose.yml
