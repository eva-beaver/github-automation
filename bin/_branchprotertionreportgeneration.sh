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
function __generateBranchProtectionReport {

    repoName=$1

    GITHUB_API_REST="repos/"

    temp=`basename $0`

    _writeLog "⏲️      Processing Branches for Repo $repoName"

    pageNo=1

    let __PAGENO=1
    let __Process=1

    let __BranchNo=0 

    while [ $__Process -eq 1 ]; 
        do

            branchPayload=$(__createTempFile2 ${temp}-${repoName}-branches-${pageNo})

            __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}/branches?per_page=${PERPAGE}&page=${__PAGENO}" $branchPayload

            datacheck=$(__getJsonItem $branchPayload '.[0].name' "end")

            if [[ $datacheck != "end" ]]
            then

                TMPFILEBRANCHES=$(__createTempFile2 ${temp}.${repoName}.branches)

                # extract branches
                jq -r '.[].name' $branchPayload > $TMPFILEBRANCHES

                # loop over branches from extracted branch file
                while IFS="" read -r branchName || [ -n "$branchName" ]
                do

                    reportDataBranch=""

                    let __BranchNo=__BranchNo+1 

                    _writeLog "⏲️      Processing Repo branch $repoName/$branchName ($__BranchNo)"

                    fixBranchName=${branchName////-}

                    branchDetailsFile=$(__createTempFile2 ${temp}-${repoName}-branch-${fixBranchName})

                    __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}/branches/$branchName" $branchDetailsFile

                    protected=$(__getJsonItem $branchDetailsFile '.protected' "xxxxxx")

                    if [[ $protected = "true" ]]
                    then
                        branchProtectionPayload=$(__createTempFile2 ${temp}.${repoName}-branch-protection-${fixBranchName})

                        __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}/branches/$branchName/protection" $branchProtectionPayload

                        dismissStaleReviews=$(__getJsonItem $branchProtectionPayload '.required_pull_request_reviews.dismiss_stale_reviews' "xxxxxx")
                    else

                        dismissStaleReviews="false"

                    fi

                    reportDataBranch+="\n ${repoName}, ${__BranchNo}, ${branchName}, ${protected}, ${dismissStaleReviews}"
                    
                    printf "$reportDataBranch" >> ./${OUTPUTDIR}/${reportName}

                done < $TMPFILEBRANCHES

                let __PAGENO=__PAGENO+1 

            else
                # No more data
                __Process=0
            fi

        done

    sepeator="\n , , , ,"
    
    printf "$sepeator" >> ./${OUTPUTDIR}/${reportName}

    _writeLog "✔️ Total Branches $__BranchNo"

}