#!/bin/bash

set -e # Will exit if there is a error in the script
set -x # Will help you debugging



function display_usage() {
        cat <<EOF
Usage: $0
    [--region]

Arguments:
    --region                        The region of Instance to create on



EOF
  exit 1
}

function handle_parameters() {
	# Y ssh?
	region=""

	until [ -z $1 ]; do
      case $1 in
      --region )
        region=$2
        shift
        ;;
      esac
      shift
  done


  if  [ "$region" == "" ]; then
    echo "region is missing"
    display_usage
	fi
}

handle_parameters "$@"

  if [ "${region}" != "" ]; then
    terraform init
    terraform apply \
    - var region=${region}
  fi