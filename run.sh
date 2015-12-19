#!/bin/bash

set -ex # exit with nonzero exit code if anything fails

source vars.sh


# Note: the files grampsXX_build.txt identify the last build
# The reports are regenerated only when the grampsXX_build.txt file changes


##############################################
### Retrieve the last generated report list
##############################################

mkdir -p downloads
for file in report_list.js report_list.json report_version.js report_version.json; do
	curl -o downloads/$file https://raw.githubusercontent.com/$EXAMPLES_REPO_SLUG/gh-pages/$file
	if [ -f downloads/$file ]; then
		cp downloads/$file site/$file
	fi
done


##############################################
###  4.2
##############################################

$WORKON_42
echo "build id" > downloads/gramps42_build.txt
curl -o downloads/gramps42_build.txt https://raw.githubusercontent.com/$EXAMPLES_REPO_SLUG/gh-pages/gramps42_build.txt
cat downloads/gramps42_build.txt

mkdir -v -p site/gramps42/gramps
mkdir -v -p site/gramps42/addons
$PYTHON_42 run_reports.py 42


##############################################
###  5.0
##############################################

$WORKON_50
mkdir -p downloads
echo "build id" > downloads/gramps50_build.txt
curl -o downloads/gramps50_build.txt https://raw.githubusercontent.com/$EXAMPLES_REPO_SLUG/gh-pages/gramps50_build.txt
cat downloads/gramps50_build.txt

mkdir -v -p site/gramps50/gramps
mkdir -v -p site/gramps50/addons
$PYTHON_50 run_reports.py 50
