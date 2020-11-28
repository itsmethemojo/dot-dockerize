# .dckrz (dot dockerize)

micro framework to move all your build/test/compile steps in containers

## usecases

Right at the moment you start writing code in the programming language of your choice this framework can become handy.

### keep your localhost software list lean

Project 1 requires python version X and project 2 ruby version Y? As all your code will run in containers you don't need to care to install additional software, when trying out new stuff.

### Infrastructure as Code

While using .dckrz in your project you automatically define Docker images containing all needed dependencies. Those can be easily used to be run in any container based new environment later. Also setting up automatic tests with github actions or travis ci will be as easy as it can get.

### prototyping

Not having to worry about local software and dependencies will ease your decisions to try new programming languages to solve a problem.

## before you start

### required software

Since nothing comes for free, this framework does also have dependencies.

* [go-task](https://taskfile.org/#/installation?id=install-script)
* [docker](https://www.docker.com/get-started)

## get started

### 1. download the .dckrz Taskfile into your project root

```
touch Taskfile.yml && docker run -v $(pwd):/app -w /app buildpack-deps:curl bash -c "curl --output /dl 'https://raw.githubusercontent.com/itsmethemojo/dot-dockerize/master/Taskfile.yml' && cat /dl > Taskfile.yml"
```

### 2. init .dckrz in your project
```
task dz:init
```

### 3. create a new script
```
TARGET_NAME=lint task dz:add
```

### 4. configure your new script

#### 4.1 Script

in **scripts/lint.sh** is now a bash script template where you can add your commands

#### 4.2 Container

you can overload the container base image in .dckrz/config/dckrz.conf
```
lint_container=ruby
```
or point to an own Dockerfile to be used in your project
```
lint_dockerfile=.dckrz/config/docker/lint/Dockerfile
```

### 5. use your new task
```
task lint
```

## testing .dckrz

this might be interesting to see if .dckrz runs on your OS

```
task dz:test
```
additional tests cli output will be stored in `tests/debug`
