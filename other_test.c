#include "my_iolib.h"
#include <stdio.h>

//test

int main()
{   
    int temp;
    unsigned int i, pos;
    int sum = 0;

    inImage();
    
    for (i = 5; i > 0; i--)
    {
        temp = getInt();
        if (temp < 0)
        {
            pos = getOutPos();
            pos--;
            setOutPos(pos);
        }
        sum += temp;
    }
    

    printf("%d\n", sum);
}

