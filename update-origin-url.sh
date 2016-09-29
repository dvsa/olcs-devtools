#!/bin/bash 

echo
echo "Iterate through sub-directories and update git origin url to new AWS"
echo

find -maxdepth 2 -type d -name .git | while read dir; do
  cd $dir
  cd ..
  pwd

  # to convert from AWS to skyscape
  NEW_REMOTE_URL=$(git remote -v | head -n1 | grep "git@[a-z.\/:\-]*" -o | sed s/repo.shd.ci.nonprod.dvsa.aws/gitlab.inf.mgt.mtpdvsa/)
  # to convert from skyscape to AWS
  #NEW_REMOTE_URL=$(git remote -v | head -n1 | grep "git@[a-z.\/:\-]*" -o | sed s/gitlab.inf.mgt.mtpdvsa/repo.shd.ci.nonprod.dvsa.aws/)
  echo " ->" $NEW_REMOTE_URL
  git remote set-url origin $NEW_REMOTE_URL
	if [ $? -ne 0 ]; then
		echo "Something went wrong"
		exit 1
	fi

	cd ..
done