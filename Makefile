## ConnectIQ resources
include Makefile.ciq


## Project resources
MY_PROJECT := GliderSK
MY_MANIFEST := manifest.xml
MY_RESOURCES := $(shell find -L resources* -name '*.xml')
MY_SOURCES := $(shell find -L source -name '*.mc')


## Help
.PHONY: help
help:
	@echo 'Targets:'
	@echo '  ciq-help  - display the build environment help'
	@echo '  help      - display this help message'
	@echo '  debug     - build the project (*.prg; including debug symbols)'
	@echo '  release   - build the project (*.prg; excluding debug symbols)'
	@echo '  iq        - package the project (*.iq)'
	@echo '  simulator - launch the project in the simulator'
	@echo '  clean     - delete all build output'
.DEFAULT_GOAL := help

## Build

# debug
OUTPUT_DEBUG := bin/${MY_PROJECT}.debug.prg
${OUTPUT_DEBUG}: ${MY_MANIFEST} ${MY_RESOURCES} ${MY_SOURCES} | ${CIQ_MONKEYC} ${CIQ_DEVKEY}  
	mkdir -p bin
	${CIQ_MONKEYC} -w \
	  -o $@ \
	  -d ${CIQ_DEVICE} \
	  -s ${CIQ_SDK} \
	  -y ${CIQ_DEVKEY} \
	  -m ${MY_MANIFEST} \
	  -z $(shell echo ${MY_RESOURCES} | tr ' ' ':') \
	  ${MY_SOURCES}
debug: ${OUTPUT_DEBUG}

# release
OUTPUT_RELEASE := bin/${MY_PROJECT}.prg
${OUTPUT_RELEASE}: ${MY_MANIFEST} ${MY_RESOURCES} ${MY_SOURCES} | ${CIQ_MONKEYC} ${CIQ_DEVKEY}  
	mkdir -p bin
	${CIQ_MONKEYC} -w -r \
	  -o $@ \
	  -d ${CIQ_DEVICE} \
	  -s ${CIQ_SDK} \
	  -y ${CIQ_DEVKEY} \
	  -m ${MY_MANIFEST} \
	  -z $(shell echo ${MY_RESOURCES} | tr ' ' ':') \
	  ${MY_SOURCES}
release: ${OUTPUT_RELEASE}

# IQ
OUTPUT_IQ := bin/${MY_PROJECT}.iq
${OUTPUT_IQ}: ${MY_MANIFEST} ${MY_RESOURCES} ${MY_SOURCES} | ${CIQ_MONKEYC} ${CIQ_DEVKEY}  
	mkdir -p bin
	${CIQ_MONKEYC} -e -w -r \
	  -o $@ \
	  -y ${CIQ_DEVKEY} \
	  -m ${MY_MANIFEST} \
	  -z $(shell echo ${MY_RESOURCES} | tr ' ' ':') \
	  ${MY_SOURCES}
iq: ${OUTPUT_IQ}


## Simulator
.PHONY: simulator
simulator: ${OUTPUT_DEBUG} | ${CIQ_SIMULATOR} ${CIQ_MONKEYDO}
	${CIQ_SIMULATOR} & sleep 1
	${CIQ_MONKEYDO} ${OUTPUT_DEBUG} ${CIQ_DEVICE}


## (Un-)Install

# mountpoint
${DESTDIR}/Garmin/Apps:
	$(error Garmin device not found; DESTDIR=${DESTDIR})

# install
.PHONY: install
install: ${OUTPUT_RELEASE} | ${DESTDIR}/Garmin/Apps
	@cp -v ${OUTPUT_RELEASE} ${DESTDIR}/Garmin/Apps/${MY_PROJECT}.prg

# uninstall
.PHONY: uninstall
uninstall: | ${DESTDIR}/Garmin/Apps
	@rm -fv ${DESTDIR}/Garmin/Apps/${MY_PROJECT}.prg \
	  ${DESTDIR}/Garmin/Apps/SETTINGS/${MY_PROJECT}.SET \
	  ${DESTDIR}/Garmin/Apps/DATA/${MY_PROJECT}.STR \
	  ${DESTDIR}/Garmin/Apps/LOGS/${MY_PROJECT}.TXT \
	  ${DESTDIR}/Garmin/Apps/LOGS/${MY_PROJECT}.BAK


## Clean
.PHONY: clean
clean:
	rm -rf bin

