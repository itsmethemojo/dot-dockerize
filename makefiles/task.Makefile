PROJECT_DIR = $(realpath $(dir $(lastword $(MAKEFILE_LIST)))../../../)

CONFIG_FOLDER =  $(PROJECT_DIR)/buildpack/config
CONFIG_FILE =  $(CONFIG_FOLDER)/tasks.env

SCRIPT_PATH = buildpack/scripts/$(task).sh

CONTAINER_NAME = $(shell grep -e "$(task)_container=" $(CONFIG_FILE) | grep -o -e '[^=]*$$')
ifeq ($(CONTAINER_NAME),)
CONTAINER_NAME = buildpack-deps
endif

DOCKERFILE =
DOCKERFILE_FOLDER =
DOCKERFILE_PATH = $(shell grep -e "$(task)_dockerfile=" $(CONFIG_FILE) | grep -o -e '[^=]*$$')
ifneq ($(DOCKERFILE_PATH),)
DOCKERFILE = $(PROJECT_DIR)/$(DOCKERFILE_PATH)
DOCKERFILE_FOLDER = $(dir $(DOCKERFILE_PATH))
CONTAINER_NAME = buildpack-task-$(task)
endif

DIR_IN_CONTAINER = /container-$(task)
CONTAINER_MOUNT_PARAMETERS = -v $(PROJECT_DIR):$(DIR_IN_CONTAINER)

.PHONY: all
all: run-task

.PHONY: run-task
# if there is no /.dockerenv this task is not started within a docker container
ifneq ($(wildcard /.dockerenv),)
# if DOCKERFILE is not empty the custom container must be build
ifneq ($(DOCKERFILE),)
run-task: build-container
endif
run-task:
	docker run $(CONTAINER_MOUNT_PARAMETERS) $(CONTAINER_NAME) bash $(DIR_IN_CONTAINER)/$(SCRIPT_PATH)
else
run-task:
	bash $(SCRIPT_PATH)
endif

.PHONY: build-container
build-container:
	docker build -t $(CONTAINER_NAME) -f $(DOCKERFILE) $(DOCKERFILE_FOLDER)
