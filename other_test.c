#include "my_iolib.h"
#include <stdio.h>

//test

int main()
{   
    long long sum = 0;
    long long temp;
    unsigned int pos, count;

    for (count=5; count>0; count-- ){
        temp = getInt();
        if (temp < 0){
            pos = getOutPos();
            pos--;
            setOutPos(pos);
        }
        sum += temp;
        putInt(temp);
        putChar('+');
    }
    pos = getOutPos();
    pos--;
    setOutPos(pos);

    putChar('=');
    putInt(sum);
    outImage();
}   

