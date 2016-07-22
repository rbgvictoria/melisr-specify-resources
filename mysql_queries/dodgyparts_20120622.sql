SELECT AltCatalogNumber, count(*), MIN(Modifier), MAX(Modifier)
FROM collectionobject
GROUP BY AltCatalogNumber
HAVING MIN(Modifier)!='A' OR (count(*)=2 AND MAX(Modifier)!='B') OR (count(*)=3 AND MAX(Modifier)!='C')
  OR (count(*)=4 AND MAX(Modifier)!='D') OR (count(*)=5 AND MAX(Modifier)!='E')
  OR (count(*)=6 AND MAX(Modifier)!='F') OR (count(*)=7 AND MAX(Modifier)!='G')
  OR (count(*)=8 AND MAX(Modifier)!='H') OR (count(*)=9 AND MAX(Modifier)!='I')
  OR (count(*)=10 AND MAX(Modifier)!='J') OR (count(*)=11 AND MAX(Modifier)!='K')
  OR (count(*)=12 AND MAX(Modifier)!='L') OR count(*)>12;