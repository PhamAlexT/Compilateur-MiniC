int PARAM = 6;
bool test = true;

int fact(int n) {
  if (n < 2) {
    return 1;
   } else {
  return n * fact(n + -1);
  }
}

int dummy(){
  int machin = 5 + test;
  bool truc = false;
}

int main(){
  putchar(fact(PARAM));
}