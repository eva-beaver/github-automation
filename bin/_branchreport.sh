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
$(dirname $0)/_common.sh
$(dirname $0)/_logging.sh

#////////////////////////////////
function __branchReport {

    GITHUB_API_REST="repos/"

    temp=`basename $0`

    reportName="BranchReport.csv"

    reportHeader="Repo Name, Branch Name, Protected, Stale Reviews, Branch Author, Branch Date"
    reportData=''

    printf "$reportHeader" > ./${OUTPUTDIR}/${reportName}

    # Loop over manifest
    while IFS="" read -r p || [ -n "$p" ]
    do

        _writeLog "⏲️      Processing Repo $p"

        pageNo=1

        branchPayload=$(__createTempFile2 ${temp}-${p}-branches-${pageNo})

        __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${p}/branches" $branchPayload

        TMPFILEBRANCHES=$(__createTempFile2 ${temp}.${p}.branches)

        # extract branches
        jq -r '.[].name' $branchPayload >> $TMPFILEBRANCHES
 
        # loop over branches
        jq -r '.[].name' $branchPayload | while read branchName; 
            do

                reportDataBranch=""

                _writeLog "⏲️      Processing Repo branch $p/$branchName"

                fixBranchName=${branchName////-}

                branchDetailsFile=$(__createTempFile2 ${temp}-${p}-branch-${fixBranchName})

                __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${p}/branches/$branchName" $branchDetailsFile

                protected=$(__getJsonItem $branchDetailsFile '.protected' "xxxxxx")
                commitauthorname=$(__getJsonItem $branchDetailsFile '.commit.commit.author.name' "xxxxxx")
                commitauthorndate=$(__getJsonItem $branchDetailsFile '.commit.commit.author.date' "xxxxxx")
 
                if [[ $protected = "true" ]]
                then
                     branchProtectionPayload=$(__createTempFile2 ${temp}.${p}-branch-protection-${fixBranchName})

                    __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${p}/branches/$branchName/protection" $branchProtectionPayload

                    dismissStaleReviews=$(__getJsonItem $branchProtectionPayload '.required_pull_request_reviews.dismiss_stale_reviews' "xxxxxx")
                else

                    dismissStaleReviews="false"

                fi
    
                reportDataBranch+="\n ${p}, ${branchName}, ${protected}, ${dismissStaleReviews}, ${commitauthorname}, ${commitauthorndate}"
               
                printf "$reportDataBranch" >> ./${OUTPUTDIR}/${reportName}

            done

        sepeator="\n ,  , , , ,"
        
        printf "$sepeator" >> ./${OUTPUTDIR}/${reportName}
    
        reportData+=$reportDataBranch

    done < $MANIFEST_NAME
 
    printTable ',' "$(cat ./${OUTPUTDIR}/${reportName})"

}