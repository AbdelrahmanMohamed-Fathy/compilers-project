
int func();
void func3(float y);
int func1(int x, int y, float z);
// ===========================================================
void func3(float y)
{
    y + 1;
    return;
}

int func()
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