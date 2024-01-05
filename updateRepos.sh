#!/bin/bash

for d in ./*/
do 
  cd $d
  pwd
  git add --all
  git stash
  git pull
  cd -
done