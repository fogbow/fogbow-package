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
  
  
  # Setting project properties
  PROJECT_PATH=$BUILD_DIR/$PROJECT_NAME
  mkdir -p $PROJECT_PATH
  
  BUILD_VERSION="${DIST_VERSION}+dev${DATE}.git.${REV}"
  DIST_REVISION="${BUILD_VERSION}-1"
  
  SOURCE="${PACKAGE}-${BUILD_VERSION}"
  ORIG_TGZ="${PACKAGE}_${BUILD_VERSION}.orig.tar.gz"
  
  echo "Building orig.tar.gz ..."
  cd $GIT_PATH
  git archive --format=tar "--prefix=${SOURCE}/" "${REV}" | gzip >"${PROJECT_PATH}/${ORIG_TGZ}"

  cd $PROJECT_PATH
  tar xzf $ORIG_TGZ

  cd $PROJECT_PATH/$SOURCE
  cp -r $PROJECT_FOLDER/inno .
  cp -r $CURRENT_DIR/common/* ./inno
  bash ./inno/pre-build.sh
  echo "iscc /O\"$PROJECT_PATH\" /F\"$SOURCE\" \"inno/build.iss\""
  # iscc /O\"$PROJECT_PATH\" /F\"$SOURCE\" \"inno/build.iss\"
  iscc inno/build.iss

done
