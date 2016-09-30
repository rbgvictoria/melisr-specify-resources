DELIMITER $$

DROP PROCEDURE IF EXISTS test_multiple_primary_preparations $$
CREATE PROCEDURE test_multiple_primary_preparations ()
BEGIN
    SELECT co.CatalogNumber, count(*)
    FROM collectionobject co
    JOIN preparation p ON co.CollectionObjectID=p.CollectionObjectID
    WHERE p.PrepTypeID IN (1,2,3,4,8,10,12,13)
    GROUP BY co.CollectionObjectID
    HAVING count(*)>1;
END $$

DELIMITER ;


