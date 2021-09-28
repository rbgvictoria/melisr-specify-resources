/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 14/11/2020
 */
DROP function IF EXISTS `identified_by_id`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `identified_by_id`(in_determination_id int) RETURNS varchar(256) CHARSET utf8
BEGIN
	DECLARE out_identified_by_id varchar(256);
    SELECT GROUP_CONCAT(DISTINCT COALESCE(av1.Name, av2.Name) ORDER BY gp.OrderNumber SEPARATOR ' | ')
    INTO out_identified_by_id
	FROM determination d
	JOIN agent a ON d.DeterminerID=a.AgentID
	LEFT JOIN groupperson gp ON a.AgentID=gp.GroupID
	LEFT JOIN agent m ON gp.MemberID=m.AgentID
	LEFT JOIN agentvariant av1 ON COALESCE(m.AgentID, a.AgentID)=av1.AgentID AND av1.VarType=11
	LEFT JOIN agentvariant av2 ON COALESCE(m.AgentID, a.AgentID)=av2.AgentID AND av2.VarType=9
	WHERE d.DeterminationID=in_determination_id AND (av1.AgentVariantID IS NOT NULL OR av2.AgentID IS NOT NULL)
	GROUP BY d.DeterminationID;
RETURN out_identified_by_id;
END$$

DELIMITER ;
