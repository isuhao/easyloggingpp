#!/bin/bash

# Bash script that helps with releasing new versions of EasyLogging++
# Revision: 1.3
# @author mkhan3189
#
# Usage:
#        ./release.sh [repo-root] [homepage-repo-root] [curr-version] [new-version] [do-not-ask]

if [ "$1" = "" ];then
  echo
  echo "Usage: $0 [repository-root] [homepage-root] [curr-version] [new-version] [do-not-ask]"
  echo
  exit 1
fi

if [ -f "$1/tools/release.sh" ];then
  [ -d "$2/releases/" ] || mkdir $2/releases/
else
  echo "Invalid repository root"
  exit 1
fi

CURR_VERSION=$3
CURR_RELEASE_DATE=$(grep -o '[0-9][0-9]-[0-9][0-9]-201[2-9] [0-9][0-9][0-9][0-9]hrs' $1/src/easylogging++.cc)
NEW_RELEASE_DATE=$(date +"%d-%m-%Y %H%Mhrs")
NEW_VERSION=$4
DO_NOT_CONFIRM=$5
if [ "$NEW_VERSION" = "" ]; then
  echo 'Current Version  ' $CURR_VERSION
  echo '** No version provided **'
  exit
fi

echo 'Current Version  ' $CURR_VERSION ' (' $CURR_RELEASE_DATE ')'
echo 'New Version      ' $NEW_VERSION  ' (' $NEW_RELEASE_DATE ')'
if [ "$DO_NOT_CONFIRM" = "y" ]; then
  confirm="y"
else
  echo "Are you sure you wish to release new version [$CURR_VERSION -> $NEW_VERSION]? (y/n)"
  read confirm
fi

if [ "$confirm" = "y" ]; then
  sed -i '' -e "s/Easylogging++ v$CURR_VERSION*/Easylogging++ v$NEW_VERSION/g" $1/src/easylogging++.h
  sed -i '' -e "s/Easylogging++ v$CURR_VERSION*/Easylogging++ v$NEW_VERSION/g" $1/src/easylogging++.cc
  sed -i '' -e "s/Easylogging++ v$CURR_VERSION*/Easylogging++ v$NEW_VERSION/g" $1/README.md
  sed -i '' -e "s/return std::string(\"$CURR_VERSION\");/return std\:\:string(\"$NEW_VERSION\");/g" $1/src/easylogging++.cc
  sed -i '' -e "s/return std::string(\"$CURR_RELEASE_DATE\");/return std\:\:string(\"$NEW_RELEASE_DATE\");/g" $1/src/easylogging++.cc
  astyle $1/src/easylogging++.h --style=google --indent=spaces=2 --max-code-length=120
  astyle $1/src/easylogging++.cc --style=google --indent=spaces=2 --max-code-length=120
  if [ -f "$1/src/easylogging++.h.orig" ];then
    rm $1/src/easylogging++.h.orig
  fi
  if [ -f "$1/src/easylogging++.cc.orig" ];then
    rm $1/src/easylogging++.cc.orig
  fi
  sed -i '' -e "s/\$currentVersion = \"$CURR_VERSION\"*/\$currentVersion = \"$NEW_VERSION\"/g" $2/version.php
  sed -i '' -e "s/\$releaseDate = \"$CURR_RELEASE_DATE\"*/\$releaseDate = \"$NEW_RELEASE_DATE\"/g" $2/version.php
  sed -i '' -e "s/$CURR_RELEASE_DATE/$NEW_RELEASE_DATE/g" $2/version.php
  sed -i '' -e "s/v$CURR_VERSION/v$NEW_VERSION/g" $1/README.md
  sed -i '' -e "s/Easylogging++ v$CURR_VERSION/Easylogging++ v$NEW_VERSION/g" $1/doc/RELEASE-NOTES-v$NEW_VERSION
  sed -i '' -e "s/easyloggingpp\/blob\/v$CURR_VERSION\/README.md/easyloggingpp\/blob\/v$NEW_VERSION\/README.md/g" $1/doc/RELEASE-NOTES-v$NEW_VERSION
  sed -i '' -e "s/easyloggingpp_$CURR_VERSION.zip/easyloggingpp_$NEW_VERSION.zip/g" $1/README.md
  if [ -f "easyloggingpp_v$NEW_VERSION.zip" ]; then
    rm easyloggingpp_v$NEW_VERSION.zip
  fi
  if [ -f "easyloggingpp.zip" ]; then
    rm easyloggingpp.zip
  fi
  cp $1/src/easylogging++.h .
  cp $1/src/easylogging++.cc .
  cp $1/doc/RELEASE-NOTES-v$NEW_VERSION RELEASE-NOTES.txt
  cp LICENCE LICENCE.txt
  zip easyloggingpp_v$NEW_VERSION.zip easylogging++.h easylogging++.cc LICENCE.txt RELEASE-NOTES.txt
  tar -pczf easyloggingpp_v$NEW_VERSION.tar.gz easylogging++.h easylogging++.cc LICENCE.txt RELEASE-NOTES.txt
  mv easyloggingpp_v$NEW_VERSION.zip $2/releases/
  mv easyloggingpp_v$NEW_VERSION.tar.gz $2/releases/
  cp $1/doc/RELEASE-NOTES-v$NEW_VERSION $2/release-notes-latest.txt
  cp $1/doc/RELEASE-NOTES-v$NEW_VERSION $2/releases/release-notes-v$NEW_VERSION.txt
  rm easylogging++.h easylogging++.cc RELEASE-NOTES.txt LICENCE.txt
  echo "\n---------- PLEASE CHANGE CMakeLists.txt MANUALLY ----------- \n"
fi
