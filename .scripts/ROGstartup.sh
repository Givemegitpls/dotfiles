#!/bin/bash

asusctl fan-curve --mod-profile Quiet --fan cpu --data 0c:0%,60c:5%,65c:15%,70c:25%,75c:35%,80c:45%,85c:70%,90c:100%
asusctl fan-curve --mod-profile Quiet --fan gpu --data 0c:0%,60c:5%,65c:15%,70c:25%,75c:35%,80c:45%,85c:70%,90c:100%
asusctl fan-curve --mod-profile Quiet --enable-fan-curves true
asusctl fan-curve --mod-profile Balanced --fan cpu --data 0c:0%,60c:5%,65c:15%,70c:25%,75c:35%,80c:45%,85c:70%,90c:100%
asusctl fan-curve --mod-profile Balanced --fan gpu --data 0c:0%,60c:5%,65c:15%,70c:25%,75c:35%,80c:45%,85c:70%,90c:100%
asusctl fan-curve --mod-profile Balanced --enable-fan-curves true
asusctl fan-curve --mod-profile Performance --fan cpu --data 24c:10%,35c:25%,40c:40%,50c:60%,55c:75%,60c:85%,65c:95%,70c:100%
asusctl fan-curve --mod-profile Performance --fan gpu --data 24c:10%,35c:25%,40c:40%,50c:60%,55c:75%,60c:85%,65c:95%,70c:100%
asusctl fan-curve --mod-profile Performance --enable-fan-curves true
sleep 3
asusctl profile set Balanced
