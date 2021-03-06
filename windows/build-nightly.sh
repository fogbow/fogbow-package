#!/bin/bash 
set -e

DIR_NAME="$(dirname $0)"
CURRENT_DIR="$(cd $DIR_NAME; pwd)"
PROJECTS_DIR=$CURRENT_DIR/projects
BUILD_DIR=$CURRENT_DIR/build

DATE=$(date +%Y%m%d)
DATE_REPR=$(date -R)

for PROJECT_FOLDER in $PROJECTS_DIR/*; do
  
  echo "Processing project $PROJECT_FOLDER"
  source $PROJECT_FOLDER/configure
  
  if [ "$IS_ACTIVE" == "false" ]; then
    echo "Skipping $PROJECT_FOLDER. Project is not active."
    continue
  fi
  
  # Setting project properties
  PROJECT_PATH=$BUILD_DIR/$PROJECT_NAME
  mkdir -p $PROJECT_PATH

  cp -r $PROJECT_FOLDER/inno $PROJECT_PATH
  cp -r $CURRENT_DIR/common/* $PROJECT_PATH/inno
  cd $PROJECT_PATH/inno
  bash pre-build.sh
  echo "iscc /O\"$PROJECT_PATH\" /F\"$SOURCE\" \"inno/build.iss\""
  # iscc /O\"$PROJECT_PATH\" /F\"$SOURCE\" \"inno/build.iss\"
  iscc build.iss

done
