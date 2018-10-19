MAKEFILES_FOLDER = buildpack/makefiles

.PHONY: install-buildpack
install-buildpack:
	make -f $(MAKEFILES_FOLDER)/installation/Makefile install-buildpack

.PHONY: checkstyle
checkstyle:
	make -f $(MAKEFILES_FOLDER)/checkstyle.Makefile

.PHONY: unittest
unittest:
	make -f $(MAKEFILES_FOLDER)/unittest.Makefile
