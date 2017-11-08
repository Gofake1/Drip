#!/bin/bash
# This script must be in the drip/ directory

projectdir=$(dirname ${0:a})/
rsync -avz --exclude '.DS_Store' --exclude 'deploy.sh' --exclude 'deployment_instructions.md' -e 'ssh -i ~/.ssh/gofake1_rsa' $projectdir vgjrmtmv@gofake1.net:~/drip