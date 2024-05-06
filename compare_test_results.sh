#!/bin/bash
 
# Function to fetch build log from Jenkins
fetchBuildLog() {
    local buildId=$1
local buildUrl="http://140.211.11.144:8080/job/Testing/${buildId}/consoleText"
    local response=$(curl -s "$buildUrl")
    echo "$response"
}
 
# Function to extract failed tests from build log
extractFailedTests() {
    local buildLog="$1"
    local failedTests=()
    local inFailedSection=false
 
    while IFS= read -r line; do
        if [[ $line == *FAILED* ]]; then
            inFailedSection=true
        elif [[ $line == *"[100%]"* || $line == *"passed"* ]]; then
            inFailedSection=false
        fi
 
if $inFailedSection && [[ $line == *"test.py"* ]]; then
            local parts=($line)
            failedTests+=("${parts[1]}")
        fi
    done <<< "$buildLog"
 
    echo "${failedTests[@]}"
}
 
# Function to compare test results between two builds
diffTestResults() {
    local firstBuildId=$1
    local secondBuildId=$2
    local firstBuildLog=$(fetchBuildLog "$firstBuildId")
    local secondBuildLog=$(fetchBuildLog "$secondBuildId")
 
    if [[ -z $firstBuildLog || -z $secondBuildLog ]]; then
        echo "Failed to fetch build logs. Make sure the build IDs are correct."
        return
    fi
 
    local firstFailedTests=$(extractFailedTests "$firstBuildLog")
    local secondFailedTests=$(extractFailedTests "$secondBuildLog")
 
    echo "Test cases failed in the first build but passed in the second build:"
    for testCase in ${firstFailedTests[@]}; do
        if [[ ! " ${secondFailedTests[@]} " == *" ${testCase} "* ]]; then
            echo "- ${testCase}"
        fi
    done
 
    echo ""
    echo "Test cases failed in the second build but passed in the first build:"
    for testCase in ${secondFailedTests[@]}; do
        if [[ ! " ${firstFailedTests[@]} " == *" ${testCase} "* ]]; then
            echo "- ${testCase}"
        fi
    done
}
 
# Provide build IDs instead of log paths
firstBuildId="1"
secondBuildId="2"
 
diffTestResults "$firstBuildId" "$secondBuildId"
