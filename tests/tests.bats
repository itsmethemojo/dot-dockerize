#!/usr/bin/env bats

function setup {
  find . -mindepth 1 -delete
  # copy Taskfile as starting point
  cp ../../Taskfile.yml .
  # if exists copy config data for the current test case
  cp -r ../data/$BATS_TEST_NUMBER/* . 2>/dev/null || :
  cp -r ../data/$BATS_TEST_NUMBER/.* . 2>/dev/null || :
}

function teardown {
  echo $output > ../debug/$BATS_TEST_NUMBER.log
  find . -mindepth 1 -delete
}

#1
@test "task dz:add without previous task dz:init fails and throws missing install error" {
  run $TASK_BINARY dz:add
  [ "$status" -eq 1 ]
  [ "$(echo $output | grep 'Important files missing. DCKRZE seems not be installed. Run "task dz:init" to fix that.' | wc -l)" = "1" ]
}

#2
@test "task dz:version without previous task dz:init fails and throws missing install error" {
  run $TASK_BINARY dz:version
  [ "$status" -eq 1 ]
  [ "$(echo $output | grep 'Important files missing. DCKRZE seems not be installed. Run "task dz:init" to fix that.' | wc -l)" = "1" ]
}

#3
@test "task dz:init succeeds. version is printed, folder structure is created" {
  run $TASK_BINARY dz:init
  [ "$status" -eq 0 ]
  [ "$(echo $output | grep '.dckrz Version:' | wc -l)" = "1" ]
  [ "$(ls -1 .dckrz/ | tr '\n' _)" = "config_tmp_" ]
  [ "$(ls -1 .dckrz/config/ | tr '\n' _)" = "docker_tasks.env_" ]
  [ "$(cat .gitignore)" = "/.dckrz/tmp/" ]
}

#4
@test "task dz:add without name parameter fails" {
  run $TASK_BINARY dz:init dz:add
  [ "$status" -eq 1 ]
  [ "$(echo $output | grep 'missing Parameter name! Usage: NAME="foo_bar" task dz:add' | wc -l)" = "1" ]
}

#5
@test "task dz:init task-name-that-does-not-exist fails" {
  run $TASK_BINARY task-name-that-does-not-exist
  [ "$status" -eq 1 ]
}

#6
@test "NAME=first_task task dz:add succeeds. first_task.sh was created" {
  run echo "$($TASK_BINARY dz:init && NAME=first_task $TASK_BINARY dz:add && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  # since bats can't handle parameters before the runner, this adds the response code to the output to be checked
  [ "$(ls -1 .dckrz/scripts | tr '\n' _)" = "first_task.sh_" ]
}

#7
@test "reinstall with task dz:init succeeds, .gitignore content as expected after reinstall" {
  run $TASK_BINARY dz:init dz:init
  [ "$status" -eq 0 ]
  [ "$(cat .gitignore)" = "/.dckrz/tmp/" ]
}

#8
@test "running task first_task succeeds. version and duration is printed" {
  run echo "$($TASK_BINARY dz:init && NAME=first_task $TASK_BINARY dz:add && $TASK_BINARY first_task && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep '.dckrz Version:' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'Duration:' | wc -l)" = "1" ]
  [ "$(echo $output | grep ok | wc -l)" = "1" ]
}

#9
@test "running task ruby fails because default container has no ruby installed" {
  run echo "$($TASK_BINARY dz:init && $TASK_BINARY ruby || echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "0" ]
  [ "$(echo $output | grep 'i am running ruby' | wc -l)" = "0" ]
}

#10
@test "running task ruby succeded because now the configured ruby container is used" {
  run echo "$($TASK_BINARY dz:init && $TASK_BINARY ruby && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'i am running ruby' | wc -l)" = "1" ]
}

#11
@test "VERSION=0.5 task dz:init succeeds. printed Version is 0.5. version is also in Taskfile.yml" {
  run echo "$(VERSION=0.5 $TASK_BINARY dz:init && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep '.dckrz Version: 0.5' | wc -l)" = "1" ]
  [ "$(cat Taskfile.yml | grep '#DCKRZ_VERSION: 0.5' | wc -l)" = "1" ]
}

#12
@test "task dz:init will reset modified Taskfile.yml" {
  run echo "$($TASK_BINARY dz:init && echo "#modified line" >> Taskfile.yml && $TASK_BINARY dz:init && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(cat Taskfile.yml | grep '#modified line' | wc -l)" = "0" ]
}

#13
@test "task dz:init will clear tmp folder" {
  run echo "$($TASK_BINARY dz:init && touch .dckrz/tmp/FILE && $TASK_BINARY dz:init && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(ls -1 .dckrz/tmp/FILE | tr '\n' _)" != ".dckrz/tmp/FILE_" ]
}

#14
@test "running task my-ruby prints content of my-file from the my-ruby Dockerfile created container" {
  run echo "$($TASK_BINARY dz:init && $TASK_BINARY my-ruby && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'my-file-content' | wc -l)" = "1" ]
}
