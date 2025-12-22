void func();
void func3(int x);
int func1(int x, int y, float z);
// ===========================================================
void func2(float y)
{
    y + 1;
    return;
}

int func6()
{
    int y;
    y + 1;
    return y;
}

int func4()
{
    return 1;
}

void main()
{
    int a = func4();
    print(a);
}