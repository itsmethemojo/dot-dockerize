#!/bin/bash

VERSION=_test_local_copy
if [ ! -z "$1" ]
  then
    VERSION=$1
fi

TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# download test software
if [ ! -d "$TEST_DIR/bats" ]; then
  docker run -v "$TEST_DIR/bats":/bats buildpack-deps bash -c \
  "git clone --depth 1 https://github.com/sstephenson/bats.git /bats &> /dev/null && chmod -R 777 /bats"
fi

mkdir -p $TEST_DIR/tmp
rm -rf $TEST_DIR/debug || true
mkdir -p $TEST_DIR/debug

# run tests in context of taskfile
cd $TEST_DIR/tmp && \
export VERSION="$VERSION" && \
$TEST_DIR/bats/bin/bats $TEST_DIR/tests.bats
