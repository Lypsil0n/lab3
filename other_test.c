#include "my_iolib.h"
#include <stdio.h>

int main()
{
    int pos = getInPos();

    inImage();

    printf("%d\n", pos);


    return 0;
}