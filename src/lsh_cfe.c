#include "printd.c"
extern int printd(int i);
int main(){
int i;
int j;
i=45000;
j=3;
int _x1;
_x1=i<<j;
printd(_x1);
int _x2;
_x2=45000<<j;
printd(_x2);
int _x3;
_x3=i<<3;
printd(_x3);
int _x4;
_x4=45000<<3;
printd(_x4);
int _x5;
int _x6;
_x5=j+0;
_x6=i<<(_x5);
printd(_x6);
int _x7;
int _x8;
_x7=i+0;
_x8=(_x7)<<j;
printd(_x8);
int _x9;
int _x10;
int _x11;
_x9=i+0;
_x10=j+0;
_x11=(_x9)<<(_x10);
printd(_x11);
int _x12;
int _x13;
_x12=i+0;
_x13=(_x12)<<3;
printd(_x13);
int _x14;
int _x15;
_x14=j+0;
_x15=45000<<(_x14);
printd(_x15);
return 0;
}
