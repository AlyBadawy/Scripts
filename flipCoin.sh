#!/bin/bash

echo "The coin says..."
FLIP=$(($(($RANDOM))%2))
if [ $FLIP -eq 1 ];then
  AYS="heads"
else
  AYS="tails"
fi
sleep 0.2
echo $AYS
