#!/usr/bin/env bats


# TODO left things to test
# version output (on master showing most current tag)
# branch output
# building and using a custom container
# check install abort on every target but install
# test Taskfile update after install (maybe with modifying it before install)
# with reinstall all files will be deleted in tmp

@test "task add without previous install fails and throws missing install error" {
  run task add
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Important files missing. Buildpack seems not be installed. Run task install-buildpack to fix that." ]
}

@test "task install-buildpack succeeds" {
  run task install-buildpack
  [ "$status" -eq 0 ]
}

@test "buildpack folder content is created" {
  run ls -1 buildpack/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "config" ]
  [ "${lines[1]}" = "tmp" ]
}

@test "buildpack/config folder content is created" {
  run ls -1 buildpack/config/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "docker" ]
  [ "${lines[1]}" = "tasks.env" ]
}

@test "BRANCH file is created" {
  run ls -1 buildpack/tmp/BRANCH
  [ "$status" -eq 0 ]
  [ "$output" = "buildpack/tmp/BRANCH" ]
}

@test ".gitignore file is created" {
  run cat .gitignore
  [ "$status" -eq 0 ]
  [ "$output" = "/buildpack/tmp/" ]
}

@test "task add without name parameter fails" {
  run task add
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = 'missing Parameter name! Usage: name="my-task" task add' ]
}

@test "task task-name-that-does-not-exist fails" {
  run task task-name-that-does-not-exist
  [ "$status" -eq 1 ]
}

@test "name=first-task task add succeeds" {
  run echo "$(name=first-task task add && echo $?)"
  [ "${lines[2]}" == "0" ]
  # since bats can't handle parameters before the runner, this adds the response code to the output to be checked
}

@test "first-task.sh was created" {
  run ls buildpack/scripts/
  [ "$status" -eq 0 ]
  [ "$output" = "first-task.sh" ]
}

@test "reinstall with task install-buildpack succeeds" {
  run task install-buildpack
  [ "$status" -eq 0 ]
}

@test "BRANCH file is created after reinstall" {
  run ls -1 buildpack/tmp/BRANCH
  [ "$status" -eq 0 ]
  [ "$output" = "buildpack/tmp/BRANCH" ]
}

@test ".gitignore content as exprected after reinstall" {
  run cat .gitignore
  [ "$status" -eq 0 ]
  [ "$output" = "/buildpack/tmp/" ]
}

@test "running task first-task succeeds" {
  run task first-task
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "ok" ]
}

@test "name=ruby-task task add succeeds" {
  run echo "$(name=ruby-task task add && echo $?)"
  [ "${lines[2]}" == "0" ]
  # since bats can't handle parameters before the runner, this adds the response code to the output to be checked
}

@test "customize script for ruby task" {
  run echo $(echo -e "#!/bin/bash\n\nruby -e \"print 'i am running ruby'\"" > buildpack/scripts/ruby-task.sh && cat buildpack/scripts/ruby-task.sh | grep running)
  [ "${output}" == "ruby -e \"print 'i am running ruby'\"" ]
}

@test "running task ruby-task fails because default container has no ruby installed" {
  run task ruby-task
  [ "$status" -eq 1 ]
}

@test "configure ruby task to use ruby container" {
  run echo $(echo 'ruby-task_container=ruby' > buildpack/config/tasks.env && cat buildpack/config/tasks.env)
  [ "$output" == "ruby-task_container=ruby" ]
}

@test "running task ruby-task succeded because now the configured ruby container is used" {
  run task ruby-task
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "i am running ruby" ]
}
