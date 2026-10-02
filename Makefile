#
# Red Pitaya specific application Makefile.
#

APP=dummy_simulator

-include _settings.env
-include _build_number

# If you want to set specific variables use the file: settings.env
#
# i.e.
#
# RPIP=rp-XXXXXX.local
# RPOPTS=-l root -p 2022
# RPSCP=-P 2022

RPOPTS ?= -l root

# Versioning system
BUILD_NUMBER ?= 0
REVISION ?= devbuild
VER:=$(shell cat $(APP)/info/info.json | grep version | sed -e 's/.*:\ *\"//' | sed -e 's/-.*//')

INSTALL_DIR ?= .

folder=$(CURDIR:%/=%)


CFLAGS += -DVERSION=$(VER)-$(BUILD_NUMBER) -DREVISION=$(REVISION)
export CFLAGS


.PHONY: all clean upload

# FPGA + controllers + target/ and the packages in archive/ (zip and tar.gz)
all:
	mkdir -p archive
	$(MAKE) -C $(APP) all
	$(MAKE) -C $(APP) zip
	$(MAKE) -C $(APP) tar

clean:
	$(MAKE) -C $(APP) clean

upload:
	$(MAKE) -C $(APP) upload
