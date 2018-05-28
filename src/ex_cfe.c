#include "printd.c"
int t[100];
extern int printd(int d);
int calcul(int x,int y){
int _x1;
_x1=x*y;
return (_x1);
}
int main(){
int i;
i=0;
L1: if(!(i<100)) goto L2;
{
int j;
int _x3;
_x3=i+1;
j=_x3;
t[i]=calcul(i,j);
}
int _x2;
_x2=i+1;
i=_x2;
goto L1;
L2:;int _x4;
_x4=i-1;
printd(t[_x4]);
}
