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

void main()
{
  int test = 2;
  putchar(fact(PARAM));
}
