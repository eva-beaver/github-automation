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
 
GITHUB_BASE_URL="https://api.github.com/"
GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.v3+json"
GITHUB_OWNER="eva-beaver"

GITHUB_BASE_URI="git@github.com:eva-beaver"

PERPAGE=50

LOGDIR="./log"
FILEDIR="./files"
OUTPUTDIR="./output"

TMP_DIR=""
