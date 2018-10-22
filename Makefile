BUILDPACK_REPOSITORY = https://github.com/itsmethemojo/buildpack.git
BUILDPACK_FOLDER = buildpack
MAKEFILES_FOLDER = $(BUILDPACK_FOLDER)/makefiles
BASH_SCRIPT_TEMPLATE = $(BUILDPACK_FOLDER)/bash/templates/run-task.sh
TASK_TARGET_TEMPLATE = $(BUILDPACK_FOLDER)/makefiles/templates/target-to-run-task.Makefile
SCRIPTS_FOLDER = scripts
BRANCH ?= master

ifeq ($(findstring _,$(MAKECMDGOALS)),_)
$(error target $(MAKECMDGOALS) is private)
endif

.PHONY: install-buildpack
install-buildpack: _download-buildpack _create-config-files _update-gitignore _update-makefile

.PHONY: _download-buildpack
_download-buildpack:
	$(info download current version of buildpack)
	@rm -rf $(BUILDPACK_FOLDER)
	@docker run -v $$(pwd)/$(BUILDPACK_FOLDER):/downloads buildpack-deps bash -c "git clone -b $(BRANCH) --depth 1 $(BUILDPACK_REPOSITORY) /downloads &> /dev/null && git ls-remote /downloads | grep 'refs/tags' | sort -r | grep -o '[^\/]*$$' | head -1 > /downloads/VERSION && rm -r /downloads/.git && chmod -R 777 /downloads"
ifneq ($(BRANCH),master)
	@echo $(BRANCH) > $(BUILDPACK_FOLDER)/VERSION
endif

.PHONY: _print-version
_print-version:
	@echo buildpack version: $$(cat $(BUILDPACK_FOLDER)/VERSION)

# if a newer version of the buildpack will add targets and therefore scripts, this will create the additional needed scripts
.PHONY: add-task
add-task: _create-task _update-makefile

.PHONY: _create-task
_create-task:
	# add error handling if NAME var is missing or bad formatted
	@mkdir -p $(SCRIPTS_FOLDER)
	@touch $(SCRIPTS_FOLDER)/$(NAME).sh
	@chmod +x $(SCRIPTS_FOLDER)/$(NAME).sh
	@cat $(BASH_SCRIPT_TEMPLATE) >> $(SCRIPTS_FOLDER)/$(NAME).sh

.PHONY: _create-config-files
_create-config-files:
	$(info create buildpack-config files if not existing)
	@mkdir -p buildpack-config/docker
	@touch buildpack-config/tasks.env

.PHONY: _update-makefile
_update-makefile: _copy-makefile _add-dynamic-targets-to-makefile _print-version
	$(info update MAKEFILE to newest version)

.PHONY: _copy-makefile
_copy-makefile:
	@cat buildpack/Makefile > Makefile

.PHONY: _add-dynamic-targets-to-makefile
_add-dynamic-targets-to-makefile:
	@for SCRIPT_FILE in $$(ls -1 $(SCRIPTS_FOLDER)  2>/dev/null | sed -e 's/\..*$$//'); do cat $(TASK_TARGET_TEMPLATE) | sed "s/__TASKNAME__/$$SCRIPT_FILE/g" >> Makefile; done

.PHONY: _update-gitignore
_update-gitignore:
	$(info update .gitignore to ignore files in buildpack folder)
	@if [ ! -f .gitignore ]; then echo "/$(BUILDPACK_FOLDER)/" > .gitignore; fi
	@if [ "$$(grep "/$(BUILDPACK_FOLDER)/" .gitignore | wc -l)" = "0" ]; then echo "/$(BUILDPACK_FOLDER)/" >> .gitignore; fi
