#include "my_iolib.h"
#include <stdio.h>

//test

int main()
{
    char msg[] = "Hello World!";
    char msg2[] = "How are you doing?";
    char msg3[] = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";

    putText(msg);
    outImage();

    putText(msg2);
    outImage();

    putText(msg3);
    outImage();

    char anotherMsg[] = "Hello again";
    putText(anotherMsg);
    outImage();

}

