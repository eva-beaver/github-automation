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
  
# ./bin/getbranches.sh -m manifest.txt -t token -r branch

#set -e    # this line will stop the script on error
#set -xv   # this line will enable debug

. $(dirname $0)/_constants.sh
. $(dirname $0)/_vars.sh
. $(dirname $0)/_common.sh
. $(dirname $0)/_logging.sh
. $(dirname $0)/_github.sh
. $(dirname $0)/_branchreport.sh
. $(dirname $0)/_branchprotectionreport.sh
. $(dirname $0)/_table.sh

function usage() {
    set -e
    cat <<EOM
    ##### getbranches #####
    Script to get all branches from a list of github repositories.

    One of the following is required:

    Required arguments:

    Optional arguments:
        -m | --manifest         The manifest to use, defaults to current directory
        -t | --token            The Github token to use
        -d | --debug            Set to 1 to switch on, defaults to off (0)
        -o | --output           Where to output the log to, defaults to current directory

    Requirements:
        git:                Local git installation
        jq:                 Local jq installation

    Examples:
      Build a sample project

        ../bin/getbranches.sh -m mymanifest.json -t xxxxxxxxxxxxxxxx

    Notes:

EOM

    exit 2
}


    if [ $# == 0 ]; then usage; fi

    _writeLog "⏲️     Starting............"
    _writeLog "⏲️     ========================================="

    #if [ $# == 0 ]; then usage; fi

    # check for required software
    __require git
    __require jq

    # Check log directory
    if [ -d "${LOGDIR}" ] ; then
        echo "✔️$LOGDIR directory exists";
    else
        echo "✔️ $LOGDIR does exist, creating";
        mkdir $LOGDIR
    fi

    # Check fle directory
    if [ -d "${FILEDIR}" ] ; then
        echo "✔️$FILEDIR directory exists";
    else
        echo "✔️ $FILEDIR does exist, creating";
        mkdir $FILEDIR
    fi


    # Check output directory
    if [ -d "${OUTPUTDIR}" ] ; then
        echo "✔️$OUTPUTDIR directory exists";
    else
        echo "✔️ $OUTPUTDIR does exist, creating";
        mkdir $OUTPUTDIR
    fi

    OUTPUT=$(pwd)

    MANIFEST_NAME="manifest.txt"
    _MANIFEST=$MANIFEST_NAME
    _GITHUB_TOKEN=""
    _REPORT_NAME="missing"
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
            -r|--report)
                _REPORT_NAME="$2"
                shift # past argument
                ;;
            -d|--debug)
                _DEBUG=1
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

    DEBUG=$_DEBUG
    MANIFEST_NAME=$_MANIFEST
    GITHUB_TOKEN=$_GITHUB_TOKEN

    if [[ $_REPORT_NAME = "missing" ]]
    then
        _writeLog "❌        No report provided";
        exit 2
    fi

    # check if manifest file exists
    if test -f "$MANIFEST_NAME"; then
        _writeLog "✔️       $MANIFEST_NAME exists"
    else    
        _writeLog "❌        check failure - [$_MANIFEST] does not exist!!!!"; exit 1
    fi

    if [[ $_REPORT_NAME = "branch" ]]; then
        __branchReport 
    elif [[ $_REPORT_NAME = "branchProtection" ]]; then
       __branchProtectionReport
    fi

    _writeLog "👋       Finished!!!"
