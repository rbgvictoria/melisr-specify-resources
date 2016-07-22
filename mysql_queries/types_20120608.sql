/*
(1) MEL types
(2) Received from other herbaria (Ex Herb.)
(3) Duplicates sent to other herbaria (Duplicate Prep. type)
 
                   (1)     (2)     (3)
All types
    total:       23381    3820     600
    Australia:   21445    3600     559
    foreign:      1936     220      41
 
Phanerogams
    total:       21086    3627     496
    Australia:   19380    3421     468
    foreign:      1706     206      28
 
Cryptogams
    total:        2295     193     104
    Australia:    2065     179      91
    foreign:       230      14      13
 
*/
 
-- Australian types
SELECT NodeNumber, HighestChildNodeNumber FROM geography WHERE Name='Australia'; -- 3367, 3383
SELECT co.CatalogNumber, count(*)
FROM collectionobject co
JOIN preparation p ON p.CollectionObjectID=co.CollectionObjectID
JOIN `storage` s ON p.StorageID=s.StorageID
JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID
JOIN collectingevent ce ON co.CollectingEventID=ce.CollectingEventID
JOIN locality l ON ce.LocalityID=l.LocalityID
JOIN geography g ON l.GeographyID=g.GeographyID
-- JOIN otheridentifier oi ON co.CollectionObjectID=oi.CollectionObjectID
WHERE d.YesNo1=1 AND (s.NodeNumber>3 AND s.NodeNumber<=466)
AND !(g.NodeNumber>=3367 AND g.NodeNumber<=3383)
-- AND p.PrepTypeID=15
GROUP BY co.CollectionObjectID;
 

-- Phanerogams
SELECT count(*)
FROM collectionobject co
JOIN preparation p ON p.CollectionObjectID=co.CollectionObjectID
JOIN `storage` s ON p.StorageID=s.StorageID
JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID
JOIN collectingevent ce ON co.CollectingEventID=ce.CollectingEventID
JOIN locality l ON ce.LocalityID=l.LocalityID
JOIN geography g ON l.GeographyID=g.GeographyID
-- JOIN otheridentifier oi ON co.CollectionObjectID=oi.CollectionObjectID
WHERE d.YesNo1=1
AND ((s.NodeNumber>=134 AND s.NodeNumber<=454) -- dicots
  OR (s.NodeNumber>=112 AND s.NodeNumber<=125) -- gymnosperms
  OR (s.NodeNumber>=46 AND s.NodeNumber<=110) -- monocots
  OR (s.NodeNumber>=8 AND s.NodeNumber<=45) -- ferns
  OR (s.NodeNumber>=4 AND s.NodeNumber<=7)) -- lycophytes
AND (g.NodeNumber>=3367 AND g.NodeNumber<=3383)
-- AND p.PrepTypeID=15
GROUP BY co.CollectionObjectID;
 

-- Cryptogams
SELECT count(*)
FROM collectionobject co
JOIN preparation p ON p.CollectionObjectID=co.CollectionObjectID
JOIN `storage` s ON p.StorageID=s.StorageID
JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID
JOIN collectingevent ce ON co.CollectingEventID=ce.CollectingEventID
JOIN locality l ON ce.LocalityID=l.LocalityID
JOIN geography g ON l.GeographyID=g.GeographyID
-- JOIN otheridentifier oi ON co.CollectionObjectID=oi.CollectionObjectID
WHERE d.YesNo1=1
AND ((s.NodeNumber>=458 AND s.NodeNumber<=466) -- algae
  OR (s.NodeNumber>=455 AND s.NodeNumber<=457) -- bryophytes
  OR (s.NodeNumber>=126 AND s.NodeNumber<=133) -- fungi
  OR (s.NodeNumber>=111 AND s.NodeNumber<=111)) -- lichens
AND !(g.NodeNumber>=3367 AND g.NodeNumber<=3383)
-- AND p.PrepTypeID=15
GROUP BY co.CollectionobjectID;