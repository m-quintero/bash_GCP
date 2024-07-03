# Script Name: gcp_instance_search_v1.2.sh
# Version: 1.2
# Author: michael.quintero@rackspace.com
# Pre-requisites: 4 things needed! A GCP account (be sure to authenticate), Bash, gcloud (https://cloud.google.com/sdk/docs/install#linux), jq (https://www.scaler.com/topics/linux-jq/)
# Description: This script will help automate searching for an instance_id through all projects within a GCP account
 
#!/bin/bash
 
# Setting that instance flag. Without it, ya ain't going nowhere! :O
usage() {
  echo "Usage: $0 -i instance_id"
  exit 1
}
 
while getopts ":i:" opt; do
  case ${opt} in
    i )
      INSTANCE_ID=$OPTARG
      ;;
    \? )
      usage
      ;;
  esac
done
 
# Need to have set that instance id with the -i flag while running this script
if [ -z "$INSTANCE_ID" ]; then
  usage
fi
 
# Yep, we're moving through all projects. Noise will be generated in the logs! lol
projects=$(gcloud projects list --format="value(projectId)")
 
# Just a simple for-loop through all the projects. This may take a while and you may run into PERMISSION DENIED errors, either due to the Compute Engine API not being enabled or whatever
for project in $projects; do
  instances=$(gcloud compute instances list --project=$project --format="json")
  if echo "$instances" | jq -e ".[] | select(.id == \"$INSTANCE_ID\")" > /dev/null; then
    echo "Project: $project"
    echo "$instances" | jq -r ".[] | select(.id == \"$INSTANCE_ID\") | [ .name, .zone, .id ] | @tsv" | column -t
  fi
done
