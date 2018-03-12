#!/bin/zsh

# SQS Queue URL
queueurl='https://sqs.us-west-2.amazonaws.com/764112847618/CPQ-debug'

# Aliases to handle the lightbulb, update the IP address in the commands below
alias red='tplight hsb 172.20.10.8 360 100 100'
alias blue='tplight hsb 172.20.10.8 230 100 100'
alias green='tplight hsb 172.20.10.8 110 100 100'
alias off='tplight off 172.20.10.8'
alias on='tplight on 172.20.10.8'
alias pipelinestart=blue
alias pipelinemove=pipelinestart
alias pipelinefail=red
alias pipelinesucceeded=green

# Script execution starts here...

# sed "s/\\\//g" # remove escapes

figgletize () {
  state=$1
  detailtype=$2
  stage=$3
  figlet -f doh.flf -w 180 $stage |head -n 17 |sed -n '2!p'
  figlet -f doh.flf -w 180 $state |head -n 19 |sed -n '3!p'
  echo "Change:" $detailtype
  #echo "State:" $state
}

pipelinelight () {
  stage=$1
  state=$2
  if [[ "$state" == "FAILED" ]]; then
    pipelinefail
    echo -e "\033[91m"
    figgletize $state $detailtype $stage
    echo -e "\033[0m"
  fi
  if [[ "$state" == "STARTED" ]]; then
    pipelinestart
    echo -e "\033[94m"
    figgletize $state $detailtype $stage
    echo -e "\033[0m"
  fi
  if [[ "$state" == "SUCCEEDED" ]]; then
    pipelinesucceeded
    echo -e "\033[92m"
    figgletize "SUCCESS" $detailtype $stage
    echo -e "\033[0m"
  fi
}
while true
do
  msg=$(aws sqs receive-message --queue-url $queueurl |jq '.Messages[].Body' | sed "s/\\\//g")
  msg2=${msg#"\""}
  msg2=${msg2%"\""}
  msg2=$(echo $msg2 |sed "s/detail-type/detailtype/g")
  echo $msg2 |jq .
  detailtype=$(echo $msg2 |jq .detailtype |sed "s/[\"\']//g")
  stage=$(echo $msg2 |jq .detail.stage |sed "s/[\"\']//g")
  state=$(echo $msg2 |jq .detail.state |sed "s/[\"\']//g")

  #echo "detail-type:" $detailtype
  #echo "state:" $state
  if [[ "$state" == "FAILED" ]] || [[ "$state" == "STARTED" ]] || [[ "$state" == "SUCCEEDED" ]]; then
    echo "=$previousstate=" ---- "=$state=" 
    if [[ $state != $previousstate ]]; then
      #echo STATES ARE DIFFERENT, TRIGERRING LAMP WITH $state
      pipelinelight $stage $state
      previousstate=$(echo $state)
    fi
  fi
  sleep 1
done


#msg='"{"version":"0","id":"2ceb5e18-b856-8405-be9a-46f1d44628c2","detail-type":"AWS API Call via CloudTrail","source":"aws.codepipeline","account":"612895797421","time":"2018-03-09T01:13:47Z","region":"us-west-2","resources":[],"detail":{"eventVersion":"1.05","userIdentity":{"type":"AssumedRole","principalId":"AROAIRMHUBVPRMPLSD5VU:sayersr-Isengard","arn":"arn:aws:sts::612895797421:assumed-role/Admin/sayersr-Isengard","accountId":"612895797421","accessKeyId":"ASIAJYFE5OOT7SXHIXNA","sessionContext":{"attributes":{"mfaAuthenticated":"false","creationDate":"2018-03-08T20:53:55Z"},"sessionIssuer":{"type":"Role","principalId":"AROAIRMHUBVPRMPLSD5VU","arn":"arn:aws:iam::612895797421:role/Admin","accountId":"612895797421","userName":"Admin"}}},"eventTime":"2018-03-09T01:13:47Z","eventSource":"codepipeline.amazonaws.com","eventName":"UpdatePipeline","awsRegion":"us-west-2","sourceIPAddress":"205.251.233.178","userAgent":"aws-internal/3","requestParameters":{"pipeline":{"version":1,"name":"continuous-integration","artifactStore":{"type":"S3","location":"codepipeline-us-west-2-776513347464"},"stages":[{"actions":[{"inputArtifacts":[],"name":"Source","outputArtifacts":[{"name":"MyApp"}],"actionTypeId":{"owner":"AWS","category":"Source","provider":"CodeCommit","version":"1"},"configuration":{"PollForSourceChanges":"false","RepositoryName":"russ-deploying-repo","BranchName":"dev"},"runOrder":1}],"name":"Source"},{"actions":[{"inputArtifacts":[{"name":"MyApp"}],"name":"CodeBuild","outputArtifacts":[{"name":"MyAppBuild"}],"actionTypeId":{"owner":"AWS","category":"Build","provider":"CodeBuild","version":"1"},"configuration":{"ProjectName":"UnitTests"},"runOrder":1}],"name":"Build"},{"actions":[{"inputArtifacts":[{"name":"MyApp"}],"name":"AcceptanceEnv","outputArtifacts":[],"actionTypeId":{"owner":"AWS","category":"Deploy","provider":"CloudFormation","version":"1"},"configuration":{"TemplatePath":"MyApp::templates/edx-provision.yaml","ActionMode":"CREATE_UPDATE","Capabilities":"CAPABILITY_IAM","RoleArn":"arn:aws:iam::612895797421:role/codepipeline-template","StackName":"acceptance"},"runOrder":1}],"name":"Provision"}],"roleArn":"arn:aws:iam::612895797421:role/AWS-CodePipeline-Service"}},"responseElements":{"pipeline":{"version":2,"name":"continuous-integration","artifactStore":{"type":"S3","location":"codepipeline-us-west-2-776513347464"},"stages":[{"actions":[{"inputArtifacts":[],"name":"Source","outputArtifacts":[{"name":"MyApp"}],"actionTypeId":{"owner":"AWS","category":"Source","provider":"CodeCommit","version":"1"},"configuration":{"PollForSourceChanges":"false","RepositoryName":"russ-deploying-repo","BranchName":"dev"},"runOrder":1}],"name":"Source"},{"actions":[{"inputArtifacts":[{"name":"MyApp"}],"name":"CodeBuild","outputArtifacts":[{"name":"MyAppBuild"}],"actionTypeId":{"owner":"AWS","category":"Build","provider":"CodeBuild","version":"1"},"configuration":{"ProjectName":"UnitTests"},"runOrder":1}],"name":"Build"},{"actions":[{"inputArtifacts":[{"name":"MyApp"}],"name":"AcceptanceEnv","outputArtifacts":[],"actionTypeId":{"owner":"AWS","category":"Deploy","provider":"CloudFormation","version":"1"},"configuration":{"TemplatePath":"MyApp::templates/edx-provision.yaml","ActionMode":"CREATE_UPDATE","Capabilities":"CAPABILITY_IAM","RoleArn":"arn:aws:iam::612895797421:role/codepipeline-template","StackName":"acceptance"},"runOrder":1}],"name":"Provision"}],"roleArn":"arn:aws:iam::612895797421:role/AWS-CodePipeline-Service"}},"requestID":"1e4d360b-2337-11e8-a183-eb91fa5d46da","eventID":"d451b1f5-b4cf-443b-987b-83d317ffe96a","eventType":"AwsApiCall"}}"'
