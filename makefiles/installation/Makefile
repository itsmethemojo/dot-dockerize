BUILDPACK_REPOSITORY = https://github.com/itsmethemojo/buildpack.git
BUILDPACK_FOLDER = buildpack
SCRIPTS_TEMPLATES_FOLDER = $(BUILDPACK_FOLDER)/scripts-templates
SCRIPTS_FOLDER = scripts

ifeq ($(findstring _,$(MAKECMDGOALS)),_)
$(error target $(MAKECMDGOALS) is private)
endif

.PHONY: install-buildpack
install-buildpack: _download-buildpack _create-script-files

.PHONY: _download-buildpack
_download-buildpack:
	rm -rf $(BUILDPACK_FOLDER)
	docker run -v $$(pwd)/$(BUILDPACK_FOLDER):/downloads buildpack-deps bash -c "git clone --depth 1 $(BUILDPACK_REPOSITORY) /downloads && rm -r /downloads/.git && chmod -R 777 /downloads"

.PHONY: _create-script-files
_create-script-files:
	mkdir -p scripts
	for SCRIPT_FILE in $$(ls -1 $(SCRIPTS_TEMPLATES_FOLDER)); do if [ ! -f $(SCRIPTS_FOLDER)/$$SCRIPT_FILE ]; then cp $(SCRIPTS_TEMPLATES_FOLDER)/$$SCRIPT_FILE $(SCRIPTS_FOLDER)/$$SCRIPT_FILE; fi ; done

.PHONY: _update-makefile
_update-makefile:
	cat buildpack/Makefile > Makefile

.PHONY: _update-gitignore
_update-gitignore:
	if [ ! -f .gitignore ]; then echo "/$(BUILDPACK_FOLDER)" > .gitignore; fi
	if [ "$$(grep "/$(BUILDPACK_FOLDER)" .gitignore | wc -l)" = "0" ]; then echo "/$(BUILDPACK_FOLDER)" >> .gitignore; fi
