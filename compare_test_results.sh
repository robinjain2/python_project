#!/bin/bash
 
# Function to fetch build log from Jenkins
fetchBuildLog() {
    local buildId="$1"
local buildUrl="http://140.211.11.144:8080/job/Testing/${buildId}/consoleText"
    curl -s "$buildUrl"
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
    # Commented out for debugging
    #local firstFailedTests=$(extractFailedTests "$firstBuildLog")
    #local secondFailedTests=$(extractFailedTests "$secondBuildLog")
    echo "Test results comparison will be performed here"
}
 
# Provide build IDs instead of log paths
firstBuildId="1"
secondBuildId="2"
diffTestResults "$firstBuildId" "$secondBuildId"
