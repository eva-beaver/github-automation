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
  
# ./bin/getbranches.sh -m manifest.txt -t your-github-token -r branch

#set -e    # this line will stop the script on error
#set -xv   # this line will enable debug

. $(dirname $0)/_constants.sh
. $(dirname $0)/_vars.sh
. $(dirname $0)/_common.sh
. $(dirname $0)/_logging.sh
. $(dirname $0)/_github.sh
. $(dirname $0)/_table.sh
. $(dirname $0)/_table.sh
. $(dirname $0)/_processcheckout.sh

function usage() {
    set -e
    cat <<EOM

    ##### gitprocess #####
    Script to allow various processes to be run on with a manifest file which list multiple github repo projects
    or you can supply a single repo name

    One of the following is required:

    Required arguments:
        -m | --manifest         The manifest to use, defaults to current directory
        -t | --token            The Github token to use
        -r | --request          Request to process 
                                    * checkout - checkout project(s)

    Optional arguments:
        -p | --project          Single github reposiitory to use, overrides any manifest provided
        -k | --keep             Set to 1 to keep temp files directory, defaults to off (0)
        -d | --debug            Set to 1 to switch on, defaults to off (0)
        -o | --output           Where to output the log to, defaults to current directory

    Requirements:
        git:                Local git installation
        jq:                 Local jq installation

    Examples:
      Process a request a sample project

        ../bin/gitprocess.sh -m mymanifest.txt -t xxxxxxxxxxxxxxxx -r checkout

    Notes:

EOM

    exit 2
}

    if [ $# == 0 ]; then usage; fi

    SCRIPT_NAME="gitprocess"

    _writeLog "⏲️     Starting............"
    _writeLog "⏲️     ========================================="

    OS=$(__getOSType)

    #if [ $# == 0 ]; then usage; fi

    # check for required software
    __require git
    __require jq

    # Check log directory
    if [ -d "${LOGDIR}" ] ; then
        echo "✔️ $LOGDIR directory exists";
    else
        echo "✔️ $LOGDIR does exist, creating";
        mkdir $LOGDIR
    fi

    # Check fle directory
    if [ -d "${FILEDIR}" ] ; then
        echo "✔️ $FILEDIR directory exists";
    else
        echo "✔️ $FILEDIR does exist, creating";
        mkdir $FILEDIR
    fi

    # Check output directory
    if [ -d "${OUTPUTDIR}" ] ; then
        echo "✔️ $OUTPUTDIR directory exists";
    else
        echo "✔️ $OUTPUTDIR does exist, creating";
        mkdir $OUTPUTDIR
    fi

    OUTPUT=$(pwd)

    MANIFEST_NAME="manifest.txt"
    _MANIFEST=$MANIFEST_NAME
    _GITHUB_TOKEN=""
    _REQUEST_NAME="missing"
    _GITHUB_PROJECT_NAME="none"
    _KEEPFIILES=0
    _DEBUG=0
    
    # Loop through arguments, two at a time for key and value
    while [[ $# > 0 ]]
    do
        key="$1"

        case ${key} in
            -m|--manifest)
                _MANIFEST="$2"
                shift # past argument
                ;;
            -t|--token)
                _GITHUB_TOKEN="$2"
                shift # past argument
                ;;
            -r|--request)
                _REQUEST_NAME="$2"
                shift # past argument
                ;;
            -p|--project)
                _GITHUB_PROJECT_NAME="$2"
                shift # past argument
                ;;
            -d|--debug)
                _DEBUG=1
                shift # past argument
                ;;
            -k|--keepFiles)
                _KEEPFIILES=1
                shift # past argument
                ;;
            -o|--output)
                _OUTPUT="$2"
                shift # past argument
                ;;
            *)
                usage
                exit 2
            ;;
        esac
        shift # past argument or value
    done

    MANIFEST_NAME=$_MANIFEST
    GITHUB_TOKEN=$_GITHUB_TOKEN
    REQUEST_NAME=$_REQUEST_NAME
    GITHUB_PROJECT_NAME=$_GITHUB_PROJECT_NAME
    KEEPFIILES=$_KEEPFIILES
    DEBUG=$_DEBUG

    if [[ $REQUEST_NAME = "missing" ]]
    then
        _writeLog "❌        No request provided";
        exit 2
    fi

    # check if manifest file exists
    if test -f "$MANIFEST_NAME"; then
        _writeLog "✔️       $MANIFEST_NAME exists"
    else    
        _writeLog "❌      check failure - [$_MANIFEST] does not exist!!!!"; exit 1
    fi

    _writeLog "✔️       Running on $(__getOSType)"

    # Loop over manifest
    while IFS="" read -r _repo || [ -n "$_repo" ]
    do
            _writeLog "⏲️      Processing Manifest $_repo"
    done < $MANIFEST_NAME

    if [[ $REQUEST_NAME = "checkout" ]]; then
        __checkOut 

    else    
        _writeLog "❌        Invalid request selected!!!!";
    fi

    if [[ $KEEPFIILES -ne 1 ]]; then
        rm -rf ${FILEDIR}
        _writeLog "✔️        Removed ${FILEDIR}"
    fi

    _writeLog "👋       Finished!!!"
