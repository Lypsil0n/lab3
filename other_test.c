#include "my_iolib.h"
#include <stdio.h>

//test

int main()
{
    char buf[64];
    getText(buf, 12);
    putText(buf);
    outImage();
}
