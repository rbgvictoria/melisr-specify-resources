/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 14/11/2020
 */
DROP FUNCTION IF EXISTS melisr.identified_by_id;

DELIMITER $$
$$
CREATE DEFINER=`admin`@`%` FUNCTION `melisr`.`identified_by_id`(in_determination_id int) RETURNS varchar(256) CHARSET utf8 COLLATE utf8_general_ci
BEGIN
	DECLARE out_identified_by_id varchar(256);
    DECLARE var_feature_or_basis varchar(32);
    SELECT GROUP_CONCAT(DISTINCT COALESCE(ai1.Identifier, ai2.Identifier) ORDER BY gp.OrderNumber SEPARATOR ' | '), d.FeatureOrBasis
    INTO out_identified_by_id, var_feature_or_basis
	FROM determination d
	JOIN agent a ON d.DeterminerID=a.AgentID
	LEFT JOIN groupperson gp ON a.AgentID=gp.GroupID
	LEFT JOIN agent m ON gp.MemberID=m.AgentID
	LEFT JOIN agentidentifier ai1 ON COALESCE(m.AgentID, a.AgentID)=ai1.AgentID AND ai1.IdentifierType=1
	LEFT JOIN agentidentifier ai2 ON COALESCE(m.AgentID, a.AgentID)=ai2.AgentID AND ai2.IdentifierType=2
	WHERE d.DeterminationID=in_determination_id AND (ai1.AgentIdentifierID IS NOT NULL OR ai2.AgentIdentifierID IS NOT NULL)
	GROUP BY d.DeterminationID, d.FeatureOrBasis;
    IF var_feature_or_basis='Acc. name change' OR var_feature_or_basis='AVH annot.' THEN
		SET out_identified_by_id=NULL;
	END IF;
RETURN out_identified_by_id;
END   $$
DELIMITER ;

