/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 11/10/2020
 */

DROP procedure IF EXISTS `create_agent_action_extension`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` PROCEDURE `create_agent_action_extension`() 
BEGIN
    DROP TABLE IF EXISTS `mel_avh_agent_action_extension`;
    CREATE TABLE `mel_avh_agent_action_extension` (
      `CollectionObjectID` integer unsigned NOT NULL,
      `occurrenceID` varchar(128) DEFAULT NULL,
      `type` varchar(64) DEFAULT NULL,
      `identifier` varchar(255) DEFAULT NULL,
      `agentIdentifierType` varchar(32) DEFAULT NULL,
      `name` varchar(255) DEFAULT NULL,
      `familyName` varchar(255) DEFAULT NULL,
      `givenName` varchar(255) DEFAULT NULL,
      `action` varchar(32) DEFAULT NULL,
      `role` varchar(32) DEFAULT NULL,
      `displayOrder` bigint(12) DEFAULT NULL,
      `identificationID` varchar(128) DEFAULT NULL,
      `currentIdentification` bit(1) DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    -- collectors
    INSERT INTO `mel_avh_agent_action_extension` (`CollectionObjectID`, `occurrenceID`, `type`, `identifier`, `agentIdentifierType`, `name`, `familyName`, `givenName`, `action`, `role`, `displayOrder`, `identificationID`, `currentIdentification`)
    SELECT co.CollectionObjectID, co.GUID AS occurrenceID, 
      'http://schema.org/Person' as `type`, 
      group_concat(distinct coalesce(v3.Name, v1.name)) as identifier, 
      group_concat(distinct if(v3.AgentVariantID IS NOT NULL, 'ORCID', 'Wikidata')) as agentIdentifierType,
      group_concat(distinct v2.Name) as name,
      group_concat(distinct substring_index(v2.Name, ' ', -1)) as familyName,
      group_concat(distinct substring(v2.Name, 1, locate(substring_index(v2.Name, ' ', -1), v2.name)-1)) as givenName,
      'recorded' as `action`,
      if(c.OrderNumber=0, 'primary collector role', 'specimen collection role') as role,
      c.OrderNumber+1 as displayOrder,
      NULL as identificationID,
      NULL as currentIdentification
    FROM collectionobject co
    JOIN collectingevent ce ON co.CollectingEventID=ce.CollectingEventID
    JOIN collector c ON ce.CollectingEventID=c.CollectingEventID
    JOIN agent a ON c.AgentID=a.AgentID
    LEFT JOIN agentvariant v1 ON a.AgentID=v1.AgentID AND v1.VarType=9
    LEFT JOIN agentvariant v2 ON a.AgentID=v2.AgentID AND v2.VarType=10
    LEFT JOIN agentvariant v3 ON a.AgentID=v3.AgentID AND v3.VarType=11
    WHERE co.CollectionID=4 AND (v1.AgentVariantID IS NOT NULL OR v2.AgentVariantID IS NOT NULL OR v3.AgentVariantID IS NOT NULL)
    GROUP BY co.CollectionObjectID, a.AgentID;

    -- determiners
    INSERT INTO `mel_avh_agent_action_extension` (`CollectionObjectID`, `occurrenceID`, `type`, `identifier`, `agentIdentifierType`, `name`, `familyName`, `givenName`, `action`, `role`, `displayOrder`, `identificationID`, `currentIdentification`)
    SELECT co.CollectionObjectID, co.GUID AS occurrenceID, 
      'http://schema.org/Person' as `type`, 
      group_concat(distinct coalesce(v3.Name, v1.name)) as identifier, 
      group_concat(distinct if(v3.AgentVariantID IS NOT NULL, 'ORCID', 'Wikidata')) as agentIdentifierType,
      group_concat(distinct v2.Name) as name,
      group_concat(distinct substring_index(v2.Name, ' ', -1)) as familyName,
      group_concat(distinct substring(v2.Name, 1, locate(substring_index(v2.Name, ' ', -1), v2.name)-1)) as givenName,
      'identified' as `action`,
      null as role,
      1 as displayOrder,
      d.GUID as identificationID,
      d.isCurrent
    FROM collectionobject co
    JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID
    JOIN agent a ON d.DeterminerID=a.AgentID
    LEFT JOIN agentvariant v1 ON a.AgentID=v1.AgentID AND v1.VarType=9
    LEFT JOIN agentvariant v2 ON a.AgentID=v2.AgentID AND v2.VarType=10
    LEFT JOIN agentvariant v3 ON a.AgentID=v3.AgentID AND v3.VarType=11
    WHERE co.CollectionID=4 AND (v1.AgentVariantID IS NOT NULL OR v2.AgentVariantID IS NOT NULL OR v3.AgentVariantID IS NOT NULL)
      AND (d.FeatureOrBasis IS NULL OR d.FeatureOrBasis!='Type status')
    GROUP BY co.CollectionObjectID, d.DeterminationID, a.AgentID;

    -- determiners group members
    INSERT INTO `mel_avh_agent_action_extension` (`CollectionObjectID`, `occurrenceID`, `type`, `identifier`, `agentIdentifierType`, `name`, `familyName`, `givenName`, `action`, `role`, `displayOrder`, `identificationID`, `currentIdentification`)
    SELECT co.CollectionObjectID, co.GUID AS occurrenceID, 
      'http://schema.org/Person' as `type`, 
      group_concat(distinct coalesce(v3.Name, v1.name)) as identifier, 
      group_concat(distinct if(v3.AgentVariantID IS NOT NULL, 'ORCID', 'Wikidata')) as agentIdentifierType,
      group_concat(distinct v2.Name) as name,
      group_concat(distinct substring_index(v2.Name, ' ', -1)) as familyName,
      group_concat(distinct substring(v2.Name, 1, locate(substring_index(v2.Name, ' ', -1), v2.name)-1)) as givenName,
      'identified' as `action`,
      null as role,
      gp.OrderNumber+1 as displayOrder,
      d.GUID as identificationID,
      d.IsCurrent as currentIdentification
    FROM collectionobject co
    JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID
    JOIN agent a ON d.DeterminerID=a.AgentID
    JOIN groupperson gp ON a.AgentID=gp.GroupID
    JOIN agent gm ON gp.MemberID=gm.AgentID
    LEFT JOIN agentvariant v1 ON gm.AgentID=v1.AgentID AND v1.VarType=9
    LEFT JOIN agentvariant v2 ON gm.AgentID=v2.AgentID AND v2.VarType=10
    LEFT JOIN agentvariant v3 ON gm.AgentID=v3.AgentID AND v3.VarType=11
    WHERE co.CollectionID=4 AND (v1.AgentVariantID IS NOT NULL OR v2.AgentVariantID IS NOT NULL OR v3.AgentVariantID IS NOT NULL)
      AND (d.FeatureOrBasis IS NULL OR d.FeatureOrBasis!='Type status')
    GROUP BY co.CollectionObjectID, d.DeterminationID, gp.GroupPersonID, gm.AgentID;

    -- georeferencers
    INSERT INTO `mel_avh_agent_action_extension` (`CollectionObjectID`, `occurrenceID`, `type`, `identifier`, `agentIdentifierType`, `name`, `familyName`, `givenName`, `action`, `role`, `displayOrder`, `identificationID`, `currentIdentification`)
    SELECT co.CollectionObjectID, co.GUID AS occurrenceID, 
      'http://schema.org/Person' as `type`, 
      group_concat(distinct coalesce(v3.Name, v1.name)) as identifier, 
      group_concat(distinct if(v3.AgentVariantID IS NOT NULL, 'ORCID', 'Wikidata')) as agentIdentifierType,
      group_concat(distinct v2.Name) as name,
      group_concat(substring_index(v2.Name, ' ', -1)) as familyName,
      group_concat(substring(v2.Name, 1, locate(substring_index(v2.Name, ' ', -1), v2.name)-1)) as givenName,
      'georeferenced' as `action`,
      null as role,
      null as displayOrder,
      null,
      null
    FROM collectionobject co
    JOIN collectingevent ce ON co.CollectingEventID=ce.CollectingEventID
    JOIN locality l ON ce.LocalityID=l.LocalityID
    JOIN geocoorddetail gc ON l.LocalityID=gc.LocalityID
    JOIN agent a ON gc.AgentID=a.AgentID
    LEFT JOIN agentvariant v1 ON a.AgentID=v1.AgentID AND v1.VarType=9
    LEFT JOIN agentvariant v2 ON a.AgentID=v2.AgentID AND v2.VarType=10
    LEFT JOIN agentvariant v3 ON a.AgentID=v3.AgentID AND v3.VarType=11
    WHERE co.CollectionID=4 AND (v1.AgentVariantID IS NOT NULL OR v2.AgentVariantID IS NOT NULL OR v3.AgentVariantID IS NOT NULL)
    GROUP BY co.CollectionObjectID, a.AgentID;
    
    -- add some indexes
    ALTER TABLE `mel_avh_agent_action_extension` ADD INDEX mel_avh_agent_action_extension_CollectionObjectID_idx (CollectionObjectID);
    ALTER TABLE `mel_avh_agent_action_extension` ADD INDEX mel_avh_agent_action_extension_occurrenceID_idx (occurrenceID);
    ALTER TABLE `mel_avh_agent_action_extension` ADD INDEX mel_avh_agent_action_extension_action_idx (`action`);
    ALTER TABLE `mel_avh_agent_action_extension` ADD INDEX mel_avh_agent_action_extension_currentIdentification_idx (`currentIdentification`);
    
    
    -- table with recordedByID and identifiedByID to join to mel_avh_occurrence_core table in IPT
    DROP TABLE IF EXISTS mel_avh_occurrence_core_agent_id;
    CREATE TABLE mel_avh_occurrence_core_agent_id (
      CollectionObjectID integer unsigned not null,
      occurrenceID varchar(128),
      recordedByID text,
      identifiedByID text,
      PRIMARY KEY (CollectionObjectID)
    ) engine=innodb default charset=utf8;
    
    INSERT INTO mel_avh_occurrence_core_agent_id (CollectionObjectID, occurrenceID, recordedByID, identifiedByID)
	SELECT occ.CollectionObjectID, occ.occurrenceID, rec.recordedByID, ident.identifiedByID
	FROM (
            SELECT CollectionObjectID, occurrenceID
            FROM mel_avh_agent_action_extension
            WHERE `action` IN ('recorded', 'identified')
            GROUP BY CollectionObjectID, occurrenceID) AS occ
	LEFT JOIN (
            SELECT CollectionObjectID, group_concat(identifier SEPARATOR '|') as recordedByID
            FROM mel_avh_agent_action_extension
            WHERE `action`='recorded'
            GROUP BY CollectionObjectID) AS rec ON occ.CollectionObjectID=rec.CollectionObjectID
	LEFT JOIN (
            SELECT CollectionObjectID, group_concat(identifier SEPARATOR '|') as identifiedByID
            FROM mel_avh_agent_action_extension
            WHERE `action`='identified' AND `currentIdentification`=true
            GROUP BY CollectionObjectID) AS ident ON occ.CollectionObjectID=ident.CollectionObjectID;
        
	ALTER TABLE mel_avh_occurrence_core_agent_id ADD INDEX mel_avh_occurrence_core_agent_id_CollectionObjectID_idx (CollectionObjectID);
	ALTER TABLE mel_avh_occurrence_core_agent_id ADD INDEX mel_avh_occurrence_core_agent_id_occurrenceID_idx (occurrenceID);
    
END$$

DELIMITER ;



