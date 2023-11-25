struct Frame* new_frame(ushort length)
{
	struct Frame* frame = malloc(sizeof(struct Frame));
	frame->length = length;
	frame->data = malloc(length);
	return frame;
}


void hcca_writeFrame(byte command, struct Frame* frame)
{
	hcca_reset_write();
	hcca_start_read(HCCA_MODE_RB, NULL, 0);

	if (command != NULL) hcca_writeByte(command);
	
	hcca_writeUInt16(frame->length);		
	for (int i = 0; i < frame->length; i++)
	{
		hcca_writeByte(frame->data[i]);
	}
	hcca_start_write(HCCA_MODE_BLOCK, NULL, 0);
}


struct Frame* hcca_readFrame() {
	ushort length = hcca_readUInt16();
	struct Frame* frame = malloc(sizeof(struct Frame));
	byte* data = malloc(length);
	for (int i = 0; i < length; i++)
	{
		data[i] = hcca_readByte();
	}
	frame->length = length;
	frame->data = data;
	return frame;
}

void nabu_write_control_reg(byte value) {
	outp(0x0000, value);
}

void nabu_reset(bool coldBoot) {
			
    byte* one = (byte *)0x0000;
	byte* two = (byte *)0x0001;
	byte* three = (byte *)0x0002;
	byte* four = (byte *)0x0003;	
	
	byte* bootMode = (byte *)0xFFFE;

	// reset the bios.
	if (*four == 0xee)
	{
		*one = 0x3e;
		*two = 0x02;
		*three = 0x32;
	}

	if (*four == 0x7)
	{
		*one = 0xc3;
		*two = 0x0a;
		*three = 0x00;
	}
	
	if (coldBoot) *bootMode = 0x5A;
	else *bootMode = 0xA5;

	__asm
	di
	RST 00H;
	__endasm;
}