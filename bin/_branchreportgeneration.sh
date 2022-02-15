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
function __generateBranchReport {

    repoName=$1

    GITHUB_API_REST="repos/"

    temp=`basename $0`

    _writeLog "⏲️      Processing Repo $repoName"

    pageNo=1

    branchPayload=$(__createTempFile2 ${temp}-${repoName}-branches-${pageNo})

    __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}/branches" $branchPayload

    TMPFILEBRANCHES=$(__createTempFile2 ${temp}.${repoName}.branches)

    # extract branches
    jq -r '.[].name' $branchPayload >> $TMPFILEBRANCHES

    # loop over branches
    jq -r '.[].name' $branchPayload | while read branchName; 
        do

            reportDataBranch=""

            _writeLog "⏲️      Processing Repo branch $repoName/$branchName"

            fixBranchName=${branchName////-}

            branchDetailsFile=$(__createTempFile2 ${temp}-${repoName}-branch-${fixBranchName})

            __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}/branches/$branchName" $branchDetailsFile

            protected=$(__getJsonItem $branchDetailsFile '.protected' "xxxxxx")
            commitauthorname=$(__getJsonItem $branchDetailsFile '.commit.commit.author.name' "xxxxxx")
            commitauthorndate=$(__getJsonItem $branchDetailsFile '.commit.commit.author.date' "xxxxxx")

            if [[ $protected = "true" ]]
            then
                    branchProtectionPayload=$(__createTempFile2 ${temp}.${repoName}-branch-protection-${fixBranchName})

                __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}/branches/$branchName/protection" $branchProtectionPayload

                dismissStaleReviews=$(__getJsonItem $branchProtectionPayload '.required_pull_request_reviews.dismiss_stale_reviews' "xxxxxx")
            else

                dismissStaleReviews="false"

            fi

            reportDataBranch+="\n ${repoName}, ${branchName}, ${protected}, ${dismissStaleReviews}, ${commitauthorname}, ${commitauthorndate}"
            
            printf "$reportDataBranch" >> ./${OUTPUTDIR}/${reportName}

        done

    sepeator="\n ,  , , , ,"
    
    printf "$sepeator" >> ./${OUTPUTDIR}/${reportName}

}