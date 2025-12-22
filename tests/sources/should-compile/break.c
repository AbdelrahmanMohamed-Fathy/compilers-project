int x = 5;
switch (x)
{
case 1:
    x + 1;
    switch (x)
    {
    case 1:
        x + 1;
        break;
    case 3:
        x + 1;
        break;
    default:
        x + 1;
        break;
    }
    break;
case 3:
    x + 1;
    break;
default:
    x + 1;
    break;
}

for (int i = 0; i < 10; i = i + 1)
{
    x = x + i;
    break;
}

for (int i = 0; i < 10; i = i + 1)
{
    for (int j = 0; j < 10; j = j + 1)
    {
        x = x + i;
        break;
    }
    break;
}