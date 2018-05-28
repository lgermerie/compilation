#include "printd.c"
extern int printd(int i);
int main(){
int i;
i=0;
L2: if(!(i<10)) goto L3;
{
if(!(i==5)) goto L1;
BREAK
L1:
}
int _x1;
_x1=i+1;
i=_x1;
goto L2;
L3: printd(i);
}
