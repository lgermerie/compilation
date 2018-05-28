#include "printd.c"
extern int printd(int i);
int main(){
int i;
i=0;
L1: if(!(i<1000)) goto L2;
{
printd(i);
}
int _x1;
_x1=i+1;
i=_x1;
goto L1;
L2: return 0;
}
