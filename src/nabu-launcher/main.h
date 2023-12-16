#include "onabu.h"
//#include <input.h>
#include <games.h>
//#include <psg/vt2.h>

#define COLOR_TEXT VDP_INK_WHITE
#define COLOR_BG VDP_INK_BLACK
#define COLOR_TEXT_BG VDP_INK_LIGHT_BLUE

#define PAGE_SIZE 20

#define UI_FOOTER_LINE 23

#define MENU_START_LINE 2
#define MENU_FOOTER_LINE 22

// Printing/Screen Control

#define _Write_Str(message) \
    printf("%-32s", message);

#define _Write(message, textColor, bgColor) \
	vdp_color(textColor, bgColor, COLOR_TEXT_BG); \
	_Write_Str(message); \
	_Set_Color_Reg;

#define _Set_Color_Neg \
    vdp_color(COLOR_TEXT, COLOR_TEXT_BG, COLOR_TEXT_BG);

#define _Set_Color_Reg \
    vdp_color(COLOR_TEXT, COLOR_BG, COLOR_TEXT_BG);
 
#define _Write_Str_Neg(message) \
    _Set_Color_Neg; \
    _Write_Str(message); \
    _Set_Color_Reg;

#define _Set_Cursor_Line(p) \
    printf("%c%c%c", 22, p+32, 32); \

#define _Set_WriteLine(line, message) \
    _Set_Cursor_Line(line); \
    _Write_Str(message);

#define _Set_WriteLine_Neg(line, message) \
    _Set_Cursor_Line(line); \
    _Write_Str_Neg(message);

#define _Set_Cursor(_x,_y) \
    printf("%c%c%c", 22, _y+32, _x+32); \

#define _Disable_Scrolling() \
    printf("%c%c", 4, 0);

#define _Clr_Screen() printf("%c", 12);

#define _init(mode) \
    vdp_set_mode(mode); \
    _Set_Color_Reg; \
    _Disable_Scrolling();

#define _Change_Menu(loop) \
	state->itemNum = 0; \
	free(menu); \
	menu = RequestMenu(); \
	PrintMenu(loop);

// END

/// @brief Moves the menu cursor up
#define _Menu_Up(offset, selection, count, list) \
	_Set_Cursor_Line(offset+selection); \
	_Write_Str(list[selection]); \
	if (selection == 0) selection = count - 1; \
	else selection--; \
	_Set_Cursor_Line(offset+selection); \
	_Write_Str_Neg(list[selection]);

/// @brief Moves the menu cursor down
#define _Menu_Down(offset, selection, count, list) \
	_Set_Cursor_Line(offset+selection); \
	_Write_Str(list[selection]); \
	if (selection == count - 1) selection = 0; \
	else selection++; \
	_Set_Cursor_Line(offset+selection); \
	_Write_Str_Neg(list[selection]);


/// @brief A page of items from a larger set
struct List
{
	byte count;
	byte pages;
	char *items[PAGE_SIZE];
};

/// @brief The state struct
struct State
{
	byte menuNum;
	byte pageNum;
	byte itemNum;

};

/// @brief The settings struct
struct Settings {
	byte joystick;
};
/// @brief Prints the menu and optionally enters the main loop
/// @param loop if true, it will enter the main loop
void PrintMenu(bool loop);
/// @brief Prints the help screen
void PrintHelp();
/// @brief Prints the options screen
void PrintOptions();

/// @brief Requests the menu from the adaptor
/// @return A pointer to the menu
struct List* RequestMenu();

/// @brief Requests the adaptor list from adaptor
/// @return A pointer to the menu
struct List* RequestAdaptors();

/// @brief Reads the menu from the adaptor
/// @return A pointer to the menu
struct List* ReadMenu(struct Frame *frame);

/// @brief Sends the selected menu item to the adaptor
/// @return The boot code of the selected item
byte Select();
