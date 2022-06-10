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

CONFIGS=()

# Get the options
while getopts ":hs:w:v:PNV" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      s)
         SERVICE_NAME=`echo $OPTARG | tr '[:upper:]' '[:lower:]' | sed 's/ *$//g'`;;
      w)
         WORKSPACE_FOLDER=`echo $OPTARG | sed 's/ *$//g'`;;
      v)
         VERSION=`echo -v $OPTARG`;;
      P)
         CONFIG_FOLDER="python"
         CONFIGS+=("\"remoteUser\": \"vscode\",")
         DEFAULT_VERSIONS="-v <Python Version: 3.6,3.7,3.8,3.9,3.10>"
         INITIALIZE_COMMAND_OPTIONS="-P";;
      N)
         CONFIG_FOLDER="node"
         CONFIGS+=("\"remoteUser\": \"node\",")
         DEFAULT_VERSIONS="-v <Node Version: 12,14,16>"
         INITIALIZE_COMMAND_OPTIONS="-N";;
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

if [[ -z $VERSION ]];
then
   INITIALIZE_COMMAND_OPTIONS+=" $DEFAULT_VERSIONS"
else
   INITIALIZE_COMMAND_OPTIONS+=" $VERSION"
fi

BASEDIR=$(dirname "$0")
SETTINGS=`cat $BASEDIR/$CONFIG_FOLDER/settings.json`
EXTENSIONS=`cat $BASEDIR/$CONFIG_FOLDER/extensions.json`
FEATURES=`cat $BASEDIR/$CONFIG_FOLDER/features.json`

file="
{
   \"name\": \"$SERVICE_NAME\",
   \"dockerComposeFile\": [
      \"docker-compose.yml\",
   ],
   \"settings\": $SETTINGS,
   \"service\": \"$SERVICE_NAME\",
   \"extensions\": $EXTENSIONS,
   \"features\": $FEATURES,
   \"workspaceFolder\": \"/workspace/$SERVICE_NAME\",
   ${CONFIGS[@]}
}
"

echo $file

if [ ! -d $WORKSPACE_FOLDER/.devcontainer ]; 
then
   echo "Create folder"
   mkdir $WORKSPACE_FOLDER/.devcontainer;
else
   echo "Backup folder"
   mv $WORKSPACE_FOLDER/.devcontainer $WORKSPACE_FOLDER/.devcontainer.`date +"%Y-%m-%d_%I:%M:%S"`.bkp;
   mkdir $WORKSPACE_FOLDER/.devcontainer;
fi

bash $BASEDIR/docker-compose.sh $INITIALIZE_COMMAND_OPTIONS -s $SERVICE_NAME -w $WORKSPACE_FOLDER
echo "$file" > $WORKSPACE_FOLDER/.devcontainer/devcontainer.json
