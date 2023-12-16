/*
    O'NABU! : Quick start headers/methods for the NABU
*/
#include <stdlib.h>
#include <arch/z80.h>
#include <stdio.h>
#include <stdbool.h>
#include <video/tms99x8.h>
#include <arch/nabu/hcca.h>

#define byte uint8_t
#define uint uint32_t
#define ushort uint16_t

#define NULL ((void *)0)

#define CTRL_OFF 0x01
#define CTRL_GREEN 0x09 
#define CTRL_GREEN_DP 0x0D 
#define CTRL_RED 0x11 
#define CTRL_RED_DP 0x15
#define CTRL_YELLOW 0x21 
#define CTRL_YELLOW_DP 0x25

/// @brief A frame of data.
struct Frame {
	ushort length;
	byte* data;
};

/// @brief Creates a new frame with the specified length and name.
#define nabu_frame(name, l) \
	struct Frame* name = malloc(sizeof(struct Frame)); \
	name->length = l; \
	name->data = malloc(l);

/// @brief Writes a frame to the HCCA. Command can be NULL. 
void hcca_writeFrame(byte command, struct Frame* frame);

/// @brief Reads a frame from the HCCA.
/// @return A frame with the data read from the HCCA.
struct Frame* hcca_readFrame();

/// @brief Writes a byte to the NABU control register.
#define nabu_writeControl(value) \
    outp(0x0000, (byte)value);

/// @brief Resets the NABU.
void nabu_reset(bool coldBoot);

#include "onabu.c"