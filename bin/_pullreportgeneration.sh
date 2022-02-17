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
function __generatePullReport {

    repoName=$1

    GITHUB_API_REST="repos/"

    temp=`basename $0`

    _writeLog "⏲️      Processing Pulls For Repo $repoName"

    pageNo=1

    let __PAGENO=1
    let __Process=1

    let __BranchNo=0 
    let __pullSeq=0

    while [ $__Process -eq 1 ]; 
        do

            pullPayload=$(__createTempFile2 ${temp}-${repoName}-pulls-${pageNo})

            __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}/pulls?state=all&per_page=${PERPAGE}&page=${__PAGENO}" $pullPayload

            datacheck=$(__getJsonItem $pullPayload '.[0].number' "end")

            if [[ $datacheck != "end" ]]
            then

                __tmpFilePulls=$(__createTempFile2 ${temp}-${repoName}-pulls)

                # extract no pulls
                jq -r '.[].number' $pullPayload > $__tmpFilePulls

                # loop over pulls from extracted branch file
                while IFS="" read -r pullNo || [ -n "$pullNo" ]
                do

                    reportDataBranch=""

                    let __PullNo=__PullNo+1 

                    _writeLog "⏲️      Processing Repo pull $repoName/$pullNo ($__PullNo)"

                    #fixBranchName=${branchName////-}

                    __repoName=$(__getJsonItem $pullPayload ".[$__pullSeq].head.repo.name" "???????")
                    __repoFullName=$(__getJsonItem $pullPayload ".[$__pullSeq].head.repo.full_name" "???????")
                    __number=$(__getJsonItem $pullPayload ".[$__pullSeq].number" "???????")
                    __state=$(__getJsonItem $pullPayload ".[$__pullSeq].state" "???????")
                    __branchName=$(__getJsonItem $pullPayload ".[$__pullSeq].head.ref" "???????")
                    __title=$(__getJsonItem $pullPayload ".[$__pullSeq].title" "???????")
                    __user=$(__getJsonItem $pullPayload ".[$__pullSeq].user.login" "???????")
                    __created_at=$(__getJsonItem $pullPayload ".[$__pullSeq].created_at" "???????")
                    __updated_at=$(__getJsonItem $pullPayload ".[$__pullSeq].updated_at" "???????")
                    __closed_at=$(__getJsonItem $pullPayload ".[$__pullSeq].closed_at" "")
                    __merged_at=$(__getJsonItem $pullPayload ".[$__pullSeq].merged_at" "")
                    __merge_commit_sha=$(__getJsonItem $pullPayload ".[$__pullSeq].merge_commit_sha" "???????")

                    reportDataBranch+="\n ${__repoName}, ${__number}, ${__state}, ${__branchName}, ${__title}, ${__user}, ${__created_at}, ${__updated_at}, ${__closed_at}, ${__merged_at}"
                    
                    printf "$reportDataBranch" >> ./${OUTPUTDIR}/${reportName}

                    let __pullSeq=__pullSeq+1

                done < $__tmpFilePulls
                #done

                let __PAGENO=__PAGENO+1 
 
            else
                # No more data
                __Process=0
            fi

        done

    sepeator="\n , , , , , , , , ,"
    
    printf "$sepeator" >> ./${OUTPUTDIR}/${reportName}

    _writeLog "✔️ Total Pulls $__PullNo"

}