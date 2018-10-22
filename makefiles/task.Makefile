PROJECT_DIR = $(realpath $(dir $(lastword $(MAKEFILE_LIST)))../../)

CONTAINER_NAME = $(shell grep -e "$(task)_container=" $(PROJECT_DIR)/buildpack-config/tasks.env | grep -o -e '[^=]*$$')
ifeq ($(CONTAINER_NAME),)
CONTAINER_NAME = buildpack-deps
endif

DOCKERFILE =
DOCKERFILE_FOLDER =
DOCKERFILE_PATH = $(shell grep -e "$(task)_dockerfile=" $(PROJECT_DIR)/buildpack-config/tasks.env | grep -o -e '[^=]*$$')
ifneq ($(DOCKERFILE_PATH),)
DOCKERFILE = $(PROJECT_DIR)/$(DOCKERFILE_PATH)
DOCKERFILE_FOLDER = $(dir $(DOCKERFILE_PATH))
CONTAINER_NAME = buildpack-task-$(task)
endif

$(info $(DOCKERFILE_FOLDER) $(DOCKERFILE))
DIR_IN_CONTAINER = /container-$(task)
CONTAINER_MOUNT_PARAMETERS = -v $(PROJECT_DIR):$(DIR_IN_CONTAINER)

.PHONY: all
all: main

.PHONY: main
ifeq ($(wildcard /.dockerenv),)
ifneq ($(DOCKERFILE),)
main: build-container
endif
main:
	docker run $(CONTAINER_MOUNT_PARAMETERS) $(CONTAINER_NAME) make -f $(DIR_IN_CONTAINER)/buildpack/makefiles/task.Makefile task=$(task)
else
main: container-main
endif

.PHONY: build-container
build-container:
	docker build -t $(CONTAINER_NAME) -f $(DOCKERFILE) $(DOCKERFILE_FOLDER)

.PHONY: container-main
container-main:
	#$(call create_notification_data)
	$(PROJECT_DIR)/scripts/$(task).sh



# create all data needed to set github status
