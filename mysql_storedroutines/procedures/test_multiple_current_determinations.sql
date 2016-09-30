DELIMITER $$

DROP PROCEDURE IF EXISTS test_multiple_current_determinations $$
CREATE PROCEDURE test_multiple_current_determinations ()
BEGIN
    SELECT co.CatalogNumber, count(*)
    FROM collectionobject co
    JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID
    WHERE d.IsCurrent=1
    GROUP BY co.CollectionObjectID
    HAVING count(*)>1;
END $$

DELIMITER ;


