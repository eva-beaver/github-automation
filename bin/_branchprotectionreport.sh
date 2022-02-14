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
function __branchProtectionReport {

    GITHUB_API_REST="repos/"

    temp=`basename $0`

    reportName="BranchReport.csv"

    reportHeader="Repo Name, Branch Name, Protected, Dismiss Stale Reviews"
    reportData=''

    printf "$reportHeader" > ./${OUTPUTDIR}/${reportName}

    while IFS="" read -r p || [ -n "$p" ]
    do

        #TMPFILE=`mktemp ./${FILEDIR}/${temp}.${p}.XXXXXX.json` || exit 1
        __createTempFile ${temp}-${p}-XXXXXX`

        _writeLog "⏲️      Processing Repo $p"
        __rest_call "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${p}/branches"
  
        #TMPFILEBRANCHES=`mktemp ./${FILEDIR}/${temp}.${p}.branches.XXXXXX.json` || exit 1

        __createTempFile ${temp}-${p}-branches-XXXXXX
        TMPFILEBRANCHES=$TMPFILE

        # extract branches
        jq -r '.[].name' $TMPFILE >> $TMPFILEBRANCHES

        xx=""

        # loop over branches
        jq -r '.[].name' $TMPFILE | while read branchName; 
            do

                reportDataBranch=""

                _writeLog "⏲️      Processing Repo branch $p/$branchName"

               fixBranchName=${branchName////-}

                #TMPFILE=`mktemp ./${FILEDIR}/${temp}.${p}.branch.${i}.XXXXXX.json` || exit 1
                 __createTempFile ${temp}-${p}-branch-${fixBranchName}-XXXXXX

                __rest_call "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${p}/branches/$branchName"

                protected=$(__getJsonItem $TMPFILE '.protected' "xxxxxx")

                if [[ $protected = "true" ]]
                then
                    #TMPFILE=`mktemp ./${FILEDIR}/${temp}.${p}.branch.protection.${i}.XXXXXX.json` || exit 1
                    __createTempFile ${temp}-${p}-branch-protection-${fixBranchName}

                    __rest_call "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${p}/branches/$branchName/protection"

                    dismissStaleReviews=$(__getJsonItem $TMPFILE '.required_pull_request_reviews.dismiss_stale_reviews' "xxxxxx")
                else

                    dismissStaleReviews="false"

                fi
    
                reportDataBranch+="\n ${p}, ${branchName}, ${protected}, ${dismissStaleReviews}"
                
                printf "$reportDataBranch" >> ./${OUTPUTDIR}/${reportName}

            done

        sepeator="\n ,  , , "
        
        printf "$sepeator" >> ./${OUTPUTDIR}/${reportName}
    
        reportData+=$reportDataBranch

    done < $MANIFEST_NAME
 
    printTable ',' "$(cat ./${OUTPUTDIR}/${reportName})"

}