# Hangerőség mérése FPGA lapon 

## Pmod MIC szenzor használatával

### Projekt dokumentáció:

1. **Projekt céljainak megfogalmazása**
2. **Követelmények:**
   - a. Funkcionális
   - b. Nem funkcionális
3. **Specifikáció**
4. **Tervezés:**
   - a. Architektúra létrehozása
   - b. Tervezési módszerek
   - c. Moduláris tervezés
   - d. Szimulációs tesztelés
     - i. Almodulok
     - ii. Teljes rendszer
   - e. Mérési eredmények külső eszközzel való mérés
5. **Könyvészet**

---

## Projekt céljainak megfogalmazása:

A projekt célja egy hangmérés rendszer tervezése és implementálása FPGA alapú platformon, amely PMOD MIC szenzor segítségével képes hangerő szintet mérni. A rendszer célja a hanghullámok intenzitásának valós idejű feldolgozása, lehetőséget biztosítva a hangszint mérések automatizálására, valamint a hangerő változásainak vizualizálására. Az alkalmazás célja lehet egyszerű hangdetektálás, hangerőség szint mérése.

A projekt során a következő célokat tűztük ki:
- A PMOD MIC szenzor integrálása az FPGA rendszerrel.
- A hangerő mérésének algoritmusainak megvalósítása.
- A mért adat vizualizálása 7 szegmenses LED kijelzőn (FPGA lapon található).
- A rendszer működésének tesztelése és optimalizálása.

---

## Követelmények

### A. Funkcionális követelmények
- **PMOD MIC szenzor csatlakoztatása:** Az FPGA-hoz csatlakoztatott PMOD MIC szenzornak megfelelően kell kommunikálnia az FPGA-n, biztosítva az adatátvitelt.
- **Hangmérési képesség:** A rendszernek képesnek kell lennie a PMOD MIC szenzor jelének digitális feldolgozására.
- **Valós idejű feldolgozás:** A hangerőt valós időben kell mérni és kiértékelni az FPGA segítségével.
- **Hangerő detektálása:** A rendszernek képesnek kell lennie érzékelni a különböző hangerő szinteket és ennek megfelelően reagálni (értékek kijelzése).

### B. Nem funkcionális követelmények
- **Teljesítmény:** A rendszernek képesnek kell lennie valós idejű működésre, minimális késleltetéssel, hogy a hang jelfeldolgozás folyamatos és zökkenőmentes legyen.
- **Megbízhatóság:** A rendszernek stabilnak kell lennie, és nem szabad, hogy a zaj vagy egyéb környezeti tényezők befolyásolják a mérések pontosságát.
- **Skálázhatóság:** A tervezett rendszer könnyen bővíthető további érzékelőkkel vagy adatfeldolgozó egységekkel a későbbi fejlesztésekhez.
