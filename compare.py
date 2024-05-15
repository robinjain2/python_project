import requests

# Function to extract lines starting with '=' followed by an integer
def extract_specific_lines(console_output):
    specific_lines = []
    for line in console_output:
        if line.startswith("="):
            parts = line.split()
            for part in parts:
                if part.isdigit():
                    specific_lines.append(line)
                    break
    return specific_lines

# Define Jenkins server details
host = "http://140.211.11.144:8080"
username = "robin_jain"
password = "Robin@0206"

# Define job name and build numbers
job_name = "Testing"
build_number1 = 1
build_number2 = 2

# Construct URLs for console output of the specified builds
console_output_url1 = f"{host}/job/{job_name}/{build_number1}/consoleText"
console_output_url2 = f"{host}/job/{job_name}/{build_number2}/consoleText"

# Fetch console output for the first build
response1 = requests.get(console_output_url1, auth=(username, password))
if response1.status_code == 200:
    console_output1 = response1.text.splitlines()
else:
    print(f"Failed to fetch console output for build {build_number1}")

# Fetch console output for the second build
response2 = requests.get(console_output_url2, auth=(username, password))
if response2.status_code == 200:
    console_output2 = response2.text.splitlines()
else:
    print(f"Failed to fetch console output for build {build_number2}")

# Extract specific lines from console output
specific_lines1 = extract_specific_lines(console_output1)
specific_lines2 = extract_specific_lines(console_output2)

# Print comparison results
for line1, line2 in zip(specific_lines1, specific_lines2):
    print("In build", build_number1, ":", line1)
    print("In build", build_number2, ":", line2)
