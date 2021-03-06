# Shadow Warrior Makefile for GNU Make

# Create Makefile.user yourself to provide your own overrides
# for configurable values
-include Makefile.user
-include ../jfaudiolib.git/Makefile.shared

##
##
## CONFIGURABLE OPTIONS
##
##

# Debugging options
RELEASE ?= 0

# DirectX SDK location
DXROOT ?= $(HOME)/sdks/directx/dx7

# Engine source code path
EROOT ?= ../jfbuild.git

# JMACT library source path
MACTROOT ?= ../jfmact.git

# JFAudioLib source path
AUDIOLIBROOT ?= ../jfaudiolib.git

# Engine options
SUPERBUILD ?= 1
POLYMOST ?= 0
USE_OPENGL ?= 0
DYNAMIC_OPENGL ?= 1
NOASM ?= 1
LINKED_GTK ?= 0


##
##
## HERE BE DRAGONS
##
##

# build locations
SRC=source
RSRC=rsrc
EINC=$(EROOT)/include
ELIB=$(EROOT)
INC=$(SRC)
o=o

ifneq (0,$(RELEASE))
  # debugging disabled
  debug=-ffast-math -G0 -pipe \
	-fomit-frame-pointer -ffunction-sections -ffast-math -fsingle-precision-constant -mbranch-likely 
else
  # debugging enabled
  debug=-ggdb -O0
endif

include $(AUDIOLIBROOT)/Makefile.shared

CROSS_COMPILE ?=

CC=$(CROSS_COMPILE)gcc
CXX=$(CROSS_COMPILE)g++
OURCFLAGS=$(debug) -W -Wall -Wimplicit -Wno-char-subscripts -Wno-unused \
	-fno-pic -funsigned-char -fno-strict-aliasing -DNO_GCC_BUILTINS -march=mips32r2 \
	-I$(INC) -I$(EINC) -I$(MACTROOT) -I$(AUDIOLIBROOT)/include
OURCXXFLAGS=-fno-exceptions -fno-rtti
LIBS=-lm -flto
GAMELIBS=
NASMFLAGS=-s #-g
EXESUFFIX=

JMACTOBJ=$(MACTROOT)/util_lib.$o \
	$(MACTROOT)/file_lib.$o \
	$(MACTROOT)/control.$o \
	$(MACTROOT)/keyboard.$o \
	$(MACTROOT)/mouse.$o \
	$(MACTROOT)/mathutil.$o \
	$(MACTROOT)/scriplib.$o \
	$(MACTROOT)/animlib.$o

GAMEOBJS= \
	$(SRC)/actor.$o \
	$(SRC)/ai.$o \
	$(SRC)/anim.$o \
	$(SRC)/border.$o \
	$(SRC)/break.$o \
	$(SRC)/bunny.$o \
	$(SRC)/cache.$o \
	$(SRC)/cheats.$o \
	$(SRC)/colormap.$o \
	$(SRC)/config.$o \
	$(SRC)/console.$o \
	$(SRC)/coolg.$o \
	$(SRC)/coolie.$o \
	$(SRC)/copysect.$o \
	$(SRC)/demo.$o \
	$(SRC)/draw.$o \
	$(SRC)/eel.$o \
	$(SRC)/game.$o \
	$(SRC)/girlninj.$o \
	$(SRC)/goro.$o \
	$(SRC)/hornet.$o \
	$(SRC)/interp.$o \
	$(SRC)/interpsh.$o \
	$(SRC)/inv.$o \
	$(SRC)/jplayer.$o \
	$(SRC)/jsector.$o \
	$(SRC)/jweapon.$o \
	$(SRC)/lava.$o \
	$(SRC)/light.$o \
	$(SRC)/mclip.$o \
	$(SRC)/mdastr.$o \
	$(SRC)/menus.$o \
	$(SRC)/miscactr.$o \
	$(SRC)/morph.$o \
	$(SRC)/net.$o \
	$(SRC)/ninja.$o \
	$(SRC)/panel.$o \
	$(SRC)/player.$o \
	$(SRC)/predict.$o \
	$(SRC)/quake.$o \
	$(SRC)/ripper.$o \
	$(SRC)/ripper2.$o \
	$(SRC)/rooms.$o \
	$(SRC)/rotator.$o \
	$(SRC)/rts.$o \
	$(SRC)/save.$o \
	$(SRC)/scrip2.$o \
	$(SRC)/sector.$o \
	$(SRC)/serp.$o \
	$(SRC)/setup.$o \
	$(SRC)/skel.$o \
	$(SRC)/skull.$o \
	$(SRC)/slidor.$o \
	$(SRC)/sounds.$o \
	$(SRC)/spike.$o \
	$(SRC)/sprite.$o \
	$(SRC)/sumo.$o \
	$(SRC)/swconfig.$o \
	$(SRC)/sync.$o \
	$(SRC)/text.$o \
	$(SRC)/track.$o \
	$(SRC)/vator.$o \
	$(SRC)/vis.$o \
	$(SRC)/wallmove.$o \
	$(SRC)/warp.$o \
	$(SRC)/weapon.$o \
	$(SRC)/zilla.$o \
	$(SRC)/zombie.$o \
	$(SRC)/saveable.$o \
	$(JMACTOBJ)

EDITOROBJS=$(SRC)/jnstub.$o \
	$(SRC)/brooms.$o \
	$(SRC)/bldscript.$o \
	$(SRC)/jbhlp.$o \
	$(SRC)/colormap.$o

include $(EROOT)/Makefile.shared

ifeq ($(PLATFORM),LINUX)
	NASMFLAGS+= -f elf
	GAMELIBS+= $(JFAUDIOLIB_LDFLAGS) -lasound
endif
ifeq ($(PLATFORM),WINDOWS)
	OURCFLAGS+= -DUNDERSCORES -I$(DXROOT)/include
	NASMFLAGS+= -DUNDERSCORES -f win32
	GAMEOBJS+= $(SRC)/gameres.$o $(SRC)/startdlg.$o $(SRC)/startwin.game.$o
	EDITOROBJS+= $(SRC)/buildres.$o
	GAMELIBS+= -ldsound \
	       $(AUDIOLIBROOT)/third-party/mingw32/lib/libvorbisfile.a \
	       $(AUDIOLIBROOT)/third-party/mingw32/lib/libvorbis.a \
	       $(AUDIOLIBROOT)/third-party/mingw32/lib/libogg.a
endif

ifeq ($(RENDERTYPE),SDL)
	OURCFLAGS+= $(subst -Dmain=SDL_main,,$(shell sdl-config --cflags))
	
	ifeq (1,$(JFAUDIOLIB_USE_SDLMIXER))
		OURCFLAGS+= -DUSE_SDLMIXER
	endif

	ifeq (1,$(HAVE_GTK2))
		OURCFLAGS+= -DHAVE_GTK2 $(shell pkg-config --cflags gtk+-2.0)
		GAMEOBJS+= $(SRC)/game_banner.$o $(SRC)/startdlg.$o $(SRC)/startgtk.game.$o
		EDITOROBJS+= $(SRC)/editor_banner.$o
	endif

	GAMEOBJS+= $(SRC)/game_icon.$o
	EDITOROBJS+= $(SRC)/build_icon.$o
endif

OURCFLAGS+= $(BUILDCFLAGS)

.PHONY: clean all engine $(ELIB)/$(ENGINELIB) $(ELIB)/$(EDITORLIB) $(AUDIOLIBROOT)/$(JFAUDIOLIB)

# TARGETS

# Invoking Make from the terminal in OSX just chains the build on to xcode
ifeq ($(PLATFORM),DARWIN)
ifeq ($(RELEASE),0)
style=Debug
else
style=Release
endif
.PHONY: alldarwin
alldarwin:
	cd osx && xcodebuild -target All -buildstyle $(style)
endif

all: sw$(EXESUFFIX) build$(EXESUFFIX)

sw$(EXESUFFIX): $(GAMEOBJS) $(ELIB)/$(ENGINELIB) $(AUDIOLIBROOT)/$(JFAUDIOLIB)
	$(CXX) $(CXXFLAGS) $(OURCXXFLAGS) $(OURCFLAGS) -o $@ $^ $(LIBS) $(GAMELIBS) -Wl,-Map=$@.map
	
build$(EXESUFFIX): $(EDITOROBJS) $(ELIB)/$(EDITORLIB) $(ELIB)/$(ENGINELIB)
	$(CXX) $(CXXFLAGS) $(OURCXXFLAGS) $(OURCFLAGS) -o $@ $^ $(LIBS) -Wl,-Map=$@.map

include Makefile.deps

.PHONY: enginelib editorlib
enginelib editorlib:
	$(MAKE) -C $(EROOT) \
		SUPERBUILD=$(SUPERBUILD) POLYMOST=$(POLYMOST) \
		USE_OPENGL=$(USE_OPENGL) DYNAMIC_OPENGL=$(DYNAMIC_OPENGL) \
		NOASM=$(NOASM) RELEASE=$(RELEASE) $@

$(ELIB)/$(ENGINELIB): enginelib
$(ELIB)/$(EDITORLIB): editorlib
$(AUDIOLIBROOT)/$(JFAUDIOLIB):
	$(MAKE) -C $(AUDIOLIBROOT) RELEASE=$(RELEASE)

# RULES
$(SRC)/%.$o: $(SRC)/%.nasm
	nasm $(NASMFLAGS) $< -o $@

$(SRC)/%.$o: $(SRC)/%.c
	$(CC) $(CFLAGS) $(OURCFLAGS) -c $< -o $@ 2>&1
$(SRC)/%.$o: $(SRC)/%.cpp
	$(CXX) $(CXXFLAGS) $(OURCXXFLAGS) $(OURCFLAGS) -c $< -o $@ 2>&1
$(MACTROOT)/%.$o: $(MACTROOT)/%.c
	$(CC) $(CFLAGS) $(OURCFLAGS) -c $< -o $@ 2>&1

$(SRC)/%.$o: $(SRC)/misc/%.rc
	windres -i $< -o $@ --include-dir=$(EINC) --include-dir=$(SRC)

$(SRC)/%.$o: $(SRC)/util/%.c
	$(CC) $(CFLAGS) $(OURCFLAGS) -c $< -o $@ 2>&1

$(SRC)/%.$o: $(RSRC)/%.c
	$(CC) $(CFLAGS) $(OURCFLAGS) -c $< -o $@ 2>&1

$(SRC)/game_banner.$o: $(RSRC)/game_banner.c
$(SRC)/editor_banner.$o: $(RSRC)/editor_banner.c
$(RSRC)/game_banner.c: $(RSRC)/game.bmp
	echo "#include <gdk-pixbuf/gdk-pixdata.h>" > $@
	gdk-pixbuf-csource --extern --struct --raw --name=startbanner_pixdata $^ | sed 's/load_inc//' >> $@
$(RSRC)/editor_banner.c: $(RSRC)/build.bmp
	echo "#include <gdk-pixbuf/gdk-pixdata.h>" > $@
	gdk-pixbuf-csource --extern --struct --raw --name=startbanner_pixdata $^ | sed 's/load_inc//' >> $@

# PHONIES	
clean:
ifeq ($(PLATFORM),DARWIN)
	cd osx && xcodebuild -target All clean
else
	-rm -f $(GAMEOBJS) $(EDITOROBJS)
	$(MAKE) -C $(EROOT) clean
	$(MAKE) -C $(AUDIOLIBROOT) clean
endif
	
veryclean: clean
ifeq ($(PLATFORM),DARWIN)
else
	-rm -f sw$(EXESUFFIX) build$(EXESUFFIX) core*
	$(MAKE) -C $(EROOT) veryclean
endif

ifeq ($(PLATFORM),WINDOWS)
.PHONY: datainst
datainst:
	cd datainst && $(MAKE) GAME=SW
endif
