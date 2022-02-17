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
function __generateReleaseReport {

    repoName=$1

    GITHUB_API_REST="repos/"

    temp=`basename $0`

    _writeLog "⏲️      Processing Releases For Repo $repoName"

    pageNo=1

    let __PAGENO=1
    let __Process=1

    let __BranchNo=0 
    let __pullSeq=0

    repoPayload=$(__createTempFile2 ${temp}-${repoName})

    __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}" $repoPayload

    __fullName=$(__getJsonItem $repoPayload '.full_name' "missing")

    if [[ $__fullName = "missing" ]]
    then
        _writeLog "❌      Error Processing Repo $repoName"
       return 0
    fi

    while [ $__Process -eq 1 ]; 
        do

            releasePayload=$(__createTempFile2 ${temp}-${repoName}-releases-${pageNo})

            __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}/releases?state=all&per_page=${PERPAGE}&page=${__PAGENO}" $releasePayload

            datacheck=$(__getJsonItem $releasePayload '.[0].id' "end")

            let __releaseSeq=0

            if [[ $datacheck != "end" ]]
            then

                __tmpFileReleases=$(__createTempFile2 ${temp}-${repoName}-releases)

                # extract no releases
                jq -r '.[].id' $releasePayload > $__tmpFileReleases

                # loop over releases from extracted branch file
                while IFS="" read -r releaseNo || [ -n "$releaseNo" ]
                do

                    reportDataBranch=""

                    let __releaseNo=__releaseNo+1

                    _writeLog "⏲️      Processing Repo release $repoName/$releaseNo ($__releaseNo)"

                    __number=$(__getJsonItem $releasePayload ".[$__releaseSeq].id" "???????")
                    __draft=$(__getJsonItem $releasePayload ".[$__releaseSeq].draft" "???????")
                    __tagName=$(__getJsonItem $releasePayload ".[$__releaseSeq].tag_name" "???????")
                    __name=$(__getJsonItem $releasePayload ".[$__releaseSeq].name" "???????")
                    __targetCommitish=$(__getJsonItem $releasePayload ".[$__releaseSeq].target_commitish" "???????")
                    __user=$(__getJsonItem $releasePayload ".[$__releaseSeq].author.login" "???????")
                    __created_at=$(__getJsonItem $releasePayload ".[$__releaseSeq].created_at" "???????")
                    __published_at=$(__getJsonItem $releasePayload ".[$__releaseSeq].published_at" "???????")

                    reportDataBranch+="\n ${repoName}, ${__releaseNo}, ${__number}, ${__draft}, ${__tagName}, ${__name}, ${__targetCommitish}, ${__user}, ${__created_at}, ${__published_at}"
                    
                    printf "$reportDataBranch" >> ./${OUTPUTDIR}/${reportName}

                    let __releaseSeq=__releaseSeq+1

                done < $__tmpFileReleases

                let __PAGENO=__PAGENO+1 
 
            else
                # No more data
                __Process=0
            fi

        done

    sepeator="\n , , , , , , , , ,"
    
    printf "$sepeator" >> ./${OUTPUTDIR}/${reportName}

    _writeLog "✔️ Total Release's $__releaseNo"

}