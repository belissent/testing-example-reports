
MAKEFILE_PATH:=$(abspath $(lastword $(MAKEFILE_LIST))/..)

ifeq ($(OS),Windows_NT)
	ENV_PATH:=Scripts
else
	ENV_PATH:=bin
endif

PYTHON_50=source $(MAKEFILE_PATH)/env/gramps50/$(ENV_PATH)/activate; python
PIP_50=source $(MAKEFILE_PATH)/env/gramps50/$(ENV_PATH)/activate; pip

VARS_50:=
VARS_50:=$(VARS_50) GRAMPSHOME=$(MAKEFILE_PATH)/databases/dbgramps50
VARS_50:=$(VARS_50) GRAMPS_RESOURCES=$(MAKEFILE_PATH)/sources/gramps50
VARS_50:=$(VARS_50) GRAMPS_REPORTS=$(MAKEFILE_PATH)/gramps50
VARS_50:=$(VARS_50) PYTHONPATH=$(MAKEFILE_PATH)/sources/gramps50
VARS_50:=$(VARS_50) LANG=en_US.UTF-8
VARS_50:=$(VARS_50) LANGUAGE=en_US

PYTHON_42=$(subst gramps50,gramps42,$(PYTHON_50))
PIP_42=$(subst gramps50,gramps42,$(PIP_50))
VARS_42=$(subst gramps50,gramps42,$(VARS_50))

# ifneq ($(wildcard $(ICU_INSTALL_DIR)),)
	# PIP_ICU_INCLUDE:=--global-option=build_ext --global-option="-I$(ICU_INSTALL_DIR)/include"
# else
	# PIP_ICU_INCLUDE:=
# endif

#SUDO=sudo
SUDO:=


all: all42 all50

env: env42 env50

clone: clone42 clone50 clone_addons

copy_addons: copy_addons42 copy_addons50

run_reports.: run_reports42 run_reports50

clean:
	rm -rf env sources databases
	find . -name "*.stackdump" -exec rm {} +

############################################## 4.2

all42: env42 clone42 copy_addons run_reports42

env42:
	#todo

clone42: clone_addons
	# todo

copy_addons42:
	# todo

run_reports42:
	# todo

############################################## 5.0

all50: env50 pip50 clone50 copy_addons50 run_reports50

env50:
	if [ ! -d "env" ]; then mkdir env; fi
	if [ ! -d "env/gramps50" ]; then \
		virtualenv --system-site-packages --python=3 env/gramps50; \
	fi

pip50:
	$(PIP_50) install Django\<1.8
	# $(PIP_50) install $(PIP_ICU_INCLUDE) pyicu\<1.9
	$(PIP_50) install pyicu\<1.9
	$(PIP_50) install cffi
	$(PIP_50) install cairosvg
	$(PIP_50) install Pillow

clone50: sources/gramps50/.gitignore sources/gramps50/build/lib/gramps/grampsapp.py
sources/gramps50/.gitignore:
	if [ ! -d "sources" ]; then mkdir sources; fi
	git clone --depth=1 --branch=master git://github.com/gramps-project/gramps.git sources/gramps50
sources/gramps50/build/lib/gramps/grampsapp.py:
	cd sources/gramps50; $(PYTHON_50) setup.py build

copy_addons50: clone_addons
	if [ ! -d "databases/db50/gramps/gramps50/plugins" ]; then \
		mkdir -p databases/db50/gramps/gramps50/plugins; \
		for archive in `ls sources/addons/gramps50/download/*.tgz`; do \
			tar -xzf $$archive -C databases/db50/gramps/gramps50/plugins; \
		done; \
	fi

run_reports50: clone50 copy_addons50
	if [ ! -d "gramps50/gramps" ]; then mkdir -p gramps50/gramps; fi
	if [ ! -d "gramps50/addons" ]; then mkdir -p gramps50/addons; fi
	$(VARS_50) $(PYTHON_50) run_reports50.py

############################################## Common

clone_addons: sources/addons/.gitignore
sources/addons/.gitignore:
	if [ ! -d "sources" ]; then mkdir sources; fi
	git clone --depth=1 --branch=master git://github.com/gramps-project/addons.git sources/addons
	touch sources/addons/.gitignore
