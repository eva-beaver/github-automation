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
#/ Param 1              Repo Name
#////////////////////////////////
function __generateMetricsReport {

    repoName=$1

    GITHUB_API_REST="repos/"

    temp=`basename $0`

    _writeLog "⏲️      Processing Metrics for Repo $repoName"

    repoPayload=$(__createTempFile2 ${temp}-${repoName})

    __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}" $repoPayload

    __fullName=$(__getJsonItem $repoPayload '.full_name' "missing")

    if [[ $__fullName = "missing" ]]
    then
        _writeLog "❌      Error Processing Repo $repoName"
       return 0
    fi

    let __noWeeks=0 

    commitActivityPayload=$(__createTempFile2 ${temp}-${repoName}-commit-activity-${pageNo})

    __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}/stats/commit_activity" $commitActivityPayload

    datacheck=$(__getJsonItem $commitActivityPayload '.[0].total' "end")

    # Check to see if we found any data
    if [[ $datacheck != "end" ]]
    then

        __tmpFileStats=$(__createTempFile2 ${temp}-${repoName}-stats)

        # extract stats from json to flat csv
        jq -r '.[] | [.total, .week, .days[]] | @csv' $commitActivityPayload > $__tmpFileStats

        # loop over week stats from extracted data in the csv file
        while IFS="," read -r __noCommits __week __sun __mon __tue __wed __thu __fri __sat || [ -n "$allStats" ]
        do

            reportData=""

            let __noWeeks=__noWeeks+1 

            # Only show weeks that have had commits
            if [[ $__noCommits -ne 0 ]]; then
                #__dateWeek=$(date +"%Y-%m-%d" -d "@$__week")

                __dateWeek=$(__formatDateYYMMDD $__week)
                
                reportData+="\n ${repoName}, $__noCommits, $__dateWeek, $__mon, $__tue, $__wed, $__thu, $__fri, $__sat, $__sun "
            
                printf "$reportData" >> ./${OUTPUTDIR}/${reportName}

            fi

        done < $__tmpFileStats

    fi

    sepeator="\n , , , , , , , , ,"
    
    printf "$sepeator" >> ./${OUTPUTDIR}/${reportName}

    _writeLog "✔️ Total Weeks $__noWeeks"

}