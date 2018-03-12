#!/bin/sh

# SQS Queue URL
queueurl='https://sqs.us-west-2.amazonaws.com/764112847618/CodePipelineQueue'

# Aliases to handle the lightbulb, update the IP address in the commands below
alias red='tplight hsb 172.20.10.8 360 100 100'
alias blue='tplight hsb 172.20.10.8 230 100 100'
alias green='tplight hsb 172.20.10.8 110 100 100'
alias off='tplight off 172.20.10.8'
alias on='tplight on 172.20.10.8'
alias pipelinestart='blue'
alias pipelinemove=pipelinestart
alias pipelinefail='red'
alias pipelinesucceeded='green'

# Script execution starts here...
while true
do
  msg=$(aws sqs receive-message --queue-url $queueurl |jq '.Messages[].Body' | sed "s/[\"\']//g")
  #echo $msg
  if [ "$msg" == "FAILED" ]; then
    echo 'Pipeline FAILED - changing bulb behavior'
    pipelinefail
  fi
  if [ "$msg" == "STARTED" ]; then
    echo 'Pipeline STARTED - changing bulb behavior'
    pipelinestart
  fi
  if [ "$msg" == "SUCCEEDED" ]; then
    echo 'Pipeline SUCCEEDED - changing bulb behavior'
    pipelinesucceeded
  fi
  sleep 1
done


#Possible statuses:
#CANCELLED
#FAILED
#RESUMED
#STARTED
#SUCCEEDED
#SUPERSEDED