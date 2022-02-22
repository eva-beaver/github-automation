# github-automation

This project is a collection of various tools to help automate reporting and managng of github projects.

It allows you to automatically run repetative tasks.

All code is found in the ./bin directory


The are two functions

 * gitreport - This automates producing reports from github using apis
 * gitprocess - This automates tasks on repos, such as checkig them out

To customise this to run for you own githib account you will need to chanmge the constants held in _constants.sh 

 
GITHUB_BASE_URL="https://api.github.com/"
GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.v3+json"
GITHUB_OWNER="eva-beaver"

GITHUB_BASE_URI="git@github.com:eva-beaver"
