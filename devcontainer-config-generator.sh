#!/bin/bash

# Functions
Help()
{
   # Display Help
   echo "Create devcontainer.json."
   echo
   echo "Syntax: scriptTemplate [-P|h|v:version|V]"
   echo "options:"
   echo "P     For Python image."
   echo "v     Python version 3.10|3.9|3.8|3.6."
   echo "h     Print this Help."
   echo "V     Print script version and exit."
   echo
}

# Process the input options. Option are required.
if [[ ! $@ =~ ^\-.+ ]]
then
  Help
  exit;
fi

# Get the options
while getopts ":hs:w:PNV" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      s)
         SERVICE_NAME=`echo $OPTARG | tr '[:upper:]' '[:lower:]' | sed 's/ *$//g'`;;
      w)
         WORKSPACE_FOLDER=`echo $OPTARG | sed 's/ *$//g'`;;
      P)
         CONFIG_FOLDER="python"
         INITIALIZE_COMMAND_OPTIONS="-P -v <Python Version: 3.6,3.7,3.8,3.9,3.10>";;
      N)
         CONFIG_FOLDER="node"
         INITIALIZE_COMMAND_OPTIONS="-N -v <Node Version: 12,14,16>";;
      V) # Script Version
         echo "0.1.0"
         exit;;
      ?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

if [[ -z $SERVICE_NAME || -z $WORKSPACE_FOLDER ]]; 
  then 
    echo "Missing options"
    exit;
fi

BASEDIR=$(dirname "$0")
SETTINGS=`cat $BASEDIR/$CONFIG_FOLDER/settings.json`
EXTENSIONS=`cat $BASEDIR/$CONFIG_FOLDER/extensions.json`
FEATURES=`cat $BASEDIR/$CONFIG_FOLDER/features.json`

file="
{
  \"name\": \"$SERVICE_NAME\",
  \"dockerComposeFile\": [
    \"$BASEDIR/docker-compose.yml\",
  ],
  \"settings\": $SETTINGS,
  \"service\": \"$SERVICE_NAME\",
  \"extensions\": $EXTENSIONS,
  \"features\": $FEATURES,
  \"workspaceFolder\": \"/workspace/$SERVICE_NAME\",
  \"initializeCommand\": \"$BASEDIR/docker-compose.sh $INITIALIZE_COMMAND_OPTIONS -s $SERVICE_NAME -w $WORKSPACE_FOLDER\"
}
"

echo $file

echo "$file" > $WORKSPACE_FOLDER/.devcontainer.json
