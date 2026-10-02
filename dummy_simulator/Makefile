#
#

APP=$(notdir $(CURDIR:%/=%))

-include ../_settings.env
-include ../_build_number


# Versioning system
BUILD_NUMBER ?= 0
REVISION ?= devbuild
VER:=$(shell cat info/info.json | grep version | sed -e 's/.*:\ *\"//' | sed -e 's/-.*//')

INSTALL_DIR ?= .


CONTROLLERHF   = controllerhf.so
CONTROLLER_DBG = controllerhf_dbg.so
CONTROLLER_RLD = controllerhf_rld.so

# Ecosystem 2.0: the FPGA is loaded from a .bin (fpgautil, called by fpga.sh).
# bootgen (Vivado 2020.1) converts fpga.bit (a copy of red_pitaya.bit) into fpga.bit.bin.
FPGA_BIN         = fpga.bit.bin
BOOTGEN_SETTINGS ?= /tools/Xilinx/Vivado/2020.1/settings64.sh


CFLAGS += -DVERSION=$(VER)-$(BUILD_NUMBER) -DREVISION=$(REVISION)
export CFLAGS


.PHONY: clean clean_fpga clean_app clean_target fpga app

# fpga/app are PHONY: with fpga.sh present, make's implicit rule '%: %.sh' would
# otherwise turn the target 'fpga' (a directory) into 'cat fpga.sh > fpga'

all: $(CONTROLLERHF) fpga

# The three controllers are built here, one after the other. Before, src/Makefile edited main.h / main.c
# with sed *after* compiling the objects, so controllerhf_dbg.so and controllerhf_rld.so were identical to
# controllerhf.so. Now the sed runs before each compilation (as in rp_lock-in_pid) and is always undone.
$(CONTROLLERHF):
	$(MAKE) -C src clean
	# Turn on DEBUG
	sed 's?/* *#define DEBUG 1.*?#define DEBUG 1? ' -i src/main.h
	$(MAKE) -C src
	mv $(CONTROLLERHF) $(CONTROLLER_DBG)
	$(MAKE) -C src clean
	# Turn off DEBUG
	sed ' s?/* *#define DEBUG 1.*?// #define DEBUG 1? ' -i src/main.h
	# Turn on RELOAD
	sed "s?/\\*RELOAD_DOCK_START\\*/.*/\\*RELOAD_DOCK_END\\*/?/*RELOAD_DOCK_START*/ PARAMS_DUMMY_PARAMS - 1 /*RELOAD_DOCK_END*/?"  -i src/main.c
	$(MAKE) -C src
	mv $(CONTROLLERHF) $(CONTROLLER_RLD)
	$(MAKE) -C src clean
	# Turn off RELOAD
	sed "s?/\\*RELOAD_DOCK_START\\*/.*/\\*RELOAD_DOCK_END\\*/?/*RELOAD_DOCK_START*/ PARAMS_NUM /*RELOAD_DOCK_END*/?"  -i src/main.c
	$(MAKE) -C src

$(CONTROLLER_DBG) $(CONTROLLER_RLD): $(CONTROLLERHF)


app: $(CONTROLLERHF)

fpga: red_pitaya.bit fpga.bit $(FPGA_BIN)

red_pitaya.bit:
	cd fpga && $(MAKE) out/red_pitaya.bit
	cp fpga/out/red_pitaya.bit .

fpga.bit: red_pitaya.bit
	cp red_pitaya.bit ./fpga.bit

# .bit -> .bin for Ecosystem 2.0 (bash: make runs /bin/sh, which has no 'source')
$(FPGA_BIN): fpga.bit
	printf "all:{ fpga.bit }" > fpga.bif
	bash -c '. $(BOOTGEN_SETTINGS) && bootgen -image fpga.bif -arch zynq -process_bitstream bin -w on'

target/$(APP): red_pitaya.bit $(FPGA_BIN) $(CONTROLLERHF) index.html
	mkdir -p target/$(APP)
	cp -r $(CONTROLLERHF) nginx.conf fpga.conf fpga.sh $(FPGA_BIN) info py css js red_pitaya.bit index.html target/$(APP)
	chmod 755 target/$(APP)/fpga.sh  # 2.0 runs it with system(): needs the exec bit
	if [ -d c ]; then cp -r c target/$(APP)/ ; fi
	rm target/$(APP)/info/icon_*.png
	cp -r upload_app.sh target/
	cp -r ../resources target/
	cp ../CHANGELOG.md ../README.md target/
	sed -i target/$(APP)/info/info.json -e 's/REVISION/$(REVISION)/'
	sed -i target/$(APP)/info/info.json -e 's/BUILD_NUMBER/$(BUILD_NUMBER)/'
	sed -i target/$(APP)/index.html -e "s/\(\\s*\)var\\s*app_version\\s*=\\s*'VERSION'\\s*;\\s*/\\1var app_version = '$(VER)-$(BUILD_NUMBER)-$(REVISION)';/"

target_dbg/$(APP)_DEBUG: red_pitaya.bit $(FPGA_BIN) $(CONTROLLER_DBG) index.html
	mkdir -p target_dbg/$(APP)_DEBUG
	cp -r $(CONTROLLER_DBG) nginx.conf fpga.conf fpga.sh $(FPGA_BIN) info py css js red_pitaya.bit index.html target_dbg/$(APP)_DEBUG
	chmod 755 target_dbg/$(APP)_DEBUG/fpga.sh
	if [ -d c ]; then cp -r c target_dbg/$(APP)_DEBUG/ ; fi
	cat target_dbg/$(APP)_DEBUG/info/icon_DEBUG.png > target_dbg/$(APP)_DEBUG/info/icon.png
	rm  target_dbg/$(APP)_DEBUG/info/icon_*.png
	mv  target_dbg/$(APP)_DEBUG/$(CONTROLLER_DBG) target_dbg/$(APP)_DEBUG/$(CONTROLLERHF)
	cp -r upload_app.sh target_dbg/
	cp -r ../resources target_dbg/
	cp ../CHANGELOG.md ../README.md target_dbg/
	sed -i target_dbg/$(APP)_DEBUG/info/info.json -e 's/REVISION/$(REVISION)_DEBUG/'
	sed -i target_dbg/$(APP)_DEBUG/info/info.json -e 's/BUILD_NUMBER/$(BUILD_NUMBER)/'
	sed -i target_dbg/$(APP)_DEBUG/index.html -e "s/\(\\s*\)var\\s*app_version\\s*=\\s*'VERSION'\\s*;\\s*/\\1var app_version = '$(VER)-$(BUILD_NUMBER)-$(REVISION)_DEBUG';/"
	sed -i target_dbg/$(APP)_DEBUG/index.html -e "s/\(\\s*\)var\\s*app_id\\s*=\\s*'$(APP)'\\s*;\\s*/\\1var app_id = '$(APP)_DEBUG';/"
	sed -i target_dbg/$(APP)_DEBUG/fpga.conf -e "s/$(APP)/$(APP)_DEBUG/"
	sed -i target_dbg/$(APP)_DEBUG/fpga.sh   -e "s?/apps/$(APP)/?/apps/$(APP)_DEBUG/?"
	sed -i target_dbg/$(APP)_DEBUG/nginx.conf -e "s?/$(APP)/?/$(APP)_DEBUG/?g"

target_rld/$(APP)_RELOAD: red_pitaya.bit $(CONTROLLER_RLD) index.html
	mkdir -p target_rld/$(APP)_RELOAD
	# No fpga.sh / fpga.bit.bin / red_pitaya.bit: _RELOAD keeps the FPGA already loaded (empty fpga.conf)
	cp -r $(CONTROLLER_RLD) nginx.conf info py css js index.html target_rld/$(APP)_RELOAD
	sed -i target_rld/$(APP)_RELOAD/nginx.conf -e "s?/$(APP)/?/$(APP)_RELOAD/?g"
	if [ -d c ]; then cp -r c target_rld/$(APP)_RELOAD/ ; fi
	touch target_rld/$(APP)_RELOAD/fpga.conf
	cat   target_rld/$(APP)_RELOAD/info/icon_RELOAD.png > target_rld/$(APP)_RELOAD/info/icon.png
	rm    target_rld/$(APP)_RELOAD/info/icon_*.png
	mv    target_rld/$(APP)_RELOAD/$(CONTROLLER_RLD) target_rld/$(APP)_RELOAD/$(CONTROLLERHF)
	cp -r upload_app.sh target_rld/
	cp -r ../resources target_rld/
	cp ../CHANGELOG.md ../README.md target_rld/
	sed -i target_rld/$(APP)_RELOAD/info/info.json -e 's/REVISION/$(REVISION)_RELOAD/'
	sed -i target_rld/$(APP)_RELOAD/info/info.json -e 's/BUILD_NUMBER/$(BUILD_NUMBER)/'
	sed -i target_rld/$(APP)_RELOAD/index.html -e "s/\(\\s*\)var\\s*app_version\\s*=\\s*'VERSION'\\s*;\\s*/\\1var app_version = '$(VER)-$(BUILD_NUMBER)-$(REVISION)_RELOAD';/"
	sed -i target_rld/$(APP)_RELOAD/index.html -e "s/\(\\s*\)var\\s*app_id\\s*=\\s*'$(APP)'\\s*;\\s*/\\1var app_id = '$(APP)_RELOAD';/"


zip: $(CONTROLLERHF) target/$(APP) target_dbg/$(APP)_DEBUG target_rld/$(APP)_RELOAD
	mkdir -p ../archive
	cd target; zip -r $(INSTALL_DIR)/$(APP)-$(VER)-$(BUILD_NUMBER)-$(REVISION).zip *
	mv target/$(APP)-$(VER)-$(BUILD_NUMBER)-$(REVISION).zip ../archive/.
	cd target_dbg; zip -r $(INSTALL_DIR)/$(APP)-$(VER)-$(BUILD_NUMBER)-$(REVISION)_DEBUG.zip *
	mv target_dbg/$(APP)-$(VER)-$(BUILD_NUMBER)-$(REVISION)_DEBUG.zip ../archive/.
	cd target_rld; zip -r $(INSTALL_DIR)/$(APP)-$(VER)-$(BUILD_NUMBER)-$(REVISION)_RELOAD.zip *
	mv target_rld/$(APP)-$(VER)-$(BUILD_NUMBER)-$(REVISION)_RELOAD.zip ../archive/.
	#$(RM) target -rf

tar: $(CONTROLLERHF) target/$(APP) target_dbg/$(APP)_DEBUG target_rld/$(APP)_RELOAD
	mkdir -p ../archive
	cd target; tar -czf $(INSTALL_DIR)/$(APP)-$(VER)-$(BUILD_NUMBER)-$(REVISION).tar.gz *
	mv target/$(APP)-$(VER)-$(BUILD_NUMBER)-$(REVISION).tar.gz ../archive/.
	cd target_dbg; tar -czf $(INSTALL_DIR)/$(APP)-$(VER)-$(BUILD_NUMBER)-$(REVISION)_DEBUG.tar.gz *
	mv target_dbg/$(APP)-$(VER)-$(BUILD_NUMBER)-$(REVISION)_DEBUG.tar.gz ../archive/.
	cd target_rld; tar -czf $(INSTALL_DIR)/$(APP)-$(VER)-$(BUILD_NUMBER)-$(REVISION)_RELOAD.tar.gz *
	mv target_rld/$(APP)-$(VER)-$(BUILD_NUMBER)-$(REVISION)_RELOAD.tar.gz ../archive/.

clean_target:
	-$(RM) target -rf
	-$(RM) target_dbg -rf
	-$(RM) target_rld -rf

clean_app:
	$(MAKE) -C src clean
	-$(RM) target -rf
	-$(RM) target_dbg -rf
	-$(RM) target_rld -rf
	-$(RM) *.so
	echo "BUILD_NUMBER=$$(( $(BUILD_NUMBER) + 1 ))" > ../_build_number

clean_fpga:
	$(MAKE) -C fpga clean
	-$(RM) target -rf
	-$(RM) target_dbg -rf
	-$(RM) target_rld -rf
	-$(RM) red_pitaya.bit fpga.bit $(FPGA_BIN)
	echo "BUILD_NUMBER=$$(( $(BUILD_NUMBER) + 1 ))" > ../_build_number

clean: clean_app clean_fpga clean_target



upload_bit:
	ssh $(RPIP) $(RPOPTS) "PATH_REDPITAYA=/opt/redpitaya /boot/sbin/rw ; rm /opt/redpitaya/www/apps/$(APP)/red_pitaya.bit"
	scp $(RPSCP) red_pitaya.bit $(FPGA_BIN) root@$(RPIP):/opt/redpitaya/www/apps/$(APP)/

upload: target/$(APP)
	ssh $(RPIP) $(RPOPTS) "PATH_REDPITAYA=/opt/redpitaya /boot/sbin/rw ; rm -rf /opt/redpitaya/www/apps/$(APP) ; mkdir -p /opt/redpitaya/www/apps/$(APP)"
	cd target/$(APP) ; scp  $(RPSCP) -r controllerhf.so css js nginx.conf fpga.conf fpga.sh $(FPGA_BIN) index.html info py red_pitaya.bit  root@$(RPIP):/opt/redpitaya/www/apps/$(APP)/

upload_debug: target_dbg/$(APP)_DEBUG
	ssh $(RPIP) $(RPOPTS) "PATH_REDPITAYA=/opt/redpitaya /boot/sbin/rw ; rm -rf /opt/redpitaya/www/apps/$(APP)_DEBUG ; mkdir -p /opt/redpitaya/www/apps/$(APP)_DEBUG"
	cd target_dbg/$(APP)_DEBUG; scp $(RPSCP) -r controllerhf.so css js nginx.conf fpga.conf fpga.sh $(FPGA_BIN) index.html info py red_pitaya.bit  root@$(RPIP):/opt/redpitaya/www/apps/$(APP)_DEBUG/

upload_reload: target_rld/$(APP)_RELOAD
	ssh $(RPIP) $(RPOPTS) "PATH_REDPITAYA=/opt/redpitaya /boot/sbin/rw ; rm -rf /opt/redpitaya/www/apps/$(APP)_RELOAD ; mkdir -p /opt/redpitaya/www/apps/$(APP)_RELOAD"
	cd target_rld/$(APP)_RELOAD; scp $(RPSCP) -r controllerhf.so css js nginx.conf fpga.conf index.html info py root@$(RPIP):/opt/redpitaya/www/apps/$(APP)_RELOAD/

upload_html: target/$(APP) target_dbg/$(APP)_DEBUG target_rld/$(APP)_RELOAD
	ssh $(RPIP) $(RPOPTS) "PATH_REDPITAYA=/opt/redpitaya /boot/sbin/rw ; rm -rf /opt/redpitaya/www/apps/$(APP)/{index.html,js,css}"
	#ssh $(RPIP) $(RPOPTS) "PATH_REDPITAYA=/opt/redpitaya /boot/sbin/rw ; rm -rf /opt/redpitaya/www/apps/$(APP)_DEBUG/{index.html,js,css}"
	#ssh $(RPIP) $(RPOPTS) "PATH_REDPITAYA=/opt/redpitaya /boot/sbin/rw ; rm -rf /opt/redpitaya/www/apps/$(APP)_RELOAD/{index.html,js,css}"
	cd target/$(APP); scp $(RPSCP) -r index.html css js root@$(RPIP):/opt/redpitaya/www/apps/$(APP)/
	#cd target_dbg/$(APP)_DEBUG; scp $(RPSCP) -r index.html css js root@$(RPIP):/opt/redpitaya/www/apps/$(APP)_DEBUG/
	#cd target_rld/$(APP)_RELOAD; scp $(RPSCP) -r index.html css js root@$(RPIP):/opt/redpitaya/www/apps/$(APP)_RELOAD/
