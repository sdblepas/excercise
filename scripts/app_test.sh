#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace

check_curl_status() {
    local url="$1"
    # Perform the curl request and capture the HTTP status code
    local http_status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    # Check if the HTTP status code is 200
    if [[ $http_status -eq 200 ]]; then
        echo "HTTP $url status code 200 OK"
    else
        echo "Error: HTTP request $url failed $http_status"
        exit 1
    fi
}


start_time=$(date +%s)
end_time=$((start_time + 20))
while true; do
    if nc -z "localhost" 4000 >/dev/null 2>&1; then
      echo "Port 4000 is open"
      break
    else
      echo "Port 4000 is not open, wait for 2 seconds"
    fi
    current_time=$(date +%s)
    if [[ "$current_time" -ge "$end_time" ]]; then
      echo "Timed out waiting for port 4000 to open"
      exit 1
    fi
    sleep 2
done
sleep 10
echo "Starting API test..."
check_curl_status "http://localhost:4000/test"
check_curl_status "http://localhost:4000/list"
check_curl_status "http://localhost:4000/employee/1"


HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "Content-Type: application/json" -XPOST 'http://localhost:4000/create' -d '{"id":99, "name":"john", "lastname":"doe", "job_title":"cleaner", "phone_number":"123456", "birthdate": "1980-11-11"}' )
if [[ $HTTP_STATUS -eq 201 ]]; then
    echo "HTTP post status code 201 OK"
    check_curl_status "http://localhost:4000/employee/99"
    check_curl_status "http://localhost:4000/logs"
else
    echo "Error: HTTP post failed $HTTP_STATUS"
    exit 1
fi
