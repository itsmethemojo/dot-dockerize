BUILDPACK_REPOSITORY = https://github.com/itsmethemojo/buildpack.git
BUILDPACK_FOLDER = buildpack
CONFIG_FOLDER = $(BUILDPACK_FOLDER)/config
BUILDPACK_TMP_FOLDER = $(BUILDPACK_FOLDER)/tmp
MAKEFILES_FOLDER = $(BUILDPACK_TMP_FOLDER)/makefiles
BASH_SCRIPT_TEMPLATE = $(BUILDPACK_TMP_FOLDER)/bash/templates/run-task.sh
TASK_TARGET_TEMPLATE = $(BUILDPACK_TMP_FOLDER)/makefiles/templates/target-to-run-task.Makefile
SCRIPTS_FOLDER = $(BUILDPACK_FOLDER)/scripts
BRANCH ?= master

ifeq ($(findstring _,$(MAKECMDGOALS)),_)
$(error target $(MAKECMDGOALS) is private)
endif

# check for missing buildpack tmp folder for every target but install-buildpack
ifneq ($(findstring install-buildpack,$(MAKECMDGOALS)),install-buildpack)
ifeq (,$(wildcard ./$(BASH_SCRIPT_TEMPLATE)))
$(error Important files missing. Buildpack seems not be installed. Run make install-buildpack to fix that.)
endif
endif

.PHONY: install-buildpack
install-buildpack: _download-buildpack _create-config-files _update-gitignore _update-makefile

$(info $(TEST_ENVIRONMENT))

.PHONY: _download-buildpack
_download-buildpack:
	$(info download current version of buildpack)
	@rm -rf $(BUILDPACK_TMP_FOLDER)
	@mkdir -p $(BUILDPACK_TMP_FOLDER)
ifeq ($(TEST_ENVIRONMENT),local)
	@cp -R $(BUILDPACK_FOLDER)/../../../makefiles $(BUILDPACK_TMP_FOLDER)
	@cp -R $(BUILDPACK_FOLDER)/../../../bash $(BUILDPACK_TMP_FOLDER)
	@cp $(BUILDPACK_FOLDER)/../../../Makefile $(BUILDPACK_TMP_FOLDER)/Makefile
	@echo TEST_ENVIRONMENT > $(BUILDPACK_TMP_FOLDER)/VERSION
else
	@docker run -v $$(pwd)/$(BUILDPACK_TMP_FOLDER):/downloads buildpack-deps bash -c "git clone -b $(BRANCH) --depth 1 $(BUILDPACK_REPOSITORY) /downloads &> /dev/null && git ls-remote /downloads | grep 'refs/tags' | sort -r | grep -o '[^\/]*$$' | head -1 > /downloads/VERSION && rm -r /downloads/.git && chmod -R 777 /downloads"
endif
ifneq ($(BRANCH),master)
	@echo $(BRANCH) > $(BUILDPACK_TMP_FOLDER)/VERSION
endif

.PHONY: _print-version
_print-version:
	@echo buildpack version: $$(cat $(BUILDPACK_TMP_FOLDER)/VERSION)

.PHONY: add-task
add-task: _create-task _update-makefile

.PHONY: _create-task
_create-task:
ifeq ($(name),)
	$(error missing Parameter name! Usage: make add-task name="my-task")
endif
	$(info adding new task: $(name))
	@mkdir -p $(SCRIPTS_FOLDER)
	@touch $(SCRIPTS_FOLDER)/$(name).sh
	@chmod +x $(SCRIPTS_FOLDER)/$(name).sh
	@cat $(BASH_SCRIPT_TEMPLATE) >> $(SCRIPTS_FOLDER)/$(name).sh

.PHONY: _create-config-files
_create-config-files:
	$(info create $(CONFIG_FOLDER) files if not existing)
	@mkdir -p $(CONFIG_FOLDER)/docker
	@touch $(CONFIG_FOLDER)/tasks.env

.PHONY: _update-makefile
_update-makefile: _copy-makefile _add-dynamic-targets-to-makefile _print-version
	$(info update MAKEFILE to newest version)

.PHONY: _copy-makefile
_copy-makefile:
	cat $(BUILDPACK_TMP_FOLDER)/Makefile > Makefile

.PHONY: _add-dynamic-targets-to-makefile
_add-dynamic-targets-to-makefile:
	for SCRIPT_FILE in $$(ls -1 $(SCRIPTS_FOLDER)  2>/dev/null | sed -e 's/\..*$$//'); do cat $(TASK_TARGET_TEMPLATE) | sed "s/__TASKNAME__/$$SCRIPT_FILE/g" >> Makefile; done

.PHONY: _update-gitignore
_update-gitignore:
	$(info update .gitignore to ignore files in buildpack folder)
	@if [ ! -f .gitignore ]; then echo "/$(BUILDPACK_TMP_FOLDER)/" > .gitignore; fi
	@if [ "$$(grep "/$(BUILDPACK_TMP_FOLDER)/" .gitignore | wc -l)" = "0" ]; then echo "/$(BUILDPACK_TMP_FOLDER)/" >> .gitignore; fi
