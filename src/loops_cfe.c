#include "printd.c"
extern int printd(int i);
int main(){
int i;
i=0;
L2: 
{
printd(i);
int _x1;
_x1=i+2;
i=_x1;
}

L1:  if(i<10) goto L2;
i=-10;
L3: if(!(i<=10)) goto L4;
printd(i);
int _x2;
_x2=i+1;
i=_x2;
goto L3;
L4: i=0;
L6: 
{
printd(i);
int _x3;
_x3=i-1;
i=_x3;
}

L5:  if(i>=-20) goto L6;
return 0;
}
