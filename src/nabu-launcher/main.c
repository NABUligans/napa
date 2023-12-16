#define VDP_MODE 2

#include "main.h"

#define _Str_Jump_Back "<<";
#define _Str_Jump_Forward ">>";
#define _Str_Page_Back "< ";
#define _Str_Page_Forward " >";



struct List *menu;
struct List *mainMenu;
//struct Menu *adaptors;
struct State *state;
struct Settings *settings;

void main() 
{
	_init(VDP_MODE);

	state = malloc(sizeof(struct State));
	state->menuNum = 0;
	state->pageNum = 0;
	state->itemNum = 0;

	settings = malloc(sizeof(struct Settings));
	settings->joystick = 0;
	
	_Change_Menu(true);	
}

struct List* ReadMenu(struct Frame *frame) 
{
	struct List *menu = malloc(sizeof(struct List));
	menu->pages = frame->data[0];
	int count = 0;
	for (int i = 1; i < frame->length; count++ )
	{
		byte n_length = frame->data[i++];
		char *name = malloc(n_length);	
		for (int n = 0; n < n_length; n++)
		{       
			name[n] = frame->data[i++];
		}
		name[n_length] = '\0';
		menu->items[count] = name;
	}
	menu->count = count;
	free(frame);
	return menu;
}

struct List* RequestAdaptors() 
{
	
	vdp_noblank();
	nabu_frame(req, 1)
	req->data[0] = 0x10;
	hcca_writeFrame(0x30, req);
	struct Frame *frame = hcca_readFrame();
	nabu_writeControl(CTRL_GREEN);
	struct List *list = ReadMenu(frame);
	free(frame);
	return list;
}

struct List* RequestMenu()
{
	vdp_noblank();
	nabu_frame(req, 3)
	req->data[0] = 0x00;
	req->data[1] = state->menuNum;
	req->data[2] = state->pageNum;
	hcca_writeFrame(0x30, req);
	struct Frame *frame = hcca_readFrame();
	nabu_writeControl(CTRL_GREEN);
	struct List *menu = ReadMenu(frame);
	free(frame);
	if (state->menuNum == 0) mainMenu = menu;
	return menu;
}

void PrintMenu(bool loop)
{				
	_Clr_Screen();
	//nabu_write_control_reg(CTRL_GREEN);
	if (state->menuNum == 0) { _Write_Str_Neg("NABU Launcher"); }
	else { _Write_Str_Neg(mainMenu->items[state->menuNum-1]); }
	
	_Set_Cursor_Line(UI_FOOTER_LINE);
	_Write_Str_Neg("H: Help|O: Options");
	_Set_Cursor_Line(MENU_START_LINE);

	// Print the menu
	for (byte i = 0; i < menu->count; i++)
	{
		if (i == state->itemNum) {
			_Write_Str_Neg(menu->items[i]);
		}
		else {
			_Write_Str(menu->items[i]);
		}
	}

	#ifndef DEBUG_MODE
	char *footer = malloc(32);
	if (menu->pages > 1)
	{
		char *lead = malloc(2);
		char *tail = malloc(2);

		if (state->menuNum > 0) {
			if (state->pageNum > 0) { lead = _Str_Page_Back; }
			else { lead = _Str_Jump_Back; }
		}

		if (state->pageNum < menu->pages-1) { tail = _Str_Page_Forward; }
		else { tail = _Str_Jump_Forward; }

		sprintf(footer, "%s  %d/%d  %s", lead, state->pageNum+1, menu->pages, tail);
	} else footer = "";
	
	_Set_Cursor_Line(MENU_FOOTER_LINE);
	_Write(footer, VDP_INK_BLACK, VDP_INK_WHITE);
	#endif
	nabu_writeControl(CTRL_OFF);
	vdp_blank();
	
	
	while (loop)
	{	
		byte key = 0;
		int joy = 0;
		do {
			key = getk();
			joy = joystick(settings->joystick);	
		} while (key == 0 && joy == 0);

		#ifdef DEBUG_MODE
		_Set_Cursor_Line(22);
		char *debug = malloc(32);
		sprintf(
			debug,
			"M: %d, P: %d/%d, I: %d, C: %d, K: %03d, J: %03d", 
			state->menuNum, 
			state->pageNum,
			menu->pages, 
			state->itemNum, 
			menu->count,
			key, 
			joy
		);
		_Write(debug, VDP_INK_BLACK, VDP_INK_WHITE);
		free(debug);
		#endif
		
		if ((key == 0xe2) || joy & MOVE_UP)
		{
			_Menu_Up(MENU_START_LINE, state->itemNum, menu->count, menu->items);
		}
		else if ((key == 0xE3) || joy & MOVE_DOWN )
		{
			_Menu_Down(MENU_START_LINE, state->itemNum, menu->count, menu->items);
		}
		else if ((key == 0xE1 || key == 0xE5) || joy & MOVE_LEFT)
		{
			if (state->menuNum > 0 && state->pageNum == 0)
			{	// Back Home
				state->menuNum = 0;
				_Change_Menu(false);
			}
			else if (state->pageNum > 0)
			{	// Back Page
				state->pageNum--;
				_Change_Menu(false);
			}
			else if (state->pageNum == 0 && menu->pages > 1)
			{ 	// To Last Page (Only works on the home page)
				state->pageNum = menu->pages-1;
				_Change_Menu(false);
			}
		}
		else if ((key == 0xE0 || key == 0xE4) || joy & MOVE_RIGHT)
		{
			if (state->menuNum == 0) {
				state->menuNum = state->itemNum+1;
				state->pageNum = 0;
				_Change_Menu(false);
			}
			else if ((state->pageNum == 0 && menu->pages > 1) || state->pageNum != menu->pages-1)
			{
				state->pageNum++;
				_Change_Menu(false);
			}
			else if (state->pageNum == menu->pages-1) {
				state->pageNum = 0;
				_Change_Menu(false);
			}
		}
		else if ((key == 0x0D) || joy & MOVE_FIRE)
		{
			if (state->menuNum == 0)
			{
				state->menuNum = state->itemNum+1;
				state->pageNum = 0;
				_Change_Menu(false);
			}
			else
			{
				byte bootMode = Select();
				if (bootMode == 0x00) continue;
				loop = false;
				nabu_reset(bootMode == 0xFE ? true : false);
			}
		}
		else if (key == 0x1B) 
		{
			if (state->pageNum > 1) 
			{ 	//Back to the first page
				state->pageNum = 0;
				_Change_Menu(false);
			} else if (state->menuNum > 0) 
			{ 	//Back to the main menu
				state->menuNum = 0; 
				state->pageNum = 0;
				_Change_Menu(false);
			}
		}
		else if (key == 0x68 || key == 0x48) 
		{ 	//h or H
			PrintHelp();
			PrintMenu(false);
		}
		else if (key == 0x6F || key == 0x4F) //o or O
		{ 	//adaptors = RequestAdaptors();
			PrintOptions();
			PrintMenu(false);
		}
	}
	
}

#define HELP_TEXT_BACK "<||/Left/ESC: Back"

void PrintHelp()
{
	vdp_noblank();
	nabu_writeControl(CTRL_GREEN);
	_Clr_Screen();
	_Write_Str_Neg("Help");
	_Set_Cursor_Line(MENU_START_LINE);
	_Write("Menu Navigation:", VDP_INK_BLACK, VDP_INK_WHITE);
	_Write_Str("    Up/Down  : Move Cursor");
	_Write_Str("  Left/Right : Prev/Next Page");
	_Write_Str("   <||/||>   : Prev/Next Page");
	_Write_Str("    GO/Fire  : Select Item");
	_Write_Str("");
	_Write_Str("     ESC     : Go Back");
	_Write_Str("      H      : This Help Screen");
	_Write_Str("      O      : Change Options");

	_Set_Cursor_Line(18);
	_Write_Str("NABU Launcher v1.0.1");
	_Write_Str("(c) 2023 Nick Daniels");
	_Write_Str("Based on the Headless Menu");
	_Write_Str("From NabuNetwork.com");

	_Set_Cursor_Line(UI_FOOTER_LINE);
	_Write_Str_Neg(HELP_TEXT_BACK);
	nabu_writeControl(CTRL_OFF);
	vdp_blank();
	
	byte key = 0;
	uint joy = 0;
	byte loop = true;
	while(loop)
	{
		do {
			joy = joystick(settings->joystick);
			key = getk();
		} while (key == 0 && joy == 0);

		if ((key == 0xE1 || key == 0xE5) || key == 0x1B || joy & MOVE_LEFT) {
			loop = false;
		}
	}
	
	vdp_noblank();
	nabu_writeControl(CTRL_GREEN);
}

void PrintOptions()
{
	vdp_noblank();
	nabu_writeControl(CTRL_GREEN);
	_Clr_Screen();
	
	_Write_Str_Neg("Options");
		
	_Set_Cursor_Line(UI_FOOTER_LINE);
	_Write_Str_Neg(HELP_TEXT_BACK);

	byte key = 0;
	uint joy = 0;
	byte choice = settings->joystick;
	bool loop = true;
			
	_Set_Cursor_Line(MENU_START_LINE);
	_Write("Joystick:", VDP_INK_BLACK, VDP_INK_WHITE);
	for (byte j = 0; j < GAME_DEVICES; j++)
	{	
		if (j == settings->joystick) {
			_Write_Str_Neg(joystick_type[j]);
		}
		else _Write_Str(joystick_type[j]);
	}
	byte v_offset = MENU_START_LINE+1;
	byte v_offset2 = v_offset+GAME_DEVICES+2;
	nabu_writeControl(CTRL_OFF);
	vdp_blank();

	while (1)
	{
		_Set_Cursor_Line(v_offset2);
		printf("Current: %23s", joystick_type[settings->joystick]);
		do {
			key = getk();
			joy = joystick(settings->joystick);	
		} while (key == 0 && joy == 0);
		
		#ifdef DEBUG_MODE
		_Set_Cursor_Line(22);
		char *debug = malloc(32);
		sprintf(debug, "K: %03d, J: %03d, C: %d CJ: %d", key, joy, choice, settings->joystick);
		_Write(debug, VDP_INK_BLACK, VDP_INK_WHITE);
		free(debug);
		#endif
		if ((key == 0xe2) || joy & MOVE_UP)
		{
			_Menu_Up(v_offset, choice, GAME_DEVICES, joystick_type);
		}
		else if ((key == 0xE3) || joy & MOVE_DOWN)
		{
			_Menu_Down(v_offset, choice, GAME_DEVICES, joystick_type);
		}
		//else if (key == 0x45 || key == 0x65) {
		if ((key == 0xE1 || key == 0xE5) || key == 0x1B || joy & MOVE_LEFT) {
			//free(adaptors);
			vdp_noblank();
			nabu_writeControl(CTRL_GREEN);
			return;
		}
		else if (key == 0x0D){
			settings->joystick = choice;
		}	
	}
}

byte Select()
{
	nabu_writeControl(CTRL_YELLOW);
	nabu_frame(req, 4)
	req->data[0] = 0x01;
	req->data[1] = state->menuNum;
	req->data[2] = state->pageNum;
	req->data[3] = state->itemNum;
	hcca_writeFrame(0x30, req);
	nabu_writeControl(0x01);
	return hcca_readByte();
}

