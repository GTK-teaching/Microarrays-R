#!/bin/bash

: ${SLEEPTIME:=1}


xtitle () 
{ 
    case "$TERM" in 
        *term* | rxvt)
            echo -n -e "\033]0;$*\007"
        ;;
        *)

        ;;
    esac
}


xtitle $(basename $(pwd))
echo Continuous make of $(basename $(pwd))

echo Sleeptime is $SLEEPTIME

while true; do
    sleep $SLEEPTIME;
    /usr/bin/make lesson-md > /dev/null;
done
