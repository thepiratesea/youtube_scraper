#!/bin/bash
piactl --help > /dev/null 2>&1
if [[ $? == "0" ]]; then
    echo ""
    echo -n "Connecting to a new VPN node...please wait..."
    pia_nodes=("us-west-streaming-optimized" "us-rhode-island" "us-virginia" "us-wyoming" "us-atlanta" "us-houston" "us-vermont" "us-honolulu" "us-alaska" "us-kansas" "us-washington-dc" "us-oklahoma" "us-louisiana" "us-minnesota" "us-michigan" "us-new-york" "us-north-carolina" "us-salt-lake-city" "us-chicago" "us-wisconsin" "us-denver" "us-seattle" "us-south-carolina" "us-texas" "us-south-dakota" "us-florida" "us-montana" "us-new-hampshire" "us-pennsylvania" "us-east" "us-idaho" "us-kentucky" "us-nebraska" "us-arkansas" "us-mississippi" "us-new-mexico" "us-baltimore" "us-maine" "us-massachusetts" "us-east-streaming-optimized" "us-wilmington" "us-connecticut" "us-silicon-valley" "us-las-vegas" "us-north-dakota" "us-ohio" "us-oregon" "us-iowa" "us-west-virginia" "us-west" "us-indiana" "us-california" "us-missouri" "us-tennessee" "us-alabama")
    randompia=$(($RANDOM % 56))
    pia=${pia_nodes[$randompia-1]}
    piactl set region $pia
    sleep 10
    echo "successfully connected to $pia!"
    echo ""
fi
