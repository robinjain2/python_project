#!/bin/bash
 
# Function to fetch build log from Jenkins
fetchBuildLog() {
    buildId=$1
buildUrl="http://140.211.11.144:8080/job/Testing/${buildId}/console"
    response=$(curl -s "$buildUrl")
    echo "$response"
}
 
# Function to extract failed tests from build log
extractFailedTests() {
    buildLog="$1"
    failedTests={}
 
    inFailedSection=false
    while IFS= read -r line; do
        if [[ $line == *FAILED* ]]; then
            inFailedSection=true
        elif [[ $line == *"[100%]"* || $line == *"passed"* ]]; then
            inFailedSection=false
        fi
 
if [[ $inFailedSection && $line == *"test.py"* ]]; then
            parts=($line)
            failedTests+=("${parts[1]}")
        fi
    done <<< "$buildLog"
 
    echo "${failedTests[@]}"
}
 
# Function to compare test results between two builds
diffTestResults() {
    firstBuildId=$1
    secondBuildId=$2
 
    firstBuildLog=$(fetchBuildLog "$firstBuildId")
    secondBuildLog=$(fetchBuildLog "$secondBuildId")
 
    if [[ -z $firstBuildLog || -z $secondBuildLog ]]; then
        echo "Failed to fetch build logs. Make sure the build IDs are correct."
        return
    fi
 
    firstFailedTests=$(extractFailedTests "$firstBuildLog")
    secondFailedTests=$(extractFailedTests "$secondBuildLog")
 
    echo "Test cases failed in the first build but passed in the second build:"
    for testCase in $firstFailedTests; do
        if ! [[ " ${secondFailedTests[@]} " =~ " ${testCase} " ]]; then
            echo "- ${testCase}"
        fi
    done
 
    echo ""
    echo "Test cases failed in the second build but passed in the first build:"
    for testCase in $secondFailedTests; do
        if ! [[ " ${firstFailedTests[@]} " =~ " ${testCase} " ]]; then
            echo "- ${testCase}"
        fi
    done
}
 
# Provide build IDs instead of log paths
firstBuildId="1"
secondBuildId="2"
 
diffTestResults "$firstBuildId" "$secondBuildId"
