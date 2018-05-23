 int t[100];

 extern int printd(int d);

 int calcul(int x, int y) {
   int _t1;       /* declaration de la var. temp. */
   _t1=x*y;
   return _t1;
 }

 int main() {
   int i;
   int _t1,_t3;/* declaration des var. temp. */
   int *_t2;   /* declaration des var. temp. */
   i=0;        /* initialisation de la boucle */
L1: if (i>=100) goto L2; /* test de la boucle */
   {
      	int j;
	int _t1;
	int *_t2;
   	j=i+1;
   	_t1=calcul(i,j);
   	_t2=t+i;            /* fait t[i]=t1 */
   	*_t2=_t1;
  	i=i+1;              /* increment de la boucle */
   }
   goto L1; 
L2:_t1=i-1;
   _t2=t+_t1;          /* fait t3 = t[t1] */
   _t3=*_t2;
   printd(_t3);
 }
