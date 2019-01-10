#!/bin/bash

ABORT=0

if [ -z "$1" ]
  then
    ABORT=1
fi

ENVIRONMENT=$1
BRANCH_NAME=$2
TEST_ENVIRONMENT_PARAMS="TEST_ENVIRONMENT=local"

if [ "$ENVIRONMENT" == "branch" ]
  then
    TEST_ENVIRONMENT_PARAMS="BRANCH=$BRANCH_NAME"
    if [ -z "$2" ]
      then
        ABORT=1
    fi
fi

if [ "$ABORT" -eq 1 ]
  then
    echo "Usage: test.sh ENVIRONMENT [BRANCH_NAME]"
    echo "available environments: local, branch"
    exit 1
fi

TEST_DIR=$(dirname "$(readlink -f "$0")")

cd $TEST_DIR

# download test software
if [ ! -d "$TEST_DIR/bats" ]; then
  docker run -v $(pwd)/bats:/bats buildpack-deps bash -c "git clone --depth 1 https://github.com/sstephenson/bats.git /bats &> /dev/null && chmod -R 777 /bats"
fi

# cleanup
mkdir -p $TEST_DIR/tmp
rm -r $TEST_DIR/tmp/* &> /dev/null

# copy starting point
cp $TEST_DIR/../Makefile $TEST_DIR/tmp/
cat $TEST_DIR/tests.bats | sed "s/TEST_ENVIRONMENT_PARAMS=/$TEST_ENVIRONMENT_PARAMS/g" > $TEST_DIR/tmp/tests.bats

# access context of make file
cd $TEST_DIR/tmp

$TEST_DIR/bats/bin/bats $TEST_DIR/tmp/tests.bats


# cleanup
rm -r $TEST_DIR/tmp &> /dev/null
