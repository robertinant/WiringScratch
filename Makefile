# Makefile for the Wiring++ framework
#
# Copyright (c) 2013, Robert Wessels
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
#
# 1. Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution. 
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies, 
# either expressed or implied, of the FreeBSD Project.

include Variables.mk

ifeq ($(OS),Windows_NT)
$(shell set CYGWIN=nodosfilewarning)
RM = $(shell rmdir /S /Q build >nul 2>nul)
MKDIR:=mkdir
else
RM:=rm -rf build
MKDIR:=mkdir -p
endif


BOARD_DIR := $(APPLICATION_PATH)/hardware/$(PLATFORM)/$(BOARD)
COMMON_LIB_PATH := $(APPLICATION_PATH)/libraries
ARCH_LIB_PATH := $(APPLICATION_PATH)/cores/$(ARCH)/libraries
ARCH_CORE_PATH := $(APPLICATION_PATH)/cores/$(ARCH)
COMMON_CORE_DIR := $(APPLICATION_PATH)/cores/Common

DIRS := $(COMMON_LIB_PATH) $(BOARD_DIR) $(CORES) $(ARCH_CORE_PATH) $(COMMON_CORE_DIR) $(ARCH_LIB_PATH)
INCLUDE_DIRS = $(foreach dir, $(DIRS), ${sort ${dir ${wildcard ${dir}/*/ ${dir}/*/utility/}}})

# Generate a list for the preprocessor
CPPFLAGS += $(foreach includedir,$(INCLUDE_DIRS),-I$(includedir))

# Use the preprocessor to find the dependencies. What we are really after is what libraries the Sketch depends on
define deps
$(foreach SRC, $1, $(shell $(CC) $(MCU) -MM $(CPPFLAGS) $(SRC)))
endef
LIBDIRS=
# (Ab)use the dependency tree to figure out what libraries the file in question depends on and add them to LIBSRCS
define get_lib_dirs
$(if $(findstring libraries, $1), LIBDIRS+=$1)
endef

LIBDEP = $(call deps, $(addsuffix .cpp, $(SKETCH_NAME)) $(EXTRA_SOURCES))
$(foreach dep, $(dir $(LIBDEP)), $(eval $(call get_lib_dirs, $(dep))))

# eval prevents the "Recursive variable `LIBDIRS' references itself (eventually)" to be emitted
$(eval LIBDIRS += $(addsuffix utility/,$(LIBDIRS)))

ARCH_LIBS_LIST = $(subst $(ARCH_LIB_PATH)/,,$(LIBDIRS))

DEP_LIB_C_SRCS = $(wildcard $(patsubst %,%*.c,$(LIBDIRS)))
OBJS = $(patsubst $(APPLICATION_PATH)/%.c,build/%.o,$(DEP_LIB_C_SRCS))

DEP_LIB_CPP_SRCS = $(wildcard $(patsubst %,%*.cpp,$(LIBDIRS)))
OBJS += $(patsubst $(APPLICATION_PATH)/%.cpp,build/%.o,$(DEP_LIB_CPP_SRCS))

CORE_C_SRCS = $(wildcard $(ARCH_CORE_PATH)/*.c)
OBJS += $(patsubst $(APPLICATION_PATH)/%.c,build/%.o,$(CORE_C_SRCS))

CORE_CPP_SRCS = $(wildcard $(ARCH_CORE_PATH)/*.cpp)
OBJS += $(patsubst $(APPLICATION_PATH)/%.cpp,build/%.o,$(CORE_CPP_SRCS))

CORE_COMMON_C_SRCS = $(wildcard $(COMMON_CORE_DIR)/*.c)
OBJS += $(patsubst $(APPLICATION_PATH)/%.c,build/%.o,$(CORE_COMMON_C_SRCS))

CORE_COMMON_CPP_SRCS = $(wildcard $(COMMON_CORE_DIR)/*.cpp)
OBJS += $(patsubst $(APPLICATION_PATH)/%.cpp,build/%.o,$(CORE_COMMON_CPP_SRCS))

BOARD_CPP_SRCS = $(wildcard $(BOARD_DIR)/*.cpp)
OBJS += $(patsubst $(APPLICATION_PATH)/%.cpp,build/%.o,$(BOARD_CPP_SRCS))

LOCAL_CPP_SRCS = $(wildcard *.cpp)
OBJS += $(patsubst %.cpp,build/%.o,$(LOCAL_CPP_SRCS))

all: build/$(SKETCH_NAME).hex

build/$(SKETCH_NAME).elf: $(OBJS)
	$(info Linking $@)
	@$(CC) $(LDFLAGS) -o $@ $(OBJS) $(SYS_OBJS) -lc

%.hex: %.elf
	$(info Creating $@)
	@$(OBJCOPY) $(OBJCOPY_FLAGS) $< $@
	$(info >>>> Done <<<<)

build/%.o: %.c
ifeq ($(OS),Windows_NT)
	$(shell mkdir $(dir $(subst /,\,$@)) >nul 2>nul)
else
	@mkdir -p $(dir $@)
endif
	$(info Compiling $@)
	$(VERBOSE)$(CC) $(MCU) $(CFLAGS) ${CPPFLAGS} -c -o $@ $<

build/%.o: %.cpp
ifeq ($(OS),Windows_NT)
	$(shell mkdir $(dir $(subst /,\,$@)) >nul 2>nul)
else
	@mkdir -p $(dir $@)
endif
	$(info Compiling $@)
	$(VERBOSE)$(CXX) $(MCU) $(CFLAGS) ${CPPFLAGS} -c -o $@ $<

build/%.o: $(APPLICATION_PATH)/%.c
ifeq ($(OS),Windows_NT)
	$(shell mkdir $(dir $(subst /,\,$@)) >nul 2>nul)
else
	@mkdir -p $(dir $@)
endif
	$(info Compiling $@)
	$(VERBOSE)$(CC) $(MCU) $(CFLAGS) ${CPPFLAGS} -c -o $@ $<

build/%.o: $(APPLICATION_PATH)/%.cpp
ifeq ($(OS),Windows_NT)
	$(shell mkdir $(dir $(subst /,\,$@)) >nul 2>nul)
else
	@mkdir -p $(dir $@)
endif
	$(info Compiling $@)
	$(VERBOSE)$(CXX) $(MCU) $(CFLAGS) ${CPPFLAGS} -c -o $@ $<

.PHONY: clean
clean:
	$(info >>>> Clean <<<<)
	$(RM)
