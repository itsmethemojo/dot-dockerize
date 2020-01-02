# buildpack

## required software

* [go-task](https://taskfile.org/#/installation?id=install-script)
* docker

## why using buildpack?

### don't install software local
When working with multiple projects, keeping up with all the required software running locally gets harder and harder. Different projects require different node/ruby/php/whatever versions? Things like this shouldn't eat your time.

### Infrastructure as Code
As you define the software dependencies of all your tasks in Dockerfile definitions, you have all your needed software stack well defined for moving to a ci system or production environment later.

### rapid prototyping with new programming languages
I am language agnostic and love to try new things. Containerize your application from the beginning will help you to get faster results

## does buildpack run on my system?
Currently it is fully tested on ubuntu linux, therefore i am pretty sure there will be no trouble to run it on other linux distributions having bash

I will look into testing it on mac os and windows


## howto use buildpack

### 1. download the buildpack Taskfile into your project root

```
# with wget
wget https://raw.githubusercontent.com/itsmethemojo/buildpack/master/Taskfile.yml

# or with curl
curl https://raw.githubusercontent.com/itsmethemojo/buildpack/master/Taskfile.yml --output Taskfile.yml
```

### 2. install buildpack
```
task init
```

### 3. setup a custom task
```
name=mytask task add
```

### 4. configure your custom task

#### 4.1 Script

in **scripts/mytask.sh** is now a bash script template where you can add your commands

#### 4.2 Container

you can overload the container base image in buildpack/config/tasks.env
```
mytask_container=ruby
```
or point to an own Dockerfile to be used in your project
```
mytask_dockerfile=buildpack/config/docker/mytask/Dockerfile
```

### 5. use your new task
```
task mytask
```
