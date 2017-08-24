/**
* classification procedure
*/
USE specify_development;

DELIMITER $$

DROP PROCEDURE IF EXISTS `classification` $$
CREATE DEFINER=`admin`@`%` PROCEDURE `classification`(p_taxonid INT)
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

/*
* collectorstring function
*/
DELIMITER $$

DROP FUNCTION IF EXISTS `collectorstring`$$
CREATE DEFINER=`admin`@`%` FUNCTION  `collectorstring`(p_collectingeventid int, p_primary bit) RETURNS varchar(128) CHARSET latin1
    READS SQL DATA
BEGIN
RETURN (
  SELECT GROUP_CONCAT(IF(!isnull(a.FirstName), CONCAT(a.LastName, ', ', a.FirstName), a.LastName) ORDER BY c.OrderNumber SEPARATOR '; ')
  FROM collector c
  JOIN agent a ON c.AgentID=a.AgentID
  WHERE c.CollectingEventID=p_collectingeventid AND c.IsPrimary=p_primary
  GROUP BY c.CollectingEventID
);

END;

 $$

DELIMITER ;


/*
* dwc_identification_qualifier function
*/
DELIMITER $$

DROP FUNCTION IF EXISTS `dwc_identification_qualifier`$$
CREATE DEFINER=`admin`@`%` FUNCTION  `dwc_identification_qualifier`(in_qualifier VARCHAR(8), in_rank VARCHAR(16), in_taxonID INT) RETURNS varchar(255) CHARSET utf8
BEGIN
    DECLARE var_name VARCHAR(255);
    DECLARE var_rank_id INT;

    DECLARE num INT;
    DECLARE ins INT;
    DECLARE spacer VARCHAR(1);

    SELECT t.RankID, t.FullName
    INTO var_rank_id, var_name
    FROM taxon t
    WHERE t.TaxonID=in_taxonID;

    IF in_qualifier IS NULL THEN
        RETURN NULL;
    ELSE
        
        CASE 
            WHEN var_rank_id < 220 THEN SET num = 1; 
            WHEN var_rank_id = 220 THEN SET num = 2; 
            WHEN var_rank_id > 220 THEN SET num = 3; 
        END CASE;

        
        CASE in_rank
            WHEN 'family' THEN SET ins = 1;     
            WHEN 'genus' THEN SET ins = 1;      
            WHEN 'species' THEN SET ins = 2;    
            WHEN 'subspecies' THEN SET ins = 3; 
            WHEN 'variety' THEN SET ins = 3;    
            WHEN 'forma' THEN SET ins = 3;      
            ELSE SET ins = num;
        END CASE;

        
        IF ins > num THEN 
            SET ins = num;
        END IF;

        IF in_qualifier='?' THEN
            SET spacer='';
        ELSE
            SET spacer=' ';
        END IF;

        
        CASE ins
            WHEN 1 THEN
                RETURN CONCAT(in_qualifier, spacer, CONCAT_WS(' ', split_string(var_name, ' ', 1), split_string(var_name, ' ', 2),
                    split_string(var_name, ' ', 3), split_string(var_name, ' ', 4)));
            WHEN 2 THEN
                RETURN CONCAT(in_qualifier, spacer, CONCAT_WS(' ', split_string(var_name, ' ', 2),
                    split_string(var_name, ' ', 3), split_string(var_name, ' ', 4)));
            WHEN 3 THEN
                RETURN CONCAT(in_qualifier, spacer, CONCAT_WS(' ', split_string(var_name, ' ', 3), split_string(var_name, ' ', 4)));
        END CASE;
        
    END IF;


END;

 $$

DELIMITER ;


/*
* dwc_type_status function
*/
DELIMITER $$

DROP FUNCTION IF EXISTS `dwc_type_status`$$
CREATE DEFINER=`admin`@`%` FUNCTION  `dwc_type_status`(colobjid INT) RETURNS varchar(1024) CHARSET utf8
BEGIN
    DECLARE var_typeOfType VARCHAR(32);
    DECLARE var_scientificName VARCHAR(128);
    DECLARE var_author VARCHAR(128);
    DECLARE var_protologue VARCHAR(255);
    DECLARE var_year INT;

    DECLARE str VARCHAR(1024);

    SELECT d.TypeStatusName, t.FullName, t.Author, t.CommonName, t.Number2
    INTO var_typeOfType, var_scientificName, var_author, var_protologue, var_year
    FROM determination d
    JOIN taxon t ON d.TaxonID=t.TaxonID
    WHERE d.CollectionObjectID=colobjid AND d.TypeStatusName IS NOT NULL AND d.YesNo1=1
        
        
        AND d.SubspQualifier IS NULL AND d.TypeStatusName!='Authentic specimen'
    LIMIT 1;

    IF var_typeOfType IS NULL THEN
        RETURN NULL;
    ELSE
        SET str = CONCAT_WS(' ', var_typeOfType, 'of', var_scientificName, var_author);
        IF var_protologue IS NOT NULL AND var_year IS NOT NULL THEN
            SET str = CONCAT(str, ', ', var_protologue, ' (', var_year, ')');
        END IF;
        RETURN str;
    END IF;

END;

 $$

DELIMITER ;

/*
* highergeography function
*/
DELIMITER $$

DROP FUNCTION IF EXISTS `highergeography`$$
CREATE DEFINER=`admin`@`%` FUNCTION  `highergeography`(p_geographyid int, p_rank varchar(64)) RETURNS varchar(128) CHARSET utf8
    READS SQL DATA
BEGIN

DECLARE var_rankid INTEGER(11);
DECLARE var_nodenumber INTEGER(11);
DECLARE var_highestdescendantnodenumber INTEGER(11);
DECLARE out_highergeography VARCHAR(128);

SELECT RankID
INTO var_rankid
FROM geographytreedefitem
WHERE Name=p_rank AND GeographyTreeDefID=1;

SELECT NodeNumber, HighestChildNodenumber
INTO var_nodenumber, var_highestdescendantnodenumber
FROM geography
WHERE GeographyID=p_geographyid;

SELECT Name
INTO out_highergeography
FROM geography
WHERE NodeNumber<=var_nodenumber AND HighestChildNodeNumber>=var_highestdescendantnodenumber AND RankID=var_rankid AND GeographyTreeDefID=1;

RETURN out_highergeography;

END;

 $$

DELIMITER ;


/*
* highertaxon function
*/
DELIMITER $$

DROP FUNCTION IF EXISTS `highertaxon`$$
CREATE DEFINER=`admin`@`%` FUNCTION  `highertaxon`(p_taxonid int, p_rank varchar(64)) RETURNS varchar(128) CHARSET latin1
    READS SQL DATA
BEGIN

DECLARE var_rankid INTEGER(11);
DECLARE var_nodenumber INTEGER(11);
DECLARE var_highestdescendantnodenumber INTEGER(11);
DECLARE out_highertaxon VARCHAR(128);

SELECT RankID
INTO var_rankid
FROM taxontreedefitem
WHERE Name=p_rank AND TaxonTreeDefID=1;

SELECT NodeNumber, HighestChildNodenumber
INTO var_nodenumber, var_highestdescendantnodenumber
FROM taxon
WHERE taxonid=p_taxonid;

IF (var_rankid<220) THEN
  SELECT Name
  INTO out_highertaxon
  FROM taxon
  WHERE NodeNumber<=var_nodenumber AND HighestChildNodeNumber>=var_highestdescendantnodenumber AND RankID=var_rankid AND TaxonTreeDefID=1;
ELSEIF (var_rankid=220) THEN
  SELECT FullName
  INTO out_highertaxon
  FROM taxon
  WHERE NodeNumber<=var_nodenumber AND HighestChildNodeNumber>=var_highestdescendantnodenumber AND RankID=var_rankid AND TaxonTreeDefID=1;
END IF;

RETURN out_highertaxon;

END;

 $$

DELIMITER ;


/*
* incoming function
*/
DELIMITER $$

DROP PROCEDURE IF EXISTS `incoming`$$
CREATE DEFINER=`admin`@`%` PROCEDURE  `incoming`()
BEGIN
    DECLARE var_collectionID INT;
    SET var_collectionID = 163840;
    SET @DISABLE_TRIGGER=1;

    START TRANSACTION;
    UPDATE collectionobject co
    LEFT JOIN collectionobjectattribute coa ON co.CollectionObjectAttributeID=coa.CollectionObjectAttributeID
    LEFT JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID
    LEFT JOIN preparation p ON co.CollectionObjectID=p.CollectionObjectID
    LEFT JOIN preptype pt1 ON p.PrepTypeID=pt1.PrepTypeID
    LEFT JOIN preptype pt2 ON pt1.Name=pt2.Name AND pt2.CollectionID=4
    LEFT JOIN otheridentifier oi ON co.CollectionObjectID=oi.CollectionObjectID
    SET co.AltCatalogNumber=IF(SUBSTRING(co.AltCatalogNumber, 1, 3)='MEL', CAST(SUBSTR(co.AltCatalogNumber, 5) AS UNSIGNED), CAST(SUBSTR(co.AltCatalogNumber, 1, 7) AS UNSIGNED)),
      co.Modifier=IF(SUBSTRING(co.AltCatalogNumber, 1, 3)='MEL', 'A', SUBSTR(co.AltCatalogNumber, 8)),
      co.`Name`=IF(SUBSTRING(co.AltCatalogNumber, 1, 3)='MEL', CONCAT('MEL ', CAST(SUBSTR(co.AltCatalogNumber, 5) AS UNSIGNED)), CONCAT('MEL ', CAST(SUBSTR(co.AltCatalogNumber, 1, 7) AS UNSIGNED))),
      co.CatalogNumber=IF(SUBSTRING(co.AltCatalogNumber, 1, 3)='MEL', CONCAT(SUBSTR(co.AltCatalogNumber, 5), 'A'), co.AltCatalogNumber),
      co.CollectionID=4,
      co.CollectionMemberID=4,
      coa.CollectionMemberID=4,
      d.CollectionMemberID=4,
      p.CollectionMemberID=4,
      p.PrepTypeID=pt2.PrepTypeID,
      oi.CollectionMemberID=4,
      co.TimestampCreated=NOW(),
      co.TimestampModified=NOW(),
      co.Version=1
    WHERE co.CollectionID=var_collectionID AND co.AltCatalogNumber IS NOT NULL;
    SET @DISABLE_TRIGGER=NULL;
    COMMIT;
END $$

DELIMITER ;


/*
* isType function
*/
DELIMITER $$

DROP FUNCTION IF EXISTS `isType`$$
CREATE DEFINER=`admin`@`%` FUNCTION  `isType`(p_collectionobjectid int) RETURNS tinyint(4)
BEGIN
    DECLARE out_isType INT;
    SELECT count(*)
    INTO out_isType
    FROM determination d
    WHERE d.YesNo1=1 AND d.TypeStatusName IS NOT NULL AND d.collectionObjectID=p_collectionobjectid;

    RETURN out_isType;
END;

 $$

DELIMITER ;


/*
* mellify function
*/
DELIMITER $$

DROP PROCEDURE IF EXISTS `mellify`$$
CREATE DEFINER=`admin`@`%` PROCEDURE  `mellify`()
BEGIN
    DECLARE var_collectionID INT;
    SET var_collectionID = 131072;
    SET @DISABLE_TRIGGER=1;

    START TRANSACTION;
    UPDATE collectionobject co
    LEFT JOIN collectionobjectattribute coa ON co.CollectionObjectAttributeID=coa.CollectionObjectAttributeID
    LEFT JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID
    LEFT JOIN preparation p ON co.CollectionObjectID=p.CollectionObjectID
    LEFT JOIN preptype pt1 ON p.PrepTypeID=pt1.PrepTypeID
    LEFT JOIN preptype pt2 ON pt1.Name=pt2.Name AND pt2.CollectionID=4
    LEFT JOIN otheridentifier oi ON co.CollectionObjectID=oi.CollectionObjectID
    SET co.AltCatalogNumber=IF(SUBSTRING(co.AltCatalogNumber, 1, 3)='MEL', CAST(SUBSTR(co.AltCatalogNumber, 5) AS UNSIGNED), CAST(SUBSTR(co.AltCatalogNumber, 1, 7) AS UNSIGNED)),
      co.Modifier=IF(SUBSTRING(co.AltCatalogNumber, 1, 3)='MEL', 'A', SUBSTR(co.AltCatalogNumber, 8)),
      co.`Name`=IF(SUBSTRING(co.AltCatalogNumber, 1, 3)='MEL', CONCAT('MEL ', CAST(SUBSTR(co.AltCatalogNumber, 5) AS UNSIGNED)), CONCAT('MEL ', CAST(SUBSTR(co.AltCatalogNumber, 1, 7) AS UNSIGNED))),
      co.CatalogNumber=IF(SUBSTRING(co.AltCatalogNumber, 1, 3)='MEL', CONCAT(SUBSTR(co.AltCatalogNumber, 5), 'A'), co.AltCatalogNumber),
      co.CollectionID=4,
      co.CollectionMemberID=4,
      coa.CollectionMemberID=4,
      d.CollectionMemberID=4,
      p.CollectionMemberID=4,
      p.PrepTypeID=pt2.PrepTypeID,
      oi.CollectionMemberID=4,
      co.TimestampCreated=NOW(),
      co.TimestampModified=NOW(),
      co.Version=1
    WHERE co.CollectionID=var_collectionID AND co.AltCatalogNumber IS NOT NULL;
    SET @DISABLE_TRIGGER=NULL;
    COMMIT;
END $$

DELIMITER ;


/*
* quantity_outstanding_nonmel function
*/
DELIMITER $$

DROP FUNCTION IF EXISTS `quantity_outstanding_nonmel`$$
CREATE DEFINER=`admin`@`%` FUNCTION  `quantity_outstanding_nonmel`(p_loanid int) RETURNS int(11)
    READS SQL DATA
BEGIN
RETURN (
    SELECT IF(s.ShipmentID IS NOT NULL, l.Number1-SUM(s.Number1), l.Number1)
    FROM loan l
    LEFT JOIN shipment s ON l.LoanID=s.LoanID
    WHERE l.DisciplineID=32768 AND l.LoanID=p_loanid
    GROUP BY l.LoanID
);

END;

 $$

DELIMITER ;


/*
* scientificname function
*/
DELIMITER $$

DROP FUNCTION IF EXISTS `scientificname`$$
CREATE DEFINER=`admin`@`%` FUNCTION  `scientificname`(p_taxonid int, p_rankid int) RETURNS varchar(255) CHARSET latin1
    READS SQL DATA
BEGIN

DECLARE out_sciname VARCHAR(255);
DECLARE var_speciesname VARCHAR(128);
DECLARE var_familyname VARCHAR(64);
DECLARE var_genusname VARCHAR(64);

IF p_rankid>=220 THEN
  SELECT highertaxon(p_taxonid, 'Species')
  INTO var_speciesname;
END IF;

CASE
  WHEN p_rankid<=140 OR p_rankid=180 THEN
    SELECT IF(!isnull(Author), CONCAT(Name, ' ', Author), Name)
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=150 THEN
    SELECT highertaxon(p_taxonid, 'Family') INTO var_familyname;
    SELECT IF(!isnull(Author),
      IF(Name=var_familyname,
        CONCAT_WS(' ', var_familyname, Author, 'subfam.', Name),
        CONCAT_WS(' ', var_familyname, 'subfam.', Name, Author)
      ), CONCAT_WS(' ', var_familyname, 'subfam.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=160 THEN
    SELECT highertaxon(p_taxonid, 'Family') INTO var_familyname;
    SELECT IF(!isnull(Author),
      IF(Name=var_familyname,
        CONCAT_WS(' ', var_familyname, Author, 'tr.', Name),
        CONCAT_WS(' ', var_familyname, 'tr.', Name, Author)
      ), CONCAT_WS(' ', var_familyname, 'tr.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=190 THEN
    SELECT highertaxon(p_taxonid, 'Genus') INTO var_genusname;
    SELECT IF(!isnull(Author),
      IF(Name=var_genusname,
        CONCAT_WS(' ', var_genusname, Author, 'subgen.', Name),
        CONCAT_WS(' ', var_genusname, 'subgen.', Name, Author)
      ), CONCAT_WS(' ', var_genusname, 'subgen.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=200 THEN
    SELECT highertaxon(p_taxonid, 'Genus') INTO var_genusname;
    SELECT IF(!isnull(Author),
      IF(Name=var_genusname,
        CONCAT_WS(' ', var_genusname, Author, 'sect.', Name),
        CONCAT_WS(' ', var_genusname, 'sect.', Name, Author)
      ), CONCAT_WS(' ', var_genusname, 'sect.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=220 THEN
    SELECT IF(!isnull(Author), CONCAT(FullName, ' ', Author), FullName)
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=230 THEN
    SELECT IF(!isnull(Author),
      IF(Name=SUBSTRING(var_speciesname, LOCATE(' ', var_speciesname)+1),
        CONCAT_WS(' ', var_speciesname, Author, 'subsp.', Name),
        CONCAT_WS(' ', var_speciesname, 'subsp.', Name, Author)
      ), CONCAT_WS(' ', var_speciesname, 'subsp.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=240 THEN
    SELECT IF(!isnull(Author),
      IF(Name=SUBSTRING(var_speciesname, LOCATE(' ', var_speciesname)+1),
        CONCAT_WS(' ', var_speciesname, Author, 'var.', Name),
        CONCAT_WS(' ', var_speciesname, 'var.', Name, Author)
      ), CONCAT_WS(' ', var_speciesname, 'var.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=250 THEN
    SELECT IF(!isnull(Author),
      IF(Name=SUBSTRING(var_speciesname, LOCATE(' ', var_speciesname)+1),
        CONCAT_WS(' ', var_speciesname, Author, 'subvar.', Name),
        CONCAT_WS(' ', var_speciesname, 'subvar.', Name, Author)
      ), CONCAT_WS(' ', var_speciesname, 'subvar.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=260 THEN
    SELECT IF(!isnull(Author),
      IF(Name=SUBSTRING(var_speciesname, LOCATE(' ', var_speciesname)+1),
        CONCAT_WS(' ', var_speciesname, Author, 'f.', Name),
        CONCAT_WS(' ', var_speciesname, 'f.', Name, Author)
      ), CONCAT_WS(' ', var_speciesname, 'f.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=270 THEN
    SELECT IF(!isnull(Author),
      IF(Name=SUBSTRING(var_speciesname, LOCATE(' ', var_speciesname)+1),
        CONCAT_WS(' ', var_speciesname, Author, 'subf.', Name),
        CONCAT_WS(' ', var_speciesname, 'subf.', Name, Author)
      ), CONCAT_WS(' ', var_speciesname, 'subf.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
END CASE;

RETURN out_sciname;

END;

 $$

DELIMITER ;


/*
*
*/
DELIMITER $$

DROP FUNCTION IF EXISTS `split_string`$$
CREATE DEFINER=`admin`@`%` FUNCTION  `split_string`(str VARCHAR(1024) , del VARCHAR(1) , i INT) RETURNS varchar(1024) CHARSET utf8
BEGIN
    DECLARE n INT ;
    SET n = LENGTH(str) - LENGTH(REPLACE(str, del, '')) + 1;
    IF i > n THEN
        RETURN NULL;
    ELSE
        RETURN SUBSTRING_INDEX(SUBSTRING_INDEX(str, del, i) , del , -1 );
    END IF;
END;

 $$

DELIMITER ;


/*
* update_dwc_identification_qualifier procedure
*/
DELIMITER $$

DROP PROCEDURE IF EXISTS `update_dwc_identification_qualifier`$$
CREATE DEFINER=`admin`@`%` PROCEDURE  `update_dwc_identification_qualifier`()
BEGIN
    UPDATE determination
    SET Text1=dwc_identification_qualifier(Qualifier, VarQualifier, TaxonID)
    WHERE Qualifier IS NOT NULL AND TaxonID IS NOT NULL;
END $$

DELIMITER ;


/*
* update_dwc_type_status procedure
*/
DELIMITER $$

DROP PROCEDURE IF EXISTS `update_dwc_type_status`$$
CREATE DEFINER=`admin`@`%` PROCEDURE  `update_dwc_type_status`()
BEGIN
    UPDATE collectionobject
    SET Description=dwc_type_status(CollectionObjectID)
    WHERE CollectionObjectID IN (
        SELECT CollectionObjectID
        FROM determination
        WHERE TypeStatusName IS NOT NULL
            AND YesNo1=1 AND SubspQualifier IS NULL AND TypeStatusName!='Authentic specimen'
    );
END $$

DELIMITER ;


/*
* update_storage procedure
*/
DELIMITER $$

DROP PROCEDURE IF EXISTS `update_storage`$$
CREATE DEFINER=`admin`@`%` PROCEDURE  `update_storage`(in_collectionobjectid INTEGER(11))
BEGIN

	DECLARE var_taxonid INTEGER(11);
	DECLARE var_type BIT(1);
	DECLARE var_rankid INTEGER(11);
	DECLARE var_nodenumber INTEGER(11);
	DECLARE var_storageid INTEGER(11);

	SELECT TaxonID
	INTO var_taxonid
	FROM determination
	WHERE YesNo1=1 AND CollectionObjectID=in_collectionobjectid
	LIMIT 1;

	IF var_taxonid THEN
		SET var_type = 1;
	ELSE
		SET var_type = 0;
		SELECT TaxonID
		INTO var_taxonID
		FROM determination
		WHERE IsCurrent=1 AND CollectionObjectID=in_collectionobjectid
    LIMIT 1;

	END IF;

	

	SELECT RankID, NodeNumber
	INTO var_rankid, var_nodenumber
	FROM taxon
	WHERE TaxonID=var_taxonid;

	If var_rankid > 180 THEN
		SELECT TaxonID
		INTO var_taxonid
		FROM taxon
		WHERE NodeNumber<var_nodenumber AND HighestChildNodeNumber>=var_nodenumber
			AND RankID=180
    LIMIT 1;
	END IF;

	IF var_type=1 THEN
		SELECT StorageIDTypes
		INTO var_storageid
		FROM genusstorage
		WHERE TaxonID=var_taxonid
    LIMIT 1;
	ELSE
		SELECT StorageID
		INTO var_storageid
		FROM genusstorage
		WHERE TaxonID=var_taxonid
    LIMIT 1;
	END IF;

	UPDATE preparation
  SET StorageID=var_storageid, TimestampModified=NOW()
  WHERE CollectionObjectID=in_collectionobjectid;

END $$

DELIMITER ;


/*
* vrs_collection procedure
*/
DELIMITER $$

DROP PROCEDURE IF EXISTS `vrs_collection`$$
CREATE DEFINER=`admin`@`%` PROCEDURE  `vrs_collection`(in_collectionobjectid INTEGER, in_agentid INTEGER)
BEGIN
    DECLARE _output TEXT DEFAULT '';
    DECLARE var_vrs_collectionid INTEGER;
    DECLARE var_vrs_catalognumber VARCHAR(10);
    DECLARE var_vrs_collectionobjectid INTEGER;
    DECLARE var_vrs_collectionobjectattributeid INTEGER;

    DECLARE chk_alreadyinvrs INTEGER DEFAULT NULL;

    
    DECLARE var_colobj_catalognumber VARCHAR(10);
    DECLARE var_colobj_remarks TEXT;
    DECLARE var_colobj_text1 TEXT;
    DECLARE var_colobj_collectingeventid INTEGER;

    
    DECLARE var_det_addendum VARCHAR(16);
    DECLARE var_det_alternatename VARCHAR(128);
    DECLARE var_det_determineddate DATE;
    DECLARE var_det_determineddateprecision INTEGER(4);
    DECLARE var_det_featureorbasis VARCHAR(50);
    DECLARE var_det_method VARCHAR(50);
    DECLARE var_det_nameusage VARCHAR(64);
    DECLARE var_det_qualifier VARCHAR(16);
    DECLARE var_det_remarks TEXT;
    DECLARE var_det_varqualifier VARCHAR(16);
    DECLARE var_det_determinerid INTEGER;
    DECLARE var_det_preferredtaxonid INTEGER;
    DECLARE var_det_taxonid INTEGER;

    
    DECLARE var_flowers FLOAT(20,10);
    DECLARE var_fruit FLOAT(20,10);
    DECLARE var_buds FLOAT(20,10);
    DECLARE var_leafless FLOAT(20,10);
    DECLARE var_fertile FLOAT(20,10);
    DECLARE var_sterile FLOAT(20,10);
    
    DECLARE done INTEGER;
    DECLARE csr_preparations CURSOR FOR
        SELECT SampleNumber
        FROM preparation
        WHERE PrepTypeID=18 AND CollectionObjectID=in_collectionobjectid;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;


    SET var_vrs_collectionid=65536;

    
    SELECT CatalogNumber, Remarks, Text1, CollectingEventID
    INTO var_colobj_catalognumber, var_colobj_remarks, var_colobj_text1, 
      var_colobj_collectingeventid
    FROM collectionobject
    WHERE CollectionObjectID=in_collectionobjectid;

    
    SELECT Addendum, AlternateName, DeterminedDate, DeterminedDatePrecision,
      FeatureOrBasis, `Method`, NameUsage, Qualifier, Remarks, VarQualifier,
      DeterminerID, PreferredTaxonID, TaxonID
    INTO var_det_addendum, var_det_alternatename, var_det_determineddate, var_det_determineddateprecision,
      var_det_featureorbasis, var_det_method, var_det_nameusage, var_det_qualifier, var_det_remarks, var_det_varqualifier,
      var_det_determinerid, var_det_preferredtaxonid, var_det_taxonid
    FROM determination
    WHERE CollectionObjectID=in_collectionobjectid AND IsCurrent=1;

    
    SELECT coa.Number1, coa.Number2, coa.Number3, coa.Number4, coa.Number5, coa.Number6
    INTO var_flowers, var_fruit, var_buds, var_leafless, var_fertile, var_sterile
    FROM collectionobject co
    JOIN collectionobjectattribute coa ON co.CollectionObjectAttributeID=coa.CollectionObjectAttributeID
    WHERE co.CollectionobjectID=in_collectionobjectid;

    OPEN csr_preparations;
    prep_loop: LOOP
        FETCH csr_preparations
        INTO var_vrs_catalognumber;

        IF done=1 THEN
            LEAVE prep_loop;
        END IF;


        
        SELECT CollectionObjectID
        INTO chk_alreadyinvrs
        FROM collectionobject
        WHERE CollectionID=var_vrs_collectionid AND CatalogNumber=var_vrs_catalognumber;
        

        IF chk_alreadyinvrs IS NOT NULL THEN
            LEAVE prep_loop;
        END IF;

        START TRANSACTION;

        
        SELECT MAX(CollectionObjectID)+1
        INTO var_vrs_collectionobjectid
        FROM collectionobject;
        

        
        SELECT MAX(CollectionObjectAttributeID)+1
        INTO var_vrs_collectionobjectattributeid
        FROM collectionobjectattribute;

        
        INSERT INTO collectionobjectattribute (CollectionObjectAttributeID, TimestampCreated, TimestampModified,
          Version, CollectionMemberID, Number1, Number2, Number3, Number4, Number5, Number6,
          CreatedByAgentID, ModifiedByAgentID)
        VALUES (var_vrs_collectionobjectattributeid, NOW(), NOW(), 0, var_vrs_collectionid,
          var_flowers, var_fruit, var_buds, var_leafless, var_fertile, var_sterile, in_agentid, in_agentid);

        
        INSERT INTO collectionobject (CollectionObjectID, TimestampCreated, TimestampModified, 
          Version, CollectionMemberID, CatalogNumber, Remarks, Text1, CollectingEventID, GUID,
          CollectionID, CollectionObjectAttributeID, ModifiedByAgentID, CreatedByAgentID)
        VALUES (var_vrs_collectionobjectid, NOW(), NOW(), 0, var_vrs_collectionid,
          var_vrs_catalognumber, var_colobj_remarks, var_colobj_text1, 
          var_colobj_collectingeventid, uuid(), var_vrs_collectionid, var_vrs_collectionobjectattributeid, in_agentid, in_agentid);

        
        INSERT INTO determination (TimestampCreated, Version, CollectionMemberID,
          Addendum, AlternateName, DeterminedDate, DeterminedDatePrecision,
          FeatureOrBasis, `Method`, NameUsage, Qualifier, Remarks, VarQualifier,
          DeterminerID, PreferredTaxonID, TaxonID,
          GUID, CollectionObjectID, ModifiedByAgentID, CreatedByAgentID, IsCurrent)
        VALUES (NOW(), 0, var_vrs_collectionid, var_det_addendum, var_det_alternatename, 
          var_det_determineddate, var_det_determineddateprecision,
          var_det_featureorbasis, var_det_method, var_det_nameusage, var_det_qualifier, var_det_remarks, var_det_varqualifier,
          var_det_determinerid, var_det_preferredtaxonid, var_det_taxonid,
          uuid(), var_vrs_collectionobjectid, in_agentid, in_agentid, 1);

        
        INSERT INTO preparation (TimestampCreated, TimestampModified, Version, CollectionMemberID, 
          CountAmt, CreatedByAgentID, CollectionObjectID, PrepTypeID, ModifiedByAgentID)
        VALUES (NOW(), NOW(), 0, var_vrs_collectionid, 1, in_agentid, var_vrs_collectionobjectid, 25, in_agentid);

        
        INSERT INTO otheridentifier (TimestampCreated, TimestampModified, Version, CollectionMemberID, 
          Identifier, Institution, Remarks, CreatedByAgentID, CollectionObjectID, ModifiedByAgentID)
        VALUES (NOW(), NOW(), 0, var_vrs_collectionid, 'MEL', var_colobj_catalognumber, 'MEL catalog number',
          in_agentid, var_vrs_collectionobjectid, in_agentid);

        COMMIT;

    END LOOP;
    CLOSE csr_preparations;
    SET done=NULL;
END $$

DELIMITER ;
