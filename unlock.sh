#!/bin/bash

v6off(){
    networksetup -setv6off wi-fi
}
v6on(){
    networksetup -setv6automatic wi-fi
}
setttl(){
    sudo sysctl -w net.inet.ip.ttl=$1
}
sethlim(){
    sudo sysctl -w net.inet6.ip6.hlim=$1
}

googledns=8.8.8.8
googledns6=2001:4860:4860::8888

# checking safe tethering conditions
v6off
if sysctl net.inet.ip.ttl | grep -q 65 && sysctl net.inet6.ip6.hlim | grep -q 65 && ping -t 1 -c 1 $googledns &> /dev/null; then
    echo "All is ok!"
    exit
else
    setttl 65 &> /dev/null; sethlim 65 &> /dev/null
    if ping -t 1 -c 1 $googledns &> /dev/null; then
        echo "All is ok!"
        exit
    fi
fi
withv6on=false
keep=true
while $keep; do
    if $withv6on; then
        v6on
        echo Testing with v6 on
    else
        v6off
        echo Testing with v6 off
    fi
    # trying to break through
    setttl 64 &> /dev/null; sethlim 64 &> /dev/null
    ping -t 1 -c 1 $googledns &> /dev/null
    if $withv6on; then 
        ping6 -c 1 $googledns6 &> /dev/null
    fi
    setttl 65 &> /dev/null; sethlim 65 &> /dev/null
    if ping -t 1 -c 1 $googledns &> /dev/null; then
        echo "All is ok!"
        keep=false
    else
        if ! $withv6on; then
            withv6on=true
        else
            withv6on=false
        fi
    fi
done
# setting safe tethering conditions
v6off
setttl 65 &> /dev/null; sethlim 65 &> /dev/null