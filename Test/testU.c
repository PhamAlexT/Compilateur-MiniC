int cst = 2;
int PARAM = 5;

  int fact(int n) {
    if (n < 2) {
      return 1;
    } else {
      return n * fact(n + -1);
    }
  }

  void main() {
    bool test = false;
    bool machin = true;
    bool testbool = test==machin;
    bool testbool2 = test!=machin;
    putchar(fact(PARAM));
  }
