#!/usr/bin/env bats

@test "make add-task name=first-task (without previous install throws missing install error)" {
  run make add-task name=first-task TEST_ENVIRONMENT_PARAMS=
  [ "$status" -eq 2 ]
}

@test "make install-buildpack" {
  run make install-buildpack TEST_ENVIRONMENT_PARAMS=
  [ "$status" -eq 0 ]
}

@test "buildpack folder content" {
  run ls -1 buildpack/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "config" ]
  [ "${lines[1]}" = "tmp" ]
}

@test "buildpack/config folder content" {
  run ls -1 buildpack/config/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "docker" ]
  [ "${lines[1]}" = "tasks.env" ]
}

@test "VERSION file creation" {
  run ls -1 buildpack/tmp/VERSION
  [ "$status" -eq 0 ]
  [ "$output" = "buildpack/tmp/VERSION" ]
}

@test ".gitignore creation" {
  run cat .gitignore
  [ "$status" -eq 0 ]
  [ "$output" = "/buildpack/tmp/" ]
}

#TODO test version output, howto test tags on master?
# maybe switch to print branch and version


@test "make add-task name=first-task" {
  run make add-task name=first-task TEST_ENVIRONMENT_PARAMS=
  [ "$status" -eq 0 ]
}

#TODO test version output

#TODO test missing parameter

@test "first-task.sh was created" {
  run ls buildpack/scripts/
  [ "$status" -eq 0 ]
  [ "$output" = "first-task.sh" ]
}

@test "make install-buildpack (reinstall)" {
  run make install-buildpack TEST_ENVIRONMENT_PARAMS=
  [ "$status" -eq 0 ]
}

@test "VERSION file creation after reinstall" {
  run ls -1 buildpack/tmp/VERSION
  [ "$status" -eq 0 ]
  [ "$output" = "buildpack/tmp/VERSION" ]
}

@test ".gitignore content after reinstall" {
  run cat .gitignore
  [ "$status" -eq 0 ]
  [ "$output" = "/buildpack/tmp/" ]
}

@test "make first-task" {
  run make first-task
  [ "$status" -eq 0 ]
  [ "${lines[4]}" = "ok" ]
}

#TODO test version output

@test "make add-task name=second-task" {
  run make add-task name=second-task TEST_ENVIRONMENT_PARAMS=
  [ "$status" -eq 0 ]
}

@test "make task-that-does-not-exist (throws non existing task error)" {
  run make task-that-does-not-exist TEST_ENVIRONMENT_PARAMS=
  [ "$status" -eq 2 ]
}
