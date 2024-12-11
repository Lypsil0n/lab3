#include "my_iolib.h"
#include <stdio.h>

extern char inBuf[64];

int main()
{
    
    char text[] = "Hello World!";

    putText(text);
    outImage();


    return 0;
}