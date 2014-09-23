#!/bin/bash
# -*- coding: utf-8 -*-

# send værdier til toilet-serveren

# kræver nc(netcat) installeret
# sudo apt-get install netcat


# Se serverens svar ved:
# curl -s http://toilet/ajax/occupied | json_xs
# kræver:
# sudo apt-get install curl, libjson-xs-perl
# eller med din browser


loki=130.226.169.164

list=('t1' 't2' 'b1' 'b2' 'b3');
# if no input arguments
if [ -z "$1" ]; then
    for i in {1..5}
    do
        ii=0
        for j in "${list[@]}"
        do
            ii=$(($ii+1))
            ms=$((1000*$ii+$i))
            echo "id = $j & type = log & ms = $ms" | nc $loki 5555 &
            sleep 0.07 # nødvendig med sleep, hvis scriptet køres på loki.
            #printf "id = %s & type = log & ms = %d \n"  $j $(($i+1000*$ii)) | nc loki 5555 &
        done
    done
    LOCK=1
elif [ "$1" == "lock" ]; then
    LOCK=1
else
    LOCK=0
fi

# lock/unlock
echo "id = t1 & type = state & state = $LOCK" | nc $loki 5555 &
echo "id = b1 & type = state & state = $LOCK" | nc $loki 5555 &
echo "id = b3 & type = state & state = $LOCK" | nc $loki 5555 &
# printf "id = t1 & type = state & state = %d \n" $LOCK | nc $loki 5555 &
# printf "id = b1 & type = state & state = %d \n" $LOCK | nc $loki 5555 &
# printf "id = b3 & type = state & state = %d \n" $LOCK | nc $loki 5555 &


