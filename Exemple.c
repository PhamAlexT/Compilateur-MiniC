int PARAM = 6;
bool test = true;

int fact(int n) {
  if (n < 2) {
    return 1;
   } else {
  return n * fact(n + -1);
  }
}

void dummy(){
  int machin = 5;
  bool truc = false;

  int cavatoutcasser = PARAM * test;
}

int main(){
  putchar(fact(PARAM));
}