int x = 10;
int y = 0;

for (int i = 0; i < 10; i = i+1) {
    x = x + i;
}

for (int i = 0; i < 10; i = i+1)  x = x + i;

for (int i = 0; i < 3; i = i+1);

while (x < 10){ 
    x = x + 1; 
}

while (y < 5) y = y + 1;

while (x < 5);

repeat {
     x = x + 1; 
    } until(x > 10);

repeat y = y + 1; until(y > 10);

repeat; until(y > 10);