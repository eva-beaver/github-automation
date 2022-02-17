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
function __generateTagReport {

    repoName=$1

    GITHUB_API_REST="repos/"

    temp=`basename $0`

    _writeLog "⏲️      Processing Tags For Repo $repoName"

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

            tagPayload=$(__createTempFile2 ${temp}-${repoName}-releases-${pageNo})

            __rest_call_to_file "${GITHUB_BASE_URL}${GITHUB_API_REST}${GITHUB_OWNER}/${repoName}/tags?state=all&per_page=${PERPAGE}&page=${__PAGENO}" $tagPayload

            datacheck=$(__getJsonItem $tagPayload '.[0].name' "end")

            let __tagSeq=0

            if [[ $datacheck != "end" ]]
            then

                __tmpFileTags=$(__createTempFile2 ${temp}-${repoName}-releases)

                # extract no releases
                jq -r '.[].name' $tagPayload > $__tmpFileTags

                # loop over releases from extracted branch file
                while IFS="" read -r tagNo || [ -n "$tagNo" ]
                do

                    reportDataBranch=""

                    let __tagNo=__tagNo+1

                    _writeLog "⏲️      Processing Repo tags $repoName/$tagNo ($__tagNo)"

                    __name=$(__getJsonItem $tagPayload ".[$__tagSeq].name" "???????")
                    __commit=$(__getJsonItem $tagPayload ".[$__tagSeq].commit.sha" "???????")

                    reportDataBranch+="\n ${repoName}, ${__tagNo}, ${__name}, ${__commit}"
                    
                    printf "$reportDataBranch" >> ./${OUTPUTDIR}/${reportName}

                    let __tagSeq=__tagSeq+1

                done < $__tmpFileTags

                let __PAGENO=__PAGENO+1 
 
            else
                # No more data
                __Process=0
            fi

        done

    sepeator="\n , , ,"
    
    printf "$sepeator" >> ./${OUTPUTDIR}/${reportName}

    _writeLog "✔️ Total Tag's $__tagNo"

}