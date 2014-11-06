all: build/js/Cindy.js

clean:
	$(RM) -r build
	cd GWT && ant clean

.PHONY: all clean

libcs := src/js/libcs/Namespace.js src/js/libcs/Accessors.js src/js/libcs/CSNumber.js src/js/libcs/List.js src/js/libcs/Essentials.js src/js/libcs/General.js src/js/libcs/Operators.js src/js/libcs/OpDrawing.js src/js/libcs/OpImageDrawing.js src/js/libcs/Parser.js src/js/libcs/OpSound.js

libgeo := src/js/libgeo/GeoState.js src/js/libgeo/GeoBasics.js src/js/libgeo/GeoOps.js src/js/libgeo/GeoScripts.js

liblab := src/js/liblab/LabBasics.js src/js/liblab/LabObjects.js

lib := src/js/lib/numeric-1.2.6.js src/js/lib/clipper.js

# by defaul compile with SIMPLE flag
optflags = SIMPLE
ifeq ($(O),1)
	optflags = ADVANCED
endif

#by default use closure compiler
js_compiler = closure

ifeq ($(plain),1)
	js_compiler = plain 
endif

ifeq ($(js_compiler), closure)
build/js/Cindy.js: $(libgeo) src/js/Setup.js src/js/Events.js src/js/Timer.js $(libcs) $(liblab) $(lib)
	mkdir -p $(@D)
	java -jar compiler.jar --language_in ECMASCRIPT5 --create_source_map $@.map --source_map_format V3 --source_map_location_mapping "src/js/|../../src/js/" --output_wrapper_file src/js/Cindy.js.wrapper --js_output_file $@ --js $^
else
build/js/Cindy.js: $(libgeo) src/js/Setup.js src/js/Events.js src/js/Timer.js $(libcs) $(liblab) $(lib)
	mkdir -p $(@D)
	cat $^ > $@
endif


ANT_VERSION=1.9.4
ANT_MIRROR=http://apache.openmirror.de
ANT_PATH=ant/binaries
ANT_ZIP=apache-ant-$(ANT_VERSION)-bin.zip
ANT_URL=$(ANT_MIRROR)/$(ANT_PATH)/$(ANT_ZIP)

GWT/download/arch/$(ANT_ZIP):
	mkdir -p $(@D)
	curl -o $@ $(ANT_URL)

GWT/download/ant/bin/ant: GWT/download/arch/$(ANT_ZIP)
	rm -rf GWT/download/ant GWT/download/apache-ant-*
	cd GWT/download && unzip arch/$(ANT_ZIP)
	mv GWT/download/apache-ant-$(ANT_VERSION) GWT/download/ant
	touch $@

ANT:=ant
ANT_DEP:=$(shell $(ANT) -version > /dev/null 2>&1 || echo GWT/download/ant/bin/ant)
ANT_CMD:=$(if $(ANT_DEP),$(ANT_DEP),$(ANT))

GWT_modules = $(patsubst src/java/cindyjs/%.gwt.xml,%,$(wildcard src/java/cindyjs/*.gwt.xml))

define GWT_template

GWT/war/$(1)/$(1).nocache.js: src/java/cindyjs/$(1).gwt.xml $$(wildcard src/java/cindyjs/$(1)/*.java) $$(ANT_DEP)
	cd GWT && $$(ANT_CMD:GWT/%=%) -Dcjs.module=$(1)

build/js/$(1)/$(1).nocache.js: GWT/war/$(1)/$(1).nocache.js
	rm -rf build/js/$(1)
	cp -r GWT/war/$(1) build/js/

all: build/js/$(1)/$(1).nocache.js

endef

$(foreach mod,$(GWT_modules),$(eval $(call GWT_template,$(mod))))
