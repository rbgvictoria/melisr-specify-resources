/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 01/03/2019
 */

DELIMITER $$

DROP PROCEDURE IF EXISTS change_storage $$
CREATE PROCEDURE change_storage()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE var_collectionobjectid INTEGER(11);
    DECLARE var_taxonid INTEGER(11);
    DECLARE var_nodenumber INTEGER(11);
    DECLARE var_highestchildnodenumber INTEGER(11);

    DECLARE cur_taxon CURSOR FOR
      SELECT TaxonID, NodeNumber, HighestChildNodeNumber 
      FROM taxon
      WHERE YesNo1=true;
    DECLARE cur_collectionobjectid CURSOR FOR
      SELECT co.CollectionObjectID
      FROM collectionobject co
      JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID
      JOIN taxon t ON d.TaxonID=t.TaxonID
      WHERE co.CollectionID=4 AND (d.IsCurrent=true or d.YesNo1=true) AND t.NodeNumber>=var_nodenumber AND t.HighestChildNodeNumber<=var_highestchildnodenumber;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;

    OPEN cur_taxon;
    cur_loop_taxon: LOOP
      FETCH cur_taxon INTO var_taxonid, var_nodenumber, var_highestchildnodenumber;
      IF done THEN
        LEAVE cur_loop_taxon;
      END IF;
      UPDATE taxon SET YesNo1=null WHERE TaxonID=var_taxonid;
      OPEN cur_collectionobjectid;
      cur_loop: LOOP
        FETCH cur_collectionobjectid INTO var_collectionobjectid;
        IF done THEN
          LEAVE cur_loop;
        END IF;
        CALL update_storage(var_collectionobjectid);
      END LOOP cur_loop;
    END LOOP cur_loop_taxon;
END $$

DELIMITER ;