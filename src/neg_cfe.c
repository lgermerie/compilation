#include "printd.c"
extern int printd(int i);
int main(){
int j;
j=123;
printd(-j);
printd(-123);
int _x1;
_x1=123+0;
printd(-(_x1));
int _x2;
_x2=j+0;
printd(-(_x2));
return 0;
}
