int PARAM = 6;
bool test = true;

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

void testFact(){
  truc = fact(test);
}

int main()
{
  int test = 5;
  return test;
}