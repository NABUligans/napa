void hcca_writeFrame(byte command, struct Frame* frame)
{
	hcca_reset_write();
	hcca_start_read(HCCA_MODE_RB, NULL, 0);
	nabu_writeControl(CTRL_RED);
	if (command != NULL) hcca_writeByte(command);
	
	hcca_writeUInt16(frame->length);		
	
	for (int i = 0; i < frame->length; i++)
	{
		hcca_writeByte(frame->data[i]);
	}
	hcca_start_write(HCCA_MODE_BLOCK, NULL, 0);
	nabu_writeControl(CTRL_OFF);
}


struct Frame* hcca_readFrame() 
{
	//hcca_start_read(HCCA_MODE_RB, NULL, 0);
	nabu_writeControl(CTRL_YELLOW);
	ushort length = hcca_readUInt16();
	byte* data = malloc(length);
	for (int i = 0; i < length; i++)
	{
		data[i] = hcca_readByte();
	}
	nabu_writeControl(CTRL_OFF);
	struct Frame* frame = malloc(sizeof(struct Frame));
	frame->length = length;
	frame->data = data;
	return frame;
}

void nabu_reset(bool coldBoot) 
{			
    byte* one   = (byte *)0x0000;
	byte* two   = (byte *)0x0001;
	byte* three = (byte *)0x0002;
	byte* four  = (byte *)0x0003;	
	
	byte* bootMode = (byte *)0xFFFE;

	switch (*four) {
		case 0xEE:
			*one = 0x3E;
			*two = 0x02;
			*three = 0x32;
		break;
		case 0x07:
			*one = 0xC3;
			*two = 0x0A;
			*three = 0x00;
		break;
	}
	
	if (coldBoot) *bootMode = 0x5A;
	else *bootMode = 0xA5;

	__asm
	di
	RST 00H;
	__endasm;
}