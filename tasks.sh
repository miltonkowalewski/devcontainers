#!/bin/bash

Help()
{
   # Display Help
   echo "Replace tasks.json with devcontainer contructor ."
   echo
   echo "Syntax: scriptTemplate [path:<tasks.json path>|h]"
   echo "options:"
   echo "path     For tasks.json path."
   echo "h        Print this Help."
   echo
}

absolute_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [[ $# -gt 0 ]];
then
    key=$(echo $1 | cut -f1 -d=)
    if [[ $key == "h" || $key == "-h" ]];
    then
        Help
        exit;
    fi
    key_length=${#key}
    value="${1:$key_length+1}"
    path=$value;
else
    path=$HOME/.config/Code/User;
fi

joinByChar() {
  local IFS="$1"
  shift
  echo "$*"
}

Tasks()
{
tasks_arr=()
for ARGUMENT in "$@"
do
key=$(echo $ARGUMENT | cut -f1 -d=)
key_length=${#key}
value="${ARGUMENT:$key_length+1}"
tasks_arr+=("
        {
            \"label\": \"Create devcontainer $value\",
            \"type\": \"shell\",
            \"command\": \"$absolute_path/devcontainer-config-generator.sh\",
            \"args\": [
                \"-$key\",
                \"-s \${workspaceFolderBasename}\",
                \"-w \${workspaceFolder}\"
            ],
            \"problemMatcher\": [],
            \"group\": {
                \"kind\": \"build\"
            }
        }
")
done
joinByChar , "${tasks_arr[@]}"
}

file="{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    \"version\": \"2.0.0\",
    \"tasks\": [ `Tasks P=Python N=Node` ]
}
"

echo "$file" > $path/tasks.json
