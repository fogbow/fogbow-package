#!/bin/bash 
set -e

# Global nightly building script for OurGrid projects
# Iterates over all the project in the projects folder, 
# checks if there is new commit for it github that was not built yet
# and builds it. 

DIR_NAME="$(dirname $0)"
CURRENT_DIR="$(cd $DIR_NAME; pwd)"
PROJECTS_DIR=$CURRENT_DIR/projects
BUILD_DIR="$(cd $(dirname .); pwd)"

DATE=$(date +%Y%m%d)
DATE_REPR=$(date -R)

DOWNLOAD_ROOT=/tmp/build

# Save previous build info
# echo "$REV" > $BUILD_DIR/prev.rev

PROJECT_FOLDER=$PROJECTS_DIR/$1

echo "Processing project $PROJECT_FOLDER"
source $PROJECT_FOLDER/configure

if [ "$IS_ACTIVE" == "false" ]; then
  echo "Skipping $PROJECT_FOLDER. Project is not active."
  exit
fi

# Setting project properties
PROJECT_PATH=$BUILD_DIR
GIT_PATH=$PROJECT_PATH/git

# Updating git folder
if [ -d "$GIT_PATH" ]; then
  cd $GIT_PATH
  git pull
  cd $PROJECT_PATH
else
  git clone $GIT_URL $GIT_PATH
fi

cd $GIT_PATH
REV="$(git log -1 --pretty=format:%h)"
 
BUILD_VERSION="${DIST_VERSION}+dev${DATE}.git.${REV}"
DIST_REVISION="${BUILD_VERSION}-1"
 
SOURCE="${PACKAGE}-${BUILD_VERSION}"  
ORIG_TGZ="${PACKAGE}_${BUILD_VERSION}.orig.tar.gz"
  
if [ -a "$PROJECT_PATH/$ORIG_TGZ" ]; then
  echo "Skipping $PROJECT_FOLDER. Package is already in its latest version."
  break
fi

echo "Building orig.tar.gz ..."
cd $GIT_PATH
git archive --format=tar "--prefix=${SOURCE}/" "${REV}" | gzip >"${PROJECT_PATH}/${ORIG_TGZ}"

cd $PROJECT_PATH
tar xzf $ORIG_TGZ
  
cd $PROJECT_PATH/$SOURCE
rsync -a $PROJECT_FOLDER/debian .

cd $GIT_PATH
CHANGELOG="$(git log $REV --pretty=format:'[ %an ]%n>%s' | $CURRENT_DIR/gitcl2deb.sh)"
  
echo -e "${PACKAGE} (${DIST_REVISION}) ${DIST}; urgency=low\n\n\
${CHANGELOG}\n\n\
 -- ${DEBFULLNAME} <${DEBEMAIL}>  ${DATE_REPR}\n"\
  > $PROJECT_PATH/$SOURCE/debian/changelog

cd $PROJECT_PATH/$SOURCE
# Building debian package
if [ "${BUILD_ARCH}" == "all" ]; then
  debuild
else
  IFS=',' read -ra ARCHS <<< "${BUILD_ARCH}"
  for ARCH in "${ARCHS[@]}"; do
    debuild -a${ARCH} || true
  done
fi 
