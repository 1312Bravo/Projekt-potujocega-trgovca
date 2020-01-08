def TravelingSalesmenProblem(MinPolozaj, MaxPolozaj, SteviloTock, DimProstora=2): #Določimo interval s katerega jemljemo točke, število točk in dimenzijo prostora grafa
     import time

     # USTVARIMO GRAF
     # Začnemo meriti čas delovanja algoritma.
     ZacetniCasGraf = time.time()
     # V prostor "namečemo" točke.
     Tocke = [random_vector(RR, DimProstora, min = MinPolozaj, max = MaxPolozaj) for i in range(SteviloTock)]
     # Naredimo matriko, kjer stolpci in vrstice predstavljajo točke, elementi matrike so pa razdalje med njimi.
     Matrika = Matrix([[(u-v).norm() for u in Tocke]for v in Tocke])
     # Iz matrike ustvaruni graf.
     Graf = Graph(Matrika)
     # Lepše razporedimo točke po prostoru (ravnini).
     Graf._pos = dict(enumerate(Tocke))
     # Konec delovanja algoritma, ustavimo čas.
     KoncniCasGraf = time.time()
     # Pretečeni čas algoritma za ustvarjanje grafa
     CasGraf = KoncniCasGraf - ZacetniCasGraf


     # TOČNA REŠITEV PROBLEMA
     # Začnemo meriti čas delovanja algoritma.
     ZacetniCasTocna = time.time()
     # Najkrakša pot v danem grafu, tj. točna rešitev problema.
     MinDrevo = Graf.traveling_salesman_problem(use_edge_labels=True)
     TocnaRazdalja = sum(MinDrevo.edge_labels())
     # Ustavimo čas
     KoncniCasTocna = time.time()
     # Pretečeni čas delovanja celotnega algoritma za izračun najkrajše poti v danem grafu
     CasTocna = CasGraf + (KoncniCasTocna - ZacetniCasTocna)
     #print("Tocna resitev problema:"), TocnaRazdalja
     #print("Casovna zahtevnost algoritma za drevo z minimalno tezo:"), CasTocna
     #print("Najkrajsa pot prek algoritma za drevo z minimalno tezo:"), MinDrevo.show()

     # DOUBLE TREE ALGHORITM
     # Začnemo meriti čas delovanja algoritma za izračun drevesa z minimalno težo, brez ustvarjanja grafa.
     ZacetniCasT = time.time()
     # Vozlišča oziroma povezave drevesa z minimalno težo v grafu.
     VozliscaDrevesa = Graf.min_spanning_tree()
     # Ustvarimo graf iz dobljenih vozlišč.
     T = Graph(VozliscaDrevesa)
     # Poskrbimo, da so vozlišča na enakih položajih kot v prvotnem grafu.
     T._pos = Graf._pos
     # Končamo merjenje časa algoritma, prepolovili smo zato, ker to potrebujemo tudi v Christofidisovem algoritmu in bomo tako lažje izmerili čas delovanja le tega.
     KoncniCasT = time.time()
     # Začnemo meriti čas novega algoritma, ki je zgolj v Double tree algoritmu
     ZacetniCasUsmerjen = time.time()
     # Usvtarimo usmerjen graf
     UsmerjenGraf = DiGraph(T)
     UsmerjenGraf._pos = Graf._pos
     # Ustvarimo množico vozlišč, kamor bomo dodajali vozlišča v vrstnem redu, kot si sledijo v Eulerjevem sprehodu v drevesu z minimalno težo.
     VozliscaEuler = []
     # Poberemo samo prvo vozlišče v povezavi. (izpustimo konec povezave in njeno težo)
     for u, _, _ in UsmerjenGraf.eulerian_circuit():
         if u not in VozliscaEuler:
             VozliscaEuler.append(u)
     # Iz zaporedja vozlišč v Eulerjevem sprehodu naredimo podgraf prvotnega grafa. Vozlišča, ki sta sosednja povežemo.
     DoubleTreeGraf = Graf.subgraph(edges=[(VozliscaEuler[i-1], VozliscaEuler[i]) for i in range(len(VozliscaEuler))])
     # Vsota povezav na najkrajši poti pred Double tree algoritma
     DoubleTreeRazdalja = sum(DoubleTreeGraf.edge_labels())
     # Prenehamo meriti čas.
     KoncniCasUsmerjen = time.time()
     # Celoten pretečen čas izvajanja Double tree algoritma.
     CasDT = CasGraf + (KoncniCasT - ZacetniCasT) + (KoncniCasUsmerjen - ZacetniCasUsmerjen)
     #print("Priblizek za tocno resitev prek Double tree algoritma:"), DoubleTreeRazdalja
     #print("Casovna zahtevnost Double tree algoritma:"), CasDT
     #print("Najkrajsa pot prek Double tree algoritma:"), DoubleTreeGraf.show()

     # CHRISTOFIDIES ALGHORITM
     # Na začetku usztvarimo še graf in graf T, kar je že narejeno zgoraj in to tu uporabimo, nato delamo naprej.
     ZacetniCasPodgraf = time.time()
     # Naredimo podrgaf iz vozlišč drevesa z liho stopnjo
     PodgrafLiha = Graf.subgraph(u for u in T if T.degree(u) % 2 == 1)
     # Najtežja povezava v podgrafu
     MaxEdge = max(PodgrafLiha.edge_labels())
     # Težo povezav v grafu damo na obratno, torej tu je najlažja v bistvu najtežja, ker matching funkcije deluje na najlažji.
     WW = Graph([(u, v, MaxEdge-t) for u, v, t in PodgrafLiha.edges()])
     WW._pos = {u: Graf._pos[u] for u in WW}
     # Naredimo nov graf iz drevesa z minimalno težo, kjer ponovno uteži na povezavah postavimo na prvotno težo.
     TT = Graph(T.edges() + [(u, v, MaxEdge-t) for u, v, t in WW.matching(use_edge_labels=True)], multiedges=True)
     TT._pos = Graf._pos
     # Naredimo množico vozlišč kamor bomo dodajali vozlišča v vrstnem redu kakor si sledi v Eulerjevem sprehodu.
     Vozlisca = []
     for u, _, _ in TT.eulerian_circuit():
         if u not in Vozlisca:
             Vozlisca.append(u)
     # Iz zaporedja vozlišč v Eulerjevem sprehodu naredimo podrgaf prvotnega grafa.
     ChristofidiesGraf = Graf.subgraph(edges=[(Vozlisca[i-1], Vozlisca[i]) for i in range(len(Vozlisca))])
     # Razdalja najkrajše poti v poti dobljeni prek Christofidiesovega algoritma.
     ChristofidiesRazdalja = sum(ChristofidiesGraf.edge_labels())
     # Algoritem je zaključen.
     KoncniCasPodgraf = time.time()
     # Celotni čas delovanja Christofidisovega algoritma.
     CasChristo = CasGraf + (KoncniCasT - ZacetniCasT) + (KoncniCasPodgraf - ZacetniCasPodgraf)
     #print("Priblizek za tocno resitev prek Christofidiesovega algoritma:"), ChristofidiesRazdalja
     #print("Casovna zahtevnost Christofidiesovega algoritma:"), CasChristo
     #print("Najkrajsa pot pred Christofidiesovega algoritma:"), ChristofidiesGraf.show()

     DoubleTreeMistake = abs(TocnaRazdalja - DoubleTreeRazdalja)
     ChristofidiesMistake = abs(TocnaRazdalja - ChristofidiesRazdalja)
     return [TocnaRazdalja, DoubleTreeMistake, ChristofidiesMistake, CasTocna, CasDT, CasChristo]

     #print("Napaka Double tree algoritma:"), DoubleTreeMistake
     #print("Napaka Christofidiesovega algoritma:"), ChristofidiesMistake
     #print("Casovna zahtevnost Double tree algoritma:"), CasDT
     #print("Casovna zahtevnost Christofidiesovega algoritma:"),CasChristo

     #NapakeDT.append(DoubleTreeMistake)
     #NapakeChristo.append(ChristofidiesMistake)
     #CasiDT.append(CasDT)
     #CasiChristo.append(CasChristo)
     #CasiTocna.append(CasTocna)

#print("Napake Double tree algoritma:"), NapakeDT
#print("Napake Christofidiesovega algoritma:"), NapakeChristo
#print("Casovne zahtevnosti Double tree algoritma:"), CasiDT
#print("Casovne zahtevnosti Christofidiesovega algoritma:"), CasiChristo
#print("Casovne zahtevnosti algoritma za drevo z minimalno tezo:"), CasiTocna

import csv

def zapisi_csv_Test(MinPolozaj, MaxPolozaj, SteviloTock, st_testov, DimProstora=4):

     koc = []
     for i in range(st_testov):
         try:
             rez = TravelingSalesmenProblem(MinPolozaj, MaxPolozaj, SteviloTock, DimProstora=4)

         except : pass
         e = rez[0]
         f = rez[1]
         g = rez[2]
         h = rez[3]
         j = rez[4]
         k = rez[5]
         koc.append([e,f,g,h,j,k])
     with open("out10dim4.csv", "w") as x:
         writer = csv.writer(x)
         writer.writerows(koc)
