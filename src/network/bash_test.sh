#!/bin/bash

usedPorts=(:TEMP:)

usePort=9050

function CheckPort() {
    # Takes port to check as arg "$1" and increment
    # amount as arg "$2".
    port=$1
    increment=$2
    while true ;
    do
        if [[ ! "${usedPorts[*]}" =~ ":$port:" ]]; then
            # If port is not in the used port array
            # add it to the array and return the port.
            usePort="$port"
            usedPorts+=(":$port:")
            break
        fi
        # If the port is in the exclusion array
        # get the next port to check
        port=$(($port + $increment))
    done
}


usePort=7050
CheckPort $usePort 2000
echo "New port is: $usePort"
echo "USED: ${usedPorts[*]}"
usePort=7050
CheckPort $usePort 2000
echo "New port is: $usePort"
echo "USED: ${usedPorts[*]}"

test=()
val="aaa"

function testf() {
    a=$1
    while true;
    do
        val="bbb"
        test+=(":$a:")
        break
    done
}
testf "aaa"
echo "$test"


org=3

function calc() {
    o=$(($1-1))
    PORT=$((7051 + ($o*2000)))
}

calc $org

echo "$PORT"

