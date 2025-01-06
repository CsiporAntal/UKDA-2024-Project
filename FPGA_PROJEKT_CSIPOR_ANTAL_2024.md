# KÖVETELMÉNYEK - VÁZLAT

##
- **Projekt címe: Hangerőség mérő**
- **Hallgató neve: Csipor Antal**
- **Szak: Számotástechnika**
- **Tantárgy: Újrakonfigurálható digitális áramkörök**
- **Projekt véglegesítésének időpontja:**
- **Fájlnév:**
  - FPGA_PROJEKT_CSIPOR_ANTAL_2024.pdf
  - FPGA_PROJEKT_CSIPOR_ANTAL_2024.md

---

## A) Projekt célja

A projekt célja egy hangmérés rendszer tervezése és implementálása FPGA alapú platformon, amely PMOD MIC szenzor segítségével képes hangerő szintet mérni. A rendszer célja a hanghullámok intenzitásának valós idejű feldolgozása, lehetőséget biztosítva a hangszint mérések automatizálására, valamint a hangerő változásainak vizualizálására. Az alkalmazás célja lehet egyszerű hangdetektálás, hangerőség szint mérése.

A projekt során a következő célokat tűztük ki:
- A PMOD MIC szenzor integrálása az FPGA rendszerrel.
- A hangerő mérésének algoritmusainak megvalósítása.
- A mért adat vizualizálása 7 szegmenses LED kijelzőn (FPGA lapon található).
- A rendszer működésének tesztelése és optimalizálása.

---

## B) Követelmények

### a. Funkcionális
- **PMOD MIC szenzor csatlakoztatása:** Az FPGA-hoz csatlakoztatott PMOD MIC szenzornak megfelelően kell kommunikálnia az FPGA-n, biztosítva az adatátvitelt.
- **Hangmérési képesség:** A rendszernek képesnek kell lennie a PMOD MIC szenzor jelének digitális feldolgozására.
- **Valós idejű feldolgozás:** A hangerőt valós időben kell mérni és kiértékelni az FPGA segítségével.
- **Hangerő detektálása:** A rendszernek képesnek kell lennie érzékelni a különböző hangerő szinteket és ennek megfelelően reagálni (értékek kijelzése).

### b. Nem funkcionális
- **Teljesítmény:** A rendszernek képesnek kell lennie valós idejű működésre, minimális késleltetéssel, hogy a hang jelfeldolgozás folyamatos és zökkenőmentes legyen.
- **Megbízhatóság:** A rendszernek stabilnak kell lennie, és nem szabad, hogy a zaj vagy egyéb környezeti tényezők befolyásolják a mérések pontosságát.
- **Skálázhatóság:** A tervezett rendszer könnyen bővíthető további érzékelőkkel vagy adatfeldolgozó egységekkel a későbbi fejlesztésekhez.

---

## C) Tervezés

### a. Tömbvázlat
![CamScanner 2025-01-06 10 24-1](https://github.com/user-attachments/assets/3b635d97-bac5-493b-928b-6f23491ae888)


---

## D) Tervezésnek a lépése

### a. Projekt modulok

#### i. Minden modulnak a tervezése
1. Idődiagram (SPI)
![CamScanner 2025-01-06 10 31-1](https://github.com/user-attachments/assets/8991b240-093c-44ab-9bfd-eff381f8504f)

3. Algoritmus (jelgenerátor)

#### ii. FSMD
1. Állapotdiagram
2. Táblázat fázisműveletekkel
3. Áramköri rajz
4. VHDL kódok

---

## E) Tesztelés

### a. Szimuláció (tömbvázlat)
#### i. VHDL

### b. Működés közben (tömbvázlat)
#### i. ILA
#### ii. VIO
#### iii. Oszc + analizátor

### c. Mérések

---

## Üzembe helyezés

- Hogyan kellene használni

---

## Forráskódok

- **Kapcsolat:** tiha@ms.sapientia.ro
- **El kell küldeni:**
  - Git projektet
  - Dokumentációt
- **Könyvtárak:**
  - Mérések
  - Forráskódok
    - Src: VHDL, Verilog
    - Sim: VHDL, Verilog
    - C, C++ (HLS)
    - .Xdc állományok
