#include "printd.c"
extern int printd(int i);
int fact(int n){
if(!(n<=1)) goto L1;
return 1;
L1:;
int _x1;
int _x2;
_x1=n-1;
_x2=n*fact(_x1);
return _x2;
}
int main(){
printd(fact(10));
return 0;
}
