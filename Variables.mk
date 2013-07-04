######################################
# Board specific and needs to be in a board.mk along with the board
MCU = -mmcu=atmega644p
F_CPU = 16000000L
######################################
# Variables unknown until compilation
APPLICATION_PATH = /Applications/Wiring.app/Contents/Resources/Java
#APPLICATION_PATH = c:/wiring
SKETCHBOOK_DIR = /Users/rwessels/Documents/Wiring
USER_LIB_PATH = /Users/rwessels/Documents/Wiring/libraries
SKETCH_NAME = sketch_jun01a
EXTRA_SOURCES = foo.cpp
BOARD = WiringS
VERBOSE = @
######################################
# Common amongst all boards for this architecture
# This needs to be in a seperate directory and a directory common for this arch
PLATFORM = Wiring
ARCH = AVR8Bit
CFLAGS := -Os -DF_CPU=$(F_CPU) -g -Os -w -Wall -ffunction-sections -fdata-sections -DWIRING=100
ASFLAGS := -DF_CPU=$(FCPU) -x assembler-with-cpp
LDFLAGS := $(MCU) -lm -Wl,--gc-sections -Os $(EXTRA_LDFLAGS)
TOOLS_PATH := $(APPLICATION_PATH)/tools/avr/bin
CC := $(TOOLS_PATH)/avr-gcc
CXX := $(TOOLS_PATH)/avr-g++
AR := $(TOOLS_PATH)/avr-ar
OBJCOPY := $(TOOLS_PATH)/avr-objcopy
OBJCOPY_FLAGS := -Oihex -R .eeprom
