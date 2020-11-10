#!/bin/bash


set -e


#variables
export AWS_REGION="us-east-2"
export AWS_DEFAULT_OUTPUT=text
export LOGIN_ECR=$(aws ecr get-login --region us-east-1 --no-include-email)
REPOS="$(aws ecr describe-repositories --query '[repositories[*].repositoryName]' --output text)"
REPONAME="jangomart/jango-app"
TAG="$(git rev-parse --verify HEAD| cut -b 35-)"
USER=aaron #define in jenkins
REGID=785063031912
GIT_BRANCH="$(git name-rev --name-only HEAD | cut -f 3- -d '/')"

ECR_URI="785063031912.dkr.ecr.us-east-2.amazonaws.com"



$LOGIN_ECR

for i in  $REPOS;
#if repo name already exist exit, if not create the Repo in ecr registery
do
  if [ "$(echo $i)" == "$REPONAME" ]
   then
    echo $i

    echo "found repo $REPONAME"
break
fi
done

if [ "$(echo $i)" != "$REPONAME" ]
 then

  echo "$REPONAME was not found"
  echo "creating new repo $REPONAME .............."
aws ecr create-repository --repository-name $REPONAME

sleep 5

echo "$REPONAME is now available"
else
echo "done"
fi

# build docker image and push to ecr

# GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo "$(git rev-parse --abbrev-ref HEAD)"
sleep 5

VERSION='1.0.0'



docker build -t "${REPONAME}:latest" -f ./Dockerfile .

docker tag "${REPONAME}:latest" "${ECR_URI}/${REPONAME}:latest"
docker tag "${REPONAME}:latest" "${ECR_URI}/${REPONAME}:${TAG}"
docker tag "${REPONAME}:latest" "${ECR_URI}/${REPONAME}:${GIT_BRANCH}"

$LOGIN_ECR



docker push "${ECR_URI}/${REPONAME}:latest"
docker push "${ECR_URI}/${REPONAME}:${TAG}"
docker push "${ECR_URI}/${REPONAME}:${GIT_BRANCH}"


aws ecr set-repository-policy --registry-id $REGID --repository-name ${REPONAME} --policy-text '{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowCrossAccountPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::388633872430:root"
      },
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  ]
}'


echo "Your Image has been successfully built and Pushed to ECR"

echo "${ECR_URI}/${REPONAME}:latest"

docker rmi "${ECR_URI}/${REPONAME}:latest"
docker rmi "${ECR_URI}/${REPONAME}:${TAG}"
docker rmi "${ECR_URI}/${REPONAME}:${GIT_BRANCH}"

exit 0
