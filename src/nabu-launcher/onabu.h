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

/// @brief A frame of data.
struct Frame {
	ushort length;
	byte* data;
};

/// @brief Creates a new frame with the specified length.
struct Frame* new_frame(ushort length);

/// @brief Writes a frame to the HCCA. Command can be NULL. 
void hcca_writeFrame(byte command, struct Frame* frame);

/// @brief Reads a frame from the HCCA.
/// @return A frame with the data read from the HCCA.
struct Frame* hcca_readFrame();

/// @brief Writes a byte to the NABU control register.
void nabu_write_control_reg(byte value);

/// @brief Resets the NABU.
void nabu_reset(bool coldBoot);

#include "onabu.c"