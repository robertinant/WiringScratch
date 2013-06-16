BOARD_TAG=WiringS
PROJECT_NAME=sketch_jun01a
APPLICATION_PATH=c:/wiring
SKETCHBOOK_DIR=/Users/rwessels/Documents/Wiring
USER_LIB_PATH=/Users/rwessels/Documents/Wiring/libraries
MCU=-mmcu=atmega644p
PLATFORM=Wiring
BOARD=WiringS
ARCH=AVR8Bit
CFLAGS = -Os -DF_CPU=16000000L -g -Os -w -Wall -ffunction-sections -fdata-sections -DWIRING=100
LDFLAGS = $(MCU) -lm -Wl,--gc-sections -Os $(EXTRA_LDFLAGS)
