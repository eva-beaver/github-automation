#!/usr/bin/env bash
#/*
 #* Copyright 2014-2022 the original author or authors.
 #*
 #* Licensed under the Apache License, Version 2.0 (the "License");
 #* you may not use this file except in compliance with the License.
 #* You may obtain a copy of the License at
 #*
 #*     http://www.apache.org/licenses/LICENSE-2.0
 #*
 #* Unless required by applicable law or agreed to in writing, software
 #* distributed under the License is distributed on an "AS IS" BASIS,
 #* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 #* See the License for the specific language governing permissions and
 #* limitations under the License.
 #*/
 
$(dirname $0)/_vars.sh
$(dirname $0)/_logging.sh

WORKING_DIRECTORY=$(cd $(dirname $0); pwd)

# keep a cache directory of projects that we are using so we dont keep having to do fresh checkouts
CACHE_DIRECTORY="${WORKING_DIRECTORY}/cache"

if [ ! -d "${CACHE_DIRECTORY}" ]; then
  mkdir "${CACHE_DIRECTORY}"
fi

function __require {
    command -v $1 > /dev/null 2>&1 || {
        echo "❌       Dude!!! Some of the required software is not installed:"
        echo "        please install $1" >&2;
        exit 1;
    }
}
 
# Using jq to extract json node data from the jsonfile
# usage 
#   $1 = filename
#   $2 = query
#   $3 = default value
function __getJsonItem {
 
    # -r option removes "
    local ITEM_TO_FIND="$(cat $1 | jq -r $2)"

    if [[ $ITEM_TO_FIND == "null" ]]
    then
      echo $3
      return 1
    else
      echo ${ITEM_TO_FIND}
      return 0
    fi

}

function __createTempDirectory {
    NAME="$(date "+%Y%m%d%H%M%S")"
    TMP_DIR="${WORKING_DIRECTORY}/${NAME}"
    rm -rdf "${TMP_DIR}"
    mkdir "${TMP_DIR}"
    echo "${TMP_DIR}"
}

function __cleanUpTempDirectory {
    cd "${WORKING_DIRECTORY}"
    rm -rdf "${TMP_DIR}"
}

function __createTempFile {
    tempName="$(date "+%Y%m%d%H%M%S")"
    if [ "$OSTYPE" == "linx-gnu" ]; then
        fileSuffix=".json"
    else
        fileSuffix=""
    fi
    TMPFILE=`mktemp -q ./${FILEDIR}/${1}.XXXXXX` || exit 1
    if [ $? -ne 0 ]; then
        echo "❌         Can't create temp file ./${FILEDIR}/${1}.XXXXXX, exiting....."
        exit 1
    fi
}

function __createTempFile2 {
    tempName="$(date "+%Y%m%d%H%M%S")"
    if [ "$OSTYPE" == "linx-gnu" ]; then
        fileSuffix=".json"
    else
        fileSuffix=""
    fi
    newFile=`mktemp -q ${FILEDIR}/${1}.XXXXXX` || exit 1
    if [ $? -ne 0 ]; then
        echo "❌         Can't create temp file ./${FILEDIR}/${1}.XXXXXX, exiting....."
        exit 1
    else
        echo $newFile
    fi
}

function __getOSType {
    case "$OSTYPE" in
    solaris*) echo "SOLARIS" ;;
    darwin*)  echo "OSX" ;; 
    linux*)   echo "LINUX" ;;
    bsd*)     echo "BSD" ;;
    msys*)    echo "WINDOWS" ;;
    cygwin*)  echo "ALSO WINDOWS" ;;
    *)        echo "unknown: $OSTYPE" ;;
    esac
}


function __showOSType {
    case "$OSTYPE" in
    solaris*) echo "SOLARIS" ;;
    darwin*)  echo "OSX" ;; 
    linux*)   echo "LINUX" ;;
    bsd*)     echo "BSD" ;;
    msys*)    echo "WINDOWS" ;;
    cygwin*)  echo "ALSO WINDOWS" ;;
    *)        echo "unknown: $OSTYPE" ;;
    esac
}

