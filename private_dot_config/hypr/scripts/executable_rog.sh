#!/bin/bash

asusctl fan-curve -m "quiet" -f cpu -D 20c:0%,50c:10%,55c:15%,60c:25%,65c:40%,70c:60%,75c:80%,80c:100%
asusctl fan-curve -m "quiet" -f gpu -D 20c:0%,50c:10%,55c:15%,60c:25%,65c:40%,70c:60%,75c:80%,80c:100%
asusctl fan-curve -m "quiet" -e true
asusctl fan-curve -m "balanced" -f cpu -D 24c:0%,40c:15%,50c:25%,55c:35%,60c:50%,65c:65%,70c:80%,75c:100%
asusctl fan-curve -m "balanced" -f gpu -D 24c:0%,40c:15%,50c:25%,55c:35%,60c:50%,65c:65%,70c:80%,75c:100%
asusctl fan-curve -m "balanced" -e true
asusctl fan-curve -m "performance" -f cpu -D 24c:10%,35c:25%,40c:40%,50c:60%,55c:75%,60c:85%,65c:95%,70c:100%
asusctl fan-curve -m "performance" -f gpu -D 24c:10%,35c:25%,40c:40%,50c:60%,55c:75%,60c:85%,65c:95%,70c:100%
asusctl fan-curve -m "performance" -e true
asusctl profile -P "balanced"
