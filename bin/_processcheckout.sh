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
 
. $(dirname $0)/_vars.sh
. $(dirname $0)/_common.sh
. $(dirname $0)/_logging.sh

#////////////////////////////////
#/ 
#////////////////////////////////
function __checkOut {

    _repoName=$1
    _suffix=".git"

    _writeLog "⏲️      Processing git chechout For Repo $MANIFEST_NAME"

    REAL_MANIFEST_NAME=$(realpath $MANIFEST_NAME)

    WORKING_DIRECTORY=$(cd $(dirname $0); pwd)

    # keep a cache directory of projects that we are using so we dont keep having to do fresh checkouts
    CACHE_DIRECTORY="${WORKING_DIRECTORY}/cache"

    if [ ! -d "${CACHE_DIRECTORY}" ]; then
        mkdir "${CACHE_DIRECTORY}"
    fi

    # create a tmp directory to work in and change to it
    TMP_DIR=$(__createTempDirectory)
    _writeLog "⏲️      Created tempDir: ${TMP_DIR}"
    cd ${TMP_DIR}

    if [ -d "${CACHE_DIRECTORY}/${_repoName}" ];
    then
        _writeLog "⏲️      Updating projects cache ${CACHE_DIRECTORY}"
    else
        _writeLog "⏲️      Cloning projects from git"
    fi

    # Loop over manifest
    while IFS="" read -r _repo || [ -n "$_repo" ]
    do

        _writeLog "⏲️      processing -> ${_repo}"

        # check to see if we have a cache of this projects
        if [ -d "${CACHE_DIRECTORY}/${_repo}" ];
        then
            _writeLog "⏲️      ${_repo} cached, updating"

            # cached so fetch and prune and deleted local branches
            git -C "${CACHE_DIRECTORY}/${_repo}" fetch -p -q
            if [ $? -eq 0 ]; then
                _writeLog "⏲️      Fetch of ${_repo} OK"
            else
                _writeErrorLog "❌        Fetch failed";
                exit 1
            fi
            git -C "${CACHE_DIRECTORY}/${_repo}" pull -q
            # make sure develop is checkout as it is not the main branch
            git -C "${CACHE_DIRECTORY}/${_repo}" checkout main
            git -C "${CACHE_DIRECTORY}/${_repo}" checkout develop

            # copy refreshed cache to tmp directory
            cp -r "${CACHE_DIRECTORY}/${_repoName}" .
        else
            # not cached so do a fresh checkout into cache and then move to current working folder
            _writeLog "⏲️      Checking out -> ${_repo}"

            git clone ${GITHUB_BASE_URI}/${_repo}.git "${CACHE_DIRECTORY}/${_repo}"
            if [ $? -eq 0 ]; then
                _writeLog "⏲️      Checkout of ${_repo} OK"
            else
                _writeErrorLog "❌        Checkout failed";
                exit 1
            fi
            git -C "${CACHE_DIRECTORY}/${_repo}" fetch -p -q
            # make sure develop is checkout as it is not the main branch
            git -C "${CACHE_DIRECTORY}/${_repo}" checkout main
            git -C "${CACHE_DIRECTORY}/${_repo}" checkout develop

            # copy refreshed cache to tmp directory
            cp -r "${CACHE_DIRECTORY}/${_repo}" .
        fi
        
        if [ -d "${CACHE_DIRECTORY}/${_repo}" ];
        then
            _writeLog "⏲️      Projects cache updated"
        else
            _writeLog "⏲️      Projects cloned from git"
        fi
        
    done < $REAL_MANIFEST_NAME

    _writeLog "⏲️      git checkout complete"

}