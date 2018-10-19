MAKEFILES_FOLDER = buildpack/makefiles

.PHONY: install-buildpack
install-buildpack:
	make -f $(MAKEFILES_FOLDER)/installation/Makefile install-buildpack

.PHONY: checkstyle
install-buildpack:
	make -f $(MAKEFILES_FOLDER)/checkstyle.Makefile

.PHONY: unittest
install-buildpack:
	make -f $(MAKEFILES_FOLDER)/unittest.Makefile
