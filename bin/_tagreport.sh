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
. $(dirname $0)/_processmanifest.sh
. $(dirname $0)/_tagreportgeneration.sh

#////////////////////////////////
#/ Param 1                  GITHUB PROJECT NAME
#////////////////////////////////
function __tagReport {

    _projectName=$1

    GITHUB_API_REST="repos/"

    temp=`basename $0`

    reportName="TagReport.csv"

    reportHeader="Repo Name, No, Name, Commit"
    reportData=''

    printf "$reportHeader" > ./${OUTPUTDIR}/${reportName}
 
    if [[ $_projectName = "none" ]]
    then
        _writeLog "⏲️      Processing Manifest"
        __processManifestItems
    else
        __generateTagReport $_projectName
    fi
 
    printTable ',' "$(cat ./${OUTPUTDIR}/${reportName})"

}