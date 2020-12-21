int PARAM = 5;
int machin = 3;

int fact(int n)
{
  if (n < 2)
  {
    return 1;
  }
  else
  {
    return n * fact(n + -1);
  }
}
int addition(int a, int b){
  return a + b;
}
void main()
{
  int test = 2 + 3;
  test = 4 +3 ;
  putchar(fact(PARAM));
}
