#!/usr/bin/env bash

read -p "Enter AWS Profile[defalut]: " AWS_PROFILE
[[ ! -z "${AWS_PROFILE}" ]] || { 
    AWS_PROFILE="default";
};

echo "AWS_PROFILE=${AWS_PROFILE}";
aws --profile $AWS_PROFILE cloudformation deploy \
    --capabilities CAPABILITY_NAMED_IAM \
    --stack-name BespinGlobal \
    --template-file template.yaml \
    --parameter-overrides Password=$(openssl rand -base64 20) \
    || { echo "ERROR"; exit 1; }


echo "User name,Password,Access key ID,Secret access key,Console login link" > new_user_credentials.csv


aws --profile $AWS_PROFILE cloudformation describe-stacks \
    --stack-name BespinGlobal \
    --query "Stacks[*].{ \
        link: Outputs[?OutputKey=='AccountId'] | [0].OutputValue, \
        Secret: Outputs[?OutputKey=='BespinSupportPassword'] | [0].OutputValue \
        }" \
    --output text \
    | awk '{print "BespinSupport,"$1",,,"$2}' >> new_user_credentials.csv

aws --profile $AWS_PROFILE cloudformation describe-stacks \
    --stack-name BespinGlobal \
    --query "Stacks[*].{ \
        link: Outputs[?OutputKey=='BespinSupportLoginURL'] | [0].OutputValue, \
        Secret: Outputs[?OutputKey=='BespinOpsnowSecretKey'] | [0].OutputValue, \
        Access: Outputs[?OutputKey=='BespinOpsnowAccessKey'] | [0].OutputValue \
        }" \
    --output text \
    | awk '{print "BespinOpsnow,,"$1","$2","$3}' >> new_user_credentials.csv
