#!/bin/bash
 
# Function to fetch build log from Jenkins
fetchBuildLog() {
    local buildId="$1"
local buildUrl="http://140.211.11.144:8080/job/Testing/${buildId}/consoleText"
    curl -s "$buildUrl"
}
 
# Function to extract failed tests from build log
extractFailedTests() {
    local buildLog="$1"
    echo "$buildLog" | grep -oP 'test\.py.*?FAILED' | awk '{print $1}'
}
 
# Function to compare test results between two builds
diffTestResults() {
    local firstBuildId="$1"
    local secondBuildId="$2"
    local firstBuildLog=$(fetchBuildLog "$firstBuildId")
    local secondBuildLog=$(fetchBuildLog "$secondBuildId")
 
    if [[ -z $firstBuildLog || -z $secondBuildLog ]]; then
        echo "Failed to fetch build logs. Make sure the build IDs are correct."
        return
    fi
 
    local firstFailedTests=$(extractFailedTests "$firstBuildLog")
    local secondFailedTests=$(extractFailedTests "$secondBuildLog")
 
    echo "Test cases failed in the first build but passed in the second build:"
    comm -23 <(echo "$firstFailedTests" | sort) <(echo "$secondFailedTests" | sort)
 
    echo ""
    echo "Test cases failed in the second build but passed in the first build:"
    comm -13 <(echo "$firstFailedTests" | sort) <(echo "$secondFailedTests" | sort)
}
 
# Provide build IDs instead of log paths
firstBuildId="1"
secondBuildId="2"
 
diffTestResults "$firstBuildId" "$secondBuildId"
