#include "printd.c"
extern int printd(int i);
int main(){
int i;
int j;
int k;
i=45000;
j=-123;
k=43;
int _x1;
int _x2;
int _x3;
int _x4;
int _x5;
int _x6;
int _x7;
int _x8;
int _x9;
int _x10;
int _x11;
_x1=i+j;
_x2=(_x1)*k;
_x3=_x2/100;
_x4=_x3+j;
_x5=_x4*k;
_x6=_x5*i;
_x7=_x6-j;
_x8=_x7<<k;
_x9=k-j;
_x10=_x9>>2;
_x11=(_x8)/(_x10);
printd(_x11);
return 0;
}
