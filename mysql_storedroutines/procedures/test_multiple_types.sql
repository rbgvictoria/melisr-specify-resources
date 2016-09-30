DELIMITER $$

DROP PROCEDURE IF EXISTS test_multiple_types $$
CREATE PROCEDURE test_multiple_types ()
BEGIN
    SELECT co.CatalogNumber, count(*)
    FROM collectionobject co
    JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID
    WHERE d.YesNo1=1
    GROUP BY co.CollectionObjectID
    HAVING count(*)>1;
END $$

DELIMITER ;


