#!/usr/bin/env bats

function setup {
  find . -mindepth 1 -delete
  # copy Taskfile as starting point
  cp ../../Taskfile.yml .
  # if exists copy config data for the current test case
  cp -r ../data/$BATS_TEST_DESCRIPTION/* . 2>/dev/null || :
  cp -r ../data/$BATS_TEST_DESCRIPTION/.* . 2>/dev/null || :
}

function teardown {
  echo $output > ../debug/$BATS_TEST_DESCRIPTION.log
  find . -mindepth 1 -delete
}

# task dz:add without previous task dz:init fails and throws missing install error
@test "no-debug-stmts-in-taskfile" {
  run echo 1
  [ "$(cat Taskfile.yml | grep 'silent: false' | wc -l)" = "0" ]
}

# task dz:add without previous task dz:init fails and throws missing install error
@test "dz-add-without-previous-dz-init" {
  run $TASK_BINARY dz:add
  [ "$status" -eq 1 ]
  [ "$(echo $output | grep 'Important files missing. DCKRZE seems not be installed. Run "task dz:init" to fix that.' | wc -l)" = "1" ]
}

# task dz:version without previous task dz:init fails and throws missing install error
@test "dz-version-without-previous-dz-init" {
  run $TASK_BINARY dz:version
  [ "$status" -eq 1 ]
  [ "$(echo $output | grep 'Important files missing. DCKRZE seems not be installed. Run "task dz:init" to fix that.' | wc -l)" = "1" ]
}

# task dz:init task-name-that-does-not-exist fails
@test "run-task-that-name-does-not-exist" {
  run $TASK_BINARY task-name-that-does-not-exist
  [ "$status" -eq 1 ]
}

# task dz:init succeeds. version is printed, folder structure is created
@test "dz-init" {
  run $TASK_BINARY dz:init
  [ "$status" -eq 0 ]
  [ "$(echo $output | grep '.dckrz Version:' | wc -l)" = "1" ]
  [ "$(ls -1 .dckrz/ | tr '\n' _)" = "config_tmp_" ]
  [ "$(ls -1 .dckrz/config/ | tr '\n' _)" = "dckrz.conf_docker_" ]
  [ "$(cat .gitignore | tr '\n' _)" = "! /.dckrz/_/.dckrz/tmp/_" ]
}

# task dz:init with existing .gitignore (variant 1) adds only lines needed
@test "dz-init-gitignore-variant-1" {
  run $TASK_BINARY dz:init
  [ "$status" -eq 0 ]
  [ "$(cat .gitignore | tr '\n' _)" = "/.dckrz/tmp/_! /.dckrz/_" ]
}

# task dz:init with existing .gitignore (variant 2) adds only lines needed
@test "dz-init-gitignore-variant-2" {
  run $TASK_BINARY dz:init
  [ "$status" -eq 0 ]
  [ "$(cat .gitignore | tr '\n' _)" = "! /.dckrz/_/.dckrz/tmp/_" ]
}

# task dz:init with existing .gitignore (variant 3) adds only lines needed
@test "dz-init-gitignore-variant-3" {
  run $TASK_BINARY dz:init
  [ "$status" -eq 0 ]
  [ "$(cat .gitignore | tr '\n' _)" = "/ignore-this_/.dckrz/tmp/_/ignore-that_! /.dckrz/_" ]
}

# task dz:init without existing .gitignore (variant 4) adds only lines needed
@test "dz-init-gitignore-variant-4" {
  run $TASK_BINARY dz:init
  [ "$status" -eq 0 ]
  [ "$(cat .gitignore | tr '\n' _)" = "! /.dckrz/_/.dckrz/tmp/_" ]
}

# reinstall with task dz:init succeeds, .gitignore content as expected after reinstall
@test "dz-init-reinstall" {
  run $TASK_BINARY dz:init dz:init
  [ "$status" -eq 0 ]
  [ "$(cat .gitignore | tr '\n' _)" = "! /.dckrz/_/.dckrz/tmp/_" ]
}

# task dz:init will clear tmp folder
@test "dz-init-clears-tmp-folder" {
  run echo "$($TASK_BINARY dz:init && touch .dckrz/tmp/FILE && $TASK_BINARY dz:init && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(ls -1 .dckrz/tmp/FILE | tr '\n' _)" != ".dckrz/tmp/FILE_" ]
}

# VERSION=0.8 task dz:init succeeds. printed Version is 0.8. version is also in Taskfile.yml
@test "dz-init-version-0-8" {
  run echo "$(VERSION=0.8 $TASK_BINARY dz:init && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep '.dckrz Version: 0.8' | wc -l)" = "1" ]
  [ "$(cat Taskfile.yml | grep '#DCKRZ_VERSION: 0.8' | wc -l)" = "1" ]
}

# task dz:init will reset modified Taskfile.yml
@test "dz-init-resets-taskfile" {
  run echo "$($TASK_BINARY dz:init && echo "#modified line" >> Taskfile.yml && $TASK_BINARY dz:init && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(cat Taskfile.yml | grep '#modified line' | wc -l)" = "0" ]
}

# dz:upgrade after VERSION=0.8 task dz:init
#TODO activate when 0.11 is available
@test "dz-upgrade-after-dz-init-version-0-10" {
  skip
  run echo "$(VERSION=0.10 $TASK_BINARY dz:init && $TASK_BINARY dz:upgrade && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(cat Taskfile.yml | grep '#DCKRZ_VERSION: 0.8' | wc -l)" = "0" ]
  [ "$(cat Taskfile.yml | grep '#DCKRZ_VERSION: ' | wc -l)" = "1" ]
}

# task dz:add without name parameter fails
@test "dz-add-without-name-parameter" {
  run $TASK_BINARY dz:init dz:add
  [ "$status" -eq 1 ]
  [ "$(echo $output | grep 'missing Parameter name! Usage: NAME="foo_bar" task dz:add' | wc -l)" = "1" ]
}

# NAME=first_task task dz:add succeeds. first_task.sh was created
@test "dz-add" {
  run echo "$($TASK_BINARY dz:init && NAME=first_task $TASK_BINARY dz:add && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  # since bats can't handle parameters before the runner, this adds the response code to the output to be checked
  [ "$(ls -1 .dckrz/scripts | tr '\n' _)" = "first_task.sh_" ]
}

# running task first_task succeeds. version and duration is printed
@test "running-first-task-after-dz-init-and-dz-add" {
  run echo "$($TASK_BINARY dz:init && NAME=first_task $TASK_BINARY dz:add && $TASK_BINARY first_task && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep '.dckrz Version:' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'Duration:' | wc -l)" = "1" ]
  [ "$(echo $output | grep ok | wc -l)" = "1" ]
}

# running task ruby fails because default container has no ruby installed
@test "ruby-without-configured-container" {
  run echo "$($TASK_BINARY dz:init && $TASK_BINARY ruby || echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "0" ]
  [ "$(echo $output | grep 'i am running ruby' | wc -l)" = "0" ]
}

# running task ruby succeded because now the configured ruby container is used
@test "ruby-with-configured-container" {
  run echo "$($TASK_BINARY dz:init && $TASK_BINARY ruby && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'i am running ruby' | wc -l)" = "1" ]
}

# running task my-ruby prints content of my-file from the my-ruby Dockerfile created container
@test "my-ruby-with-own-dockerfile" {
  run echo "$($TASK_BINARY dz:init && $TASK_BINARY my-ruby && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'my-file-content' | wc -l)" = "1" ]
}
