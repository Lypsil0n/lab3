#include "my_iolib.h"
#include <stdio.h>

//test

int main()
{
    char msg[] = "Hello World!\n";
    char msg2[] = "How are you doing today?\n";
    char msg3[] = "I'm doing great!";

    putText(msg);

    putText(msg2);

    putText(msg3);
    

    int pos = getOutPos();
    printf("Current position: %d\n", pos);
    outImage();
}

