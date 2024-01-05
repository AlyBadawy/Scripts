#!/bin/bash

echo "The Dice says..."
FLIP=$(($(($RANDOM))%6 + 1))

echo $FLIP
