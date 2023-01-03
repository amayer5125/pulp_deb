#!/usr/bin/env bash

# WARNING: DO NOT EDIT!
#
# This file was generated by plugin_template, and is managed by it. Please use
# './plugin-template --github pulp_deb' to update this file.
#
# For more info visit https://github.com/pulp/plugin_template

# make sure this script runs at the repo root
cd "$(dirname "$(realpath -e "$0")")"/../../..

set -euv

source .github/workflows/scripts/utils.sh

export PRE_BEFORE_SCRIPT=$PWD/.github/workflows/scripts/pre_before_script.sh
export POST_BEFORE_SCRIPT=$PWD/.github/workflows/scripts/post_before_script.sh

if [[ -f $PRE_BEFORE_SCRIPT ]]; then
  source $PRE_BEFORE_SCRIPT
fi

# Developers should be able to reproduce the containers with this config
echo "CI vars:"
tail -v -n +1 .ci/ansible/vars/main.yaml

# Developers often want to know the final pulp config
echo "PULP CONFIG:"
tail -v -n +1 .ci/ansible/settings/settings.* ~/.config/pulp_smash/settings.json

# Needed for some functional tests
cmd_prefix bash -c "echo '%wheel        ALL=(ALL)       NOPASSWD: ALL' > /etc/sudoers.d/nopasswd"
cmd_prefix bash -c "usermod -a -G wheel pulp"

SCENARIOS=("pulp" "performance" "azure" "gcp" "s3" "stream" "plugin-from-pypi" "generate-bindings" "lowerbounds")
if [[ " ${SCENARIOS[*]} " =~ " ${TEST} " ]]; then
  # Many functional tests require these
  cmd_prefix dnf install -yq lsof which
fi

if [[ "${REDIS_DISABLED:-false}" == true ]]; then
  cmd_prefix bash -c "s6-rc -d change redis"
  echo "The Redis service was disabled for $TEST"
fi

if [[ -f $POST_BEFORE_SCRIPT ]]; then
  source $POST_BEFORE_SCRIPT
fi
