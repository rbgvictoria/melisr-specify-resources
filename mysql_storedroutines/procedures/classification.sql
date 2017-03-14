/*******************************************************************************

classification procedure

Creates record with higher taxa for taxon

*******************************************************************************/
DELIMITER $$

DROP PROCEDURE IF EXISTS classification $$
CREATE PROCEDURE classification (p_taxonid INT)
BEGIN
  DECLARE v_nodenumber INT;

  DECLARE v_rank VARCHAR(32);
  DECLARE v_name VARCHAR(64);

  DECLARE v_kingdom VARCHAR(64) DEFAULT NULL;
  DECLARE v_phylum VARCHAR(64) DEFAULT NULL;
  DECLARE v_class VARCHAR(64) DEFAULT NULL;
  DECLARE v_order VARCHAR(64) DEFAULT NULL;
  DECLARE v_family VARCHAR(64) DEFAULT NULL;

  DECLARE v_done INT DEFAULT 0;
  DECLARE v_exists INT;

  DECLARE c_classification CURSOR FOR
    SELECT td.Name AS Rank, t.Name
    FROM taxon t
    JOIN taxontreedefitem td ON t.TaxonTreeDefItemID=td.TaxonTreeDefItemID
    WHERE t.NodeNumber<=v_nodenumber AND t.HighestChildNodeNumber>=v_nodenumber
      AND t.RankID IN (10, 30, 60, 100, 140)
    ORDER BY t.RankID;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done=1;

  SELECT NodeNumber
  INTO v_nodenumber
  FROM taxon
  WHERE TaxonID=p_taxonid;

  OPEN c_classification;
  classification_cursor: LOOP

    FETCH c_classification INTO v_rank, v_name;
    CASE v_rank
      WHEN 'kingdom' THEN SET v_kingdom = v_name;
      WHEN 'division' THEN SET v_phylum = v_name;
      WHEN 'class' THEN SET v_class = v_name;
      WHEN 'order' THEN SET v_order = v_name;
      WHEN 'family' THEN SET v_family = v_name;
    END CASE;

    SELECT count(*)
    INTO v_exists
    FROM aux_highertaxonomy
    WHERE TaxonID=p_taxonid;

    IF v_exists > 0 THEN
      UPDATE aux_highertaxonomy
      SET TimestampModified=NOW(), kingdom=v_kingdom, division=v_phylum, class=v_class, `order`=v_order, family=v_family
      WHERE TaxonID=p_taxonid;

    ELSE
      INSERT INTO aux_highertaxonomy(TaxonID, TimestampModified, kingdom, division, class, `order`, family)
      VALUES (p_taxonid, NOW(), v_kingdom, v_phylum, v_class, v_order, v_family);
    END IF;

    IF v_done=1 THEN
      LEAVE classification_cursor;
    END IF;

  END LOOP classification_cursor;
  CLOSE c_classification;


END $$

DELIMITER ;
