#include <stdio.h>

extern int my_printf(const char *str, ... );

int main()
{
    char *name = "Kalinich";
    char *name1 = "Hi,";
    int number = 8;
    int age = 18;
    char symbol = 't';
    my_printf("%d !\n", -90);
    my_printf("%s do you know that head of matan f*cker is %s and %c - is letter?\n", name1, name, symbol);
    my_printf("8 in dec = %x in hex\n", number);
    my_printf("8 in dec = %o in oct\n", number);
    my_printf("8 in dec = %b in bin\n", number);
    my_printf("I am %d years old\n", age);
    my_printf("abs(%d) = %d\n", -18, 18);
    return 0;
}