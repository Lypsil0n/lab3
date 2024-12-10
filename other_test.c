#include "my_iolib.h"
#include <stdio.h>

int main()
{
    char inBuf[64]; 

    printf("Skriv något: ");
    inImage();  


    if (inBuf[0] == '\0') {
        printf("No input was read.\n");
    } else {
        printf("Du skrev: %s\n", inBuf);  
    }

    return 0;
}