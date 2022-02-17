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
. $(dirname $0)/_branchreportgeneration.sh
. $(dirname $0)/_branchprotertionreportgeneration.sh
. $(dirname $0)/_pullreportgeneration.sh
. $(dirname $0)/_metricsreportgeneration.sh
. $(dirname $0)/_commitreportgeneration.sh
. $(dirname $0)/_releasereportgeneration.sh
. $(dirname $0)/_tagreportgeneration.sh

#////////////////////////////////
#/
#////////////////////////////////
function __processManifestItems {

    GITHUB_API_REST="repos/"

    # Loop over manifest
    while IFS="" read -r p || [ -n "$p" ]
    do

        if [[ $REPORT_NAME = "branch" ]]; then
            __generateBranchReport $p
        elif [[ $REPORT_NAME = "branchProtection" ]]; then
            __generateBranchProtectionReport $p
        elif [[ $REPORT_NAME = "pull" ]]; then
            __generatePullReport $p
        elif [[ $REPORT_NAME = "metrics" ]]; then
            __generateMetricsReport $p
        elif [[ $REPORT_NAME = "commit" ]]; then
            __generateCommitReport $p
        elif [[ $REPORT_NAME = "release" ]]; then
            __generateCommitReport $p
        elif [[ $REPORT_NAME = "tag" ]]; then
            __generateTagReport $p
        fi
        
    done < $MANIFEST_NAME

}