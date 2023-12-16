#include "onabu.h"
#include <games.h>

#define byte uint8_t
#define uint uint32_t
#define ushort uint16_t

struct List *mainMenu;

struct List
{
	byte count;
	byte pages;
	char *items[20];
};

void main() {
    vdp_set_mode(2);

    byte c_joy = 1;

    byte key = 0;
    int joy = 0;

    byte menuNum = 0;
    byte pageNum = 0;
    byte menuCount = 0;
    byte menuPages = 0;

    while (1)
    {   
        struct List *menu = malloc(sizeof(struct List));
        printf("%c", 12);

        empty_frame(frame, 3);
        frame->data[0] = 0x00;
        frame->data[1] = menuNum;
        frame->data[2] = pageNum;
        hcca_writeFrame(0x30, frame);

        struct Frame *response = hcca_readFrame();
        
        nabu_writeControl(CTRL_GREEN_DP);
        menu->pages = response->data[0];
        int count = 0;
        for (int i = 1; i < response->length; count++ )
        {
            byte n_length = response->data[i++];
            char *name = malloc(n_length);	
            for (int n = 0; n < n_length; n++)
            {       
                name[n] = response->data[i++];
            }
            name[n_length] = '\0';
            menu->items[count] = name;
        }
        menu->count = count;
        
        free(response);
        
        if (menuNum == 0) { 
            menuCount = menu->count; 
            mainMenu = menu;
        }

        menuPages = menu->pages;

        if (menuNum == 0) {
            puts("Main Menu\n");
        } 
        else {
            printf("%s\n\n", mainMenu->items[menuNum-1]);
        }

        for (int i = 0; i < menu->count; i++)
        {
            puts(menu->items[i]);
        }
        
        printf("\nPress GO or Fire to continue");
        nabu_writeControl(0x01);

        do {
            key = getk();
            joy = joystick(c_joy);
        } while (key != 0x0D && !(joy && MOVE_FIRE));
                
        pageNum++;
        
        if (pageNum == menuPages) {
            menuNum++;
            pageNum = 0;
        }
        
        if (menuNum > menuCount) {
            menuNum = 0;
            pageNum = 0;
        }       
    }
}