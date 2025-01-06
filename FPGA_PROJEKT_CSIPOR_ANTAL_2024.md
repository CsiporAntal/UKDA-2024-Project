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
![image](https://github.com/user-attachments/assets/8134e4a8-6524-48fe-b840-d25a1bebcecb)

A rendszerben az SPI interfész a PMOD MIC szenzorról érkező digitális adat beolvasását végzi. A szenzor által generált digitális jel az alábbi formátumban érkezik:
- **4 vezető '0'-ás bit**, amelyek a keret szinkronizációjához szükségesek.
- **12 bites adat**, amely az ADC által digitalizált hangerő szintet tartalmazza.

Az SPI protokoll használata során a CS jel (Chip Select) kiemelt szerepet játszik. A CS jel:
- Alaphelyzetben **1**, amely az inaktív állapotot jelzi.
- Kommunikáció akkor indul, amikor a CS jel **0-ra vált**, így aktiválva az adatátvitelt.

Az idődiagram működését az alábbi jelek határozzák meg:
- **CS jel:** A kommunikáció aktiválásához és deaktiválásához szükséges.
- **CLK jel:** Szinkronizálja a bitfolyamot.
- **MOSI vonal:** Adatok küldése a master eszközről a slave eszközre.
- **MISO vonal:** Adatok fogadása a slave eszközről a master eszközre.

Az SPI idődiagram biztosítja az FPGA és a PMOD MIC közötti megbízható adatátvitelt az órajel és az adatjelek helyes időzítésével.

2. Algoritmus

A beolvasott digitális jelet egy algoritmus dolgozza fel, amely az alábbi lépéseket tartalmazza:
- **Adatpufferelés:** Az SPI interfészen érkező adatokat egy pufferben tároljuk, hogy az adatfolyam folytonosságát biztosítsuk.
- **Maximális hangerő számítása:** A 12 bites adat alapján a rendszer kiszámolja a beérkező hanghullámok maximális amplitúdóját.
  - A számítás az alábbi képlet alapján történik:
    \[
    Hangerő = \sqrt{\frac{1}{N} \sum_{i=1}^{N} x[i]^2}
    \]
    ahol:
    - \(x[i]\) a digitális jelszintek értéke az egyes mintákból,
    - \(N\) az összes minta száma a számításhoz.
  - Ez az RMS (Root Mean Square) számítás, amely az időtartománybeli jel intenzitását adja meg. Ez a módszer biztosítja a pontos és stabil hangerőérték meghatározását.
- **Hangerő skálázása:** A számított értékeket normalizáljuk, hogy azok a kijelző által kezelhető formában legyenek (pl. BCD kódolás a 7 szegmenses kijelzőhöz).

3. Kijelző vezérlő modul (7 szegmenses LED)
A mért hangerő szinteket a 7 szegmenses LED kijelző jeleníti meg az FPGA-n. A kijelző vezérlése a következő lépésekből áll:
- **Adatkonverzió:** A mért hangerőszintet bináris formátumból BCD formátumba alakítjuk.
- **Multiplexálás:** Több számjegy esetén multiplexálást alkalmazunk, hogy a kijelzők gyorsan és váltakozva mutassák a megfelelő értékeket.
- **Kijelző meghajtása:** A kijelző szegmenseit vezérlő jeleket a feldolgozott adatok alapján generáljuk, amely a megfelelő számjegyek megjelenítéséért felel.

A mért hangerőséget megjelenitjuk az FPGAán található 7 szegmenses kijelzőn.

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
