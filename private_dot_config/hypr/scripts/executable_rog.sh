#!/bin/bash

asusctl fan-curve -m "quiet" -f cpu -D 0c:0%,60c:5%,65c:15%,70c:25%,75c:35%,80c:45%,85c:70%,90c:100%
asusctl fan-curve -m "quiet" -f gpu -D 0c:0%,60c:5%,65c:15%,70c:25%,75c:35%,80c:45%,85c:70%,90c:100%
asusctl fan-curve -m "quiet" -e true
asusctl fan-curve -m "balanced" -f cpu -D 0c:0%,60c:5%,65c:15%,70c:25%,75c:35%,80c:45%,85c:70%,90c:100%
asusctl fan-curve -m "balanced" -f gpu -D 0c:0%,60c:5%,65c:15%,70c:25%,75c:35%,80c:45%,85c:70%,90c:100%
asusctl fan-curve -m "balanced" -e true
asusctl fan-curve -m "performance" -f cpu -D 24c:10%,35c:25%,40c:40%,50c:60%,55c:75%,60c:85%,65c:95%,70c:100%
asusctl fan-curve -m "performance" -f gpu -D 24c:10%,35c:25%,40c:40%,50c:60%,55c:75%,60c:85%,65c:95%,70c:100%
asusctl fan-curve -m "performance" -e true
asusctl profile -P "balanced"
