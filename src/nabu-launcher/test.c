#include <stdlib.h>
#include <stdio.h>
#include <video/tms99x8.h>
#include <arch/nabu/hcca.h>

#define byte uint8_t
#define uint uint32_t
#define ushort uint16_t

struct Menu
{
	byte count;
	byte pages;
	char *items[20];
};

void main() {
    vdp_set_mode(0);
    byte loop = 0;
    while (1)
    {
        // I've had to put this here because there is a key press 
        // in the buffer on restart.
        puts("Press any key to continue\n");
        getkey(); 
        if (loop > 9) loop = 0;
        
        struct Menu *menu = malloc(sizeof(struct Menu));
        printf("%c", 12);

        hcca_reset_write();
        hcca_start_read(HCCA_MODE_RB, NULL, 0);

        hcca_writeByte(0x30);
        hcca_writeByte(0);//loop);
        hcca_writeByte(0);
   
        hcca_start_write(HCCA_MODE_BLOCK, NULL, 0);
        ushort length = hcca_readUInt16();
        byte *data = malloc(length);
        for (int i = 0; i < length; i++)
        {
            data[i] = hcca_readByte();
        }
        printf("Menu Bytes: %d\n", length);
        
        menu->pages = length == 0 ? 0 : data[0];        
        printf("Menu Pages: %d\n", menu->pages);
        
        
        int count = 0;
        for (int i = 1; i < length; count++ )
        {
            byte n_length = data[i++];
            printf("I: %d, L: %d\n", count, n_length);
            char *item = malloc(n_length);
            for (int n = 0; n < n_length; n++)
            {       
                item[n] = data[i++];
            }
            item[n_length] = '\0';
            menu->items[count] = item;
            
        }
        menu->count = count;
        free(data);

        printf("Menu Count: %d\n", menu->count);
        
        for (int i = 0; i < menu->count; i++)
        {
            printf("%s\n", menu->items[i]);
        }
        
        free(menu);
        loop++;

        puts("________________________________\n");
    }
}