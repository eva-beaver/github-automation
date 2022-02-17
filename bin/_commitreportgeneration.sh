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
function __generateCommitReport {

    repoName=$1

    GITHUB_API_REST="repos/"

    temp=`basename $0`

    _writeLog "⏲️      Processing Commits for Repo $repoName"

    repoPayload=$(__createTempFile2 ${temp}-${repoName})

    __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}" $repoPayload

    __fullName=$(__getJsonItem $repoPayload '.full_name' "missing")

    if [[ $__fullName = "missing" ]]
    then
        _writeLog "❌      Error Processing Repo $repoName"
       return 0
    fi

    pageNo=1

    let __PAGENO=1
    let __Process=1

    let __BranchNo=0 

    while [ $__Process -eq 1 ]; 
        do

            __commitPayload=$(__createTempFile2 ${temp}-${repoName}-commits-${pageNo})

            __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}/commits?per_page=${PERPAGE}&page=${__PAGENO}" $__commitPayload

            datacheck=$(__getJsonItem $__commitPayload '.[0].sha' "end")

            if [[ $datacheck != "end" ]]
            then

                __tmpFileCommits=$(__createTempFile2 ${temp}-${repoName}-commits)

                # extract commits
                jq -r '.[] | [.sha, .commit.author.name, .commit.author.date, .commit.message, .comment_count] | @csv' $__commitPayload > $__tmpFileCommits

                # loop over commits from extracted file
                while IFS="," read -r __authorName __authorDate __message __commentCnt || [ -n "$__authorName" ]
                do

                    reportDataCommit=""

                    let __noCommits=__noCommits+1 

                    reportDataCommit+="\n ${repoName}, ${__authorName}, ${__authorDate}, ${__message}, ${__commentCnt}"
                    
                    printf "$reportDataCommit" >> ./${OUTPUTDIR}/${reportName}

                done < $__tmpFileCommits
                #done

                let __PAGENO=__PAGENO+1 

            else
                # No more data
                __Process=0
            fi

        done

    sepeator="\n , , , , ,"
    
    printf "$sepeator" >> ./${OUTPUTDIR}/${reportName}

    _writeLog "✔️ Total commits $__noCommits"

}