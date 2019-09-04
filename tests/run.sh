#!/bin/bash

BRANCH=_local_copy
if [ ! -z "$1" ]
  then
    BRANCH=$1
fi

TEST_DIR=$(dirname "$(readlink -f "$0")")

# download test software
if [ ! -d "$TEST_DIR/bats" ]; then
  docker run -v "$TEST_DIR/bats":/bats buildpack-deps bash -c \
  "git clone --depth 1 https://github.com/sstephenson/bats.git /bats &> /dev/null && chmod -R 777 /bats"
fi

mkdir -p $TEST_DIR/tmp

# run tests in context of taskfile
cd $TEST_DIR/tmp && \
export BRANCH="$BRANCH" && \
$TEST_DIR/bats/bin/bats $TEST_DIR/tests.bats
