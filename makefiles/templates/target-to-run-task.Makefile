
.PHONY: __TASKNAME__
__TASKNAME__: _print-version
	make -f $(MAKEFILES_FOLDER)/task.Makefile task=__TASKNAME__
