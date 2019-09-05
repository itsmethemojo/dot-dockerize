#!/usr/bin/env bats

# TODO left things to test
# building and using a custom container
# check install abort on every target but init


function setup {
  find -mindepth 1 -delete
  # copy Taskfile as starting point
  cp ../../Taskfile.yml .
  # if exists copy config data for the current test case
  cp -r ../data/$BATS_TEST_NUMBER/* . 2>/dev/null || :
}

function teardown {
  find -mindepth 1 -delete
}

@test "task add without previous install fails and throws missing install error" {
  run task add
  [ "$status" -eq 1 ]
  [ "$(echo $output | grep 'Important files missing. Buildpack seems not be installed. Run "task init" to fix that.' | wc -l)" = "1" ]
}

@test "task init succeeds. version is printed, folder structure is created, VERSION file is created" {
  run task init
  [ "$status" -eq 0 ]
  [ "$(echo $output | grep 'Version:' | wc -l)" = "1" ]
  [ "$(ls -1 buildpack/ | tr '\n' _)" = "config_tmp_" ]
  [ "$(ls -1 buildpack/config/ | tr '\n' _)" = "docker_tasks.env_" ]
  [ "$(ls -1 buildpack/tmp/VERSION | tr '\n' _)" = "buildpack/tmp/VERSION_" ]
  [ "$(cat .gitignore)" = "/buildpack/tmp/" ]
}

@test "task add without name parameter fails" {
  run task init add
  [ "$status" -eq 1 ]
  [ "$(echo $output | grep 'missing Parameter name! Usage: name="my-task" task add' | wc -l)" = "1" ]
}

@test "task init task-name-that-does-not-exist fails" {
  run task task-name-that-does-not-exist
  [ "$status" -eq 1 ]
}

@test "name=first-task task add succeeds. first-task.sh was created" {
  run echo "$(BRANCH=$BRANCH task init && name=first-task task add && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  # since bats can't handle parameters before the runner, this adds the response code to the output to be checked
  [ "$(ls -1 buildpack/scripts | tr '\n' _)" = "first-task.sh_" ]
}

@test "reinstall with task init succeeds, VERSION file exists, .gitignore content as expected after reinstall" {
  run task init init
  [ "$status" -eq 0 ]
  [ "$(ls -1 buildpack/tmp/VERSION | tr '\n' _)" = "buildpack/tmp/VERSION_" ]
  [ "$(cat .gitignore)" = "/buildpack/tmp/" ]
}

# this test may fail when the image is not pulled yet and so the tested statements are not in the defined output lines
# is reproducable by dropping the buildpack-deps container
# rerun will succeed
# maybe switch to output and grep
@test "running task first-task succeeds. version and duration is printed" {
  run echo "$(BRANCH=$BRANCH task init && name=first-task task add && task first-task && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'Version:' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'Duration:' | wc -l)" = "1" ]
  [ "$(echo $output | grep ok | wc -l)" = "1" ]
}

@test "running task ruby fails because default container has no ruby installed" {
  run  echo "$(BRANCH=$BRANCH task init && task ruby || echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "0" ]
  [ "$(echo $output | grep 'i am running ruby' | wc -l)" = "0" ]
}

@test "running task ruby succeded because now the configured ruby container is used" {
  run echo "$(BRANCH=$BRANCH task init && task ruby && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'i am running ruby' | wc -l)" = "1" ]
}

@test "BRANCH=0.5 task init succeeds. printed Version is 0.5. version is also in Taskfile.yml" {
  run echo "$(BRANCH=0.5 task init && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'Version: 0.5' | wc -l)" = "1" ]
  [ "$(cat Taskfile.yml | grep '#BUILDPACK VERSION: 0.5' | wc -l)" = "1" ]
}

@test "task init will reset modified Taskfile.yml" {
  run echo "$(BRANCH=$BRANCH task init && echo "#modified line" >> Taskfile.yml && BRANCH=$BRANCH task init && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(cat Taskfile.yml | grep '#modified line' | wc -l)" = "0" ]
}

@test "task init will clear tmp folder" {
  run echo "$(BRANCH=$BRANCH task init && touch buildpack/tmp/FILE && BRANCH=$BRANCH task init && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(ls -1 buildpack/tmp/FILE | tr '\n' _)" != "buildpack/tmp/FILE_" ]
}
