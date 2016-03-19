DELIMITER $$

DROP PROCEDURE IF EXISTS vrs_collection $$
CREATE PROCEDURE vrs_collection (in_collectionobjectid INTEGER, in_agentid INTEGER)
BEGIN
    -- DECLARE _output TEXT DEFAULT '';
    DECLARE var_vrs_collectionid INTEGER;
    DECLARE var_vrs_catalognumber VARCHAR(10);
    DECLARE var_vrs_collectionobjectid INTEGER;
    DECLARE var_vrs_collectionobjectattributeid INTEGER;

    DECLARE chk_alreadyinvrs INTEGER DEFAULT NULL;

    -- collection object
    DECLARE var_colobj_catalognumber VARCHAR(10);
    DECLARE var_colobj_remarks TEXT;
    DECLARE var_colobj_text1 TEXT;
    DECLARE var_colobj_collectingeventid INTEGER;

    -- determination
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

    -- collection object attribute
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

    /* collection object data */
    SELECT CatalogNumber, Remarks, Text1, CollectingEventID
    INTO var_colobj_catalognumber, var_colobj_remarks, var_colobj_text1, 
      var_colobj_collectingeventid
    FROM collectionobject
    WHERE CollectionObjectID=in_collectionobjectid;

    /* determination data */
    SELECT Addendum, AlternateName, DeterminedDate, DeterminedDatePrecision,
      FeatureOrBasis, `Method`, NameUsage, Qualifier, Remarks, VarQualifier,
      DeterminerID, PreferredTaxonID, TaxonID
    INTO var_det_addendum, var_det_alternatename, var_det_determineddate, var_det_determineddateprecision,
      var_det_featureorbasis, var_det_method, var_det_nameusage, var_det_qualifier, var_det_remarks, var_det_varqualifier,
      var_det_determinerid, var_det_preferredtaxonid, var_det_taxonid
    FROM determination
    WHERE CollectionObjectID=in_collectionobjectid AND IsCurrent=1;

    /* collection object attribute data */
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


        /* check if already in VRS collection */
        SELECT CollectionObjectID
        INTO chk_alreadyinvrs
        FROM collectionobject
        WHERE CollectionID=var_vrs_collectionid AND CatalogNumber=var_vrs_catalognumber;
        -- SET _output = CONCAT(var_vrs_collectionid, ',', var_vrs_catalognumber, ',', chk_alreadyinvrs);

        IF chk_alreadyinvrs IS NOT NULL THEN
            LEAVE prep_loop;
        END IF;

        /* get new collectionobject id */
        SELECT MAX(CollectionObjectID)+1
        INTO var_vrs_collectionobjectid
        FROM collectionobject;
        -- SET _output=var_vrs_collectionobjectid;

        /* get new collection object attribute id */
        SELECT MAX(CollectionObjectAttributeID)+1
        INTO var_vrs_collectionobjectattributeid
        FROM collectionobjectattribute;

        /* insert VRS collection object attribute record */
        INSERT INTO collectionobjectattribute (CollectionObjectAttributeID, TimestampCreated, TimestampModified,
          Version, CollectionMemberID, Number1, Number2, Number3, Number4, Number5, Number6,
          CreatedByAgentID, ModifiedByAgentID)
        VALUES (var_vrs_collectionobjectattributeid, NOW(), NOW(), 0, var_vrs_collectionid,
          var_flowers, var_fruit, var_buds, var_leafless, var_fertile, var_sterile, in_agentid, in_agentid);

        /* insert VRS collection object record */
        INSERT INTO collectionobject (CollectionObjectID, TimestampCreated, TimestampModified, 
          Version, CollectionMemberID, CatalogNumber, Remarks, Text1, CollectingEventID, GUID,
          CollectionID, CollectionObjectAttributeID, ModifiedByAgentID, CreatedByAgentID)
        VALUES (var_vrs_collectionobjectid, NOW(), NOW(), 0, var_vrs_collectionid,
          var_vrs_catalognumber, var_colobj_remarks, var_colobj_text1, 
          var_colobj_collectingeventid, uuid(), var_vrs_collectionid, var_vrs_collectionobjectattributeid, in_agentid, in_agentid);

        /* insert VRS determination record */
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

        /* insert preparation record */
        INSERT INTO preparation (TimestampCreated, TimestampModified, Version, CollectionMemberID, 
          CountAmt, CreatedByAgentID, CollectionObjectID, PrepTypeID, ModifiedByAgentID)
        VALUES (NOW(), NOW(), 0, var_vrs_collectionid, 1, in_agentid, var_vrs_collectionobjectid, 25, in_agentid);

        /* insert other identifier record */
        INSERT INTO otheridentifier (TimestampCreated, TimestampModified, Version, CollectionMemberID, 
          Identifier, Institution, Remarks, CreatedByAgentID, CollectionObjectID, ModifiedByAgentID)
        VALUES (NOW(), NOW(), 0, var_vrs_collectionid, 'MEL', var_colobj_catalognumber, 'MEL catalog number',
          in_agentid, var_vrs_collectionobjectid, in_agentid);

    END LOOP;
    CLOSE csr_preparations;
    SET done=NULL;
    
    
    -- SELECT _output;

END $$

DELIMITER ;


