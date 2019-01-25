# buildpack

## Required Software

* [go-task](https://taskfile.org/#/installation?id=install-script)

## howto use buildpack

### 1. download the buildpack installer into your project root

```
# with wget
wget https://raw.githubusercontent.com/itsmethemojo/buildpack/master/Taskfile.yml

# or with curl
curl https://raw.githubusercontent.com/itsmethemojo/buildpack/master/Taskfile.yml --output Taskfile.yml
```

### 2. install buildpack
```
task install-buildpack
```

### 3. setup a custom task
```
name=mytask task add-task
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

### 5. use you new task
```
task mytask
```
