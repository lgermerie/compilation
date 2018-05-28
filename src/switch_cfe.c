#include "printd.c"
extern int printd(int i);
int main(){
int i;
int j;
i=3;
{
if(i != 0) goto L1;
printd(0);
goto L6;
L1 :

if(i != 1) goto L2;
printd(1);
goto L6;
L2 :

if(i != 2) goto L3;
printd(2);
goto L6;
L3 :

if(i != 3) goto L4;
printd(3);
L4 :
if(i != 4) goto L5;
printd(4);
L5 :
printd(-1);
}
L6:;
}
