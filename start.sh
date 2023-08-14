#!/bin/bash

if [ "$#" -gt 0 ]
then
  echo "No arguments supplied"
  if [ $1 = "roadrunner" ];
  then
      shift
      echo "passing the following commandline inputs to roadrunner: ",$@
      /libra/apps/install/roadrunner $@
      
  elif [ $2 = "hummbee" ];
  then
      shift
      echo "passing the following commandline inputs to hummbee: ",$@
      /libra/apps/install/hummbee $@
  fi
fi
