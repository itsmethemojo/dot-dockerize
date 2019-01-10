# buildpack

### 1. download the buildpack installer into your project root

```
# with wget
wget https://raw.githubusercontent.com/itsmethemojo/buildpack/master/Makefile

# or with curl
curl https://raw.githubusercontent.com/itsmethemojo/buildpack/master/Makefile --output Makefile
```

### 2. install buildpack
```
make install-buildpack
```

### 3. setup a custom task
```
make add-task NAME=mytask
```

### 4. configure your custom task

#### 4.1 Script

in **scripts/mytask.sh** is now a bash script template where you can add your commands

#### 4.2 Container

you can overload the container base image in buildpack/config/tasks.env
```
mytask_container=ruby
```
or point to an own Dockerfile in your project
```
mytask_dockerfile=buildpack/config/docker/mytask/Dockerfile
```
