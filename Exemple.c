int PARAM = 5;
bool test = true;

bool truc()
{
}
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

void jeSuisUnDebutant(int p1, bool p2)
{
  int test = 5;
  int test2 = 5 + 3;
  return test;
}

void main()
{
  putchar(fact(PARAM));
}
