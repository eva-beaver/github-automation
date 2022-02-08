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
