#!/usr/bin/env bats

function setup {
  find . -mindepth 1 -delete
  # copy Taskfile as starting point
  cp ../../Taskfile.yml .
  # if exists copy config data for the current test case
  cp -r ../data/$BATS_TEST_NUMBER/* . 2>/dev/null || :
}

function teardown {
  echo $output > ../debug/$BATS_TEST_NUMBER.log
  find . -mindepth 1 -delete
}

#1
@test "task add without previous task init fails and throws missing install error" {
  run task add
  [ "$status" -eq 1 ]
  [ "$(echo $output | grep 'Important files missing. Buildpack seems not be installed. Run "task init" to fix that.' | wc -l)" = "1" ]
}

#2
@test "task version without previous task init fails and throws missing install error" {
  run task version
  [ "$status" -eq 1 ]
  [ "$(echo $output | grep 'Important files missing. Buildpack seems not be installed. Run "task init" to fix that.' | wc -l)" = "1" ]
}

#3
@test "task init succeeds. version is printed, folder structure is created" {
  run task init
  [ "$status" -eq 0 ]
  [ "$(echo $output | grep 'Buildpack Version:' | wc -l)" = "1" ]
  [ "$(ls -1 buildpack/ | tr '\n' _)" = "config_tmp_" ]
  [ "$(ls -1 buildpack/config/ | tr '\n' _)" = "docker_tasks.env_" ]
  [ "$(cat .gitignore)" = "/buildpack/tmp/" ]
}

#4
@test "task add without name parameter fails" {
    run task init add
  [ "$status" -eq 1 ]
  [ "$(echo $output | grep 'missing Parameter name! Usage: name="my-task" task add' | wc -l)" = "1" ]
}

#5
@test "task init task-name-that-does-not-exist fails" {
    run task task-name-that-does-not-exist
  [ "$status" -eq 1 ]
}

#6
@test "name=first_task task add succeeds. first_task.sh was created" {
    run echo "$(VERSION=$VERSION task init && name=first_task task add && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  # since bats can't handle parameters before the runner, this adds the response code to the output to be checked
  [ "$(ls -1 buildpack/scripts | tr '\n' _)" = "first_task.sh_" ]
}

#7
@test "reinstall with task init succeeds, .gitignore content as expected after reinstall" {
    run task init init
  [ "$status" -eq 0 ]
  [ "$(cat .gitignore)" = "/buildpack/tmp/" ]
}

#8
@test "running task first_task succeeds. version and duration is printed" {
    run echo "$(VERSION=$VERSION task init && name=first_task task add && task first_task && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'Buildpack Version:' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'Duration:' | wc -l)" = "1" ]
  [ "$(echo $output | grep ok | wc -l)" = "1" ]
}

#9
@test "running task ruby fails because default container has no ruby installed" {
    run  echo "$(VERSION=$VERSION task init && task ruby || echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "0" ]
  [ "$(echo $output | grep 'i am running ruby' | wc -l)" = "0" ]
}

#10
@test "running task ruby succeded because now the configured ruby container is used" {
    run echo "$(VERSION=$VERSION task init && task ruby && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'i am running ruby' | wc -l)" = "1" ]
}

#11
@test "VERSION=0.5 task init succeeds. printed Version is 0.5. version is also in Taskfile.yml" {
    run echo "$(VERSION=0.5 task init && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'Buildpack Version: 0.5' | wc -l)" = "1" ]
  [ "$(cat Taskfile.yml | grep '#BUILDPACK_VERSION: 0.5' | wc -l)" = "1" ]
}

#12
@test "task init will reset modified Taskfile.yml" {
    run echo "$(VERSION=$VERSION task init && echo "#modified line" >> Taskfile.yml && VERSION=$VERSION task init && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(cat Taskfile.yml | grep '#modified line' | wc -l)" = "0" ]
}

#13
@test "task init will clear tmp folder" {
    run echo "$(VERSION=$VERSION task init && touch buildpack/tmp/FILE && VERSION=$VERSION task init && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(ls -1 buildpack/tmp/FILE | tr '\n' _)" != "buildpack/tmp/FILE_" ]
}

#14
@test "running task my-ruby prints content of my-file from the my-ruby Dockerfile created container" {
    run echo "$(VERSION=$VERSION task init && task my-ruby && echo FINAL_EXIT_CODE=$?)"
  [ "$(echo $output | grep 'FINAL_EXIT_CODE=0' | wc -l)" = "1" ]
  [ "$(echo $output | grep 'my-file-content' | wc -l)" = "1" ]
}
