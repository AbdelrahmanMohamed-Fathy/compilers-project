int x = 10;
int y = 0;

for (int i = 0; i < 10; i++) {
    x = x + i;
}

for (int i = 0; i < 10; i++)  x = x + i;

for (int i = 0; i < 3; i++);

while (x < 10){ 
    x++; 
}

while (y < 5) y++;

while (x < 5);

do{x++;} while (x < 5);

do y++; while (y < 5);

do; while (y < 5);

repeat {
     x++; 
    } until(x > 10);

repeat y++; until(y > 10);

repeat; until(y > 10);