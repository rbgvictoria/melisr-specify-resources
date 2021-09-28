/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 12/11/2020
 */
DROP function IF EXISTS `recorded_by_id`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `recorded_by_id`(in_collecting_event_id int) RETURNS varchar(256) CHARSET utf8
BEGIN
	DECLARE out_recorded_by_id varchar(256);
    SELECT GROUP_CONCAT(DISTINCT COALESCE(av1.Name, av2.Name) ORDER BY c.OrderNumber SEPARATOR ' | ')
    INTO out_recorded_by_id
    FROM collector c
    JOIN agent a ON c.AgentID=a.agentID
    LEFT JOIN agentvariant av1 ON a.AgentID=av1.AgentID AND av1.VarType=11
    LEFT JOIN agentvariant av2 ON a.AgentID=av2.AgentID AND av2.VarType=9
    WHERE c.CollectingEventID=in_collecting_event_id AND (av1.AgentVariantID IS NOT NULL OR av2.AgentVariantID IS NOT NULL)
    GROUP BY c.CollectingEventID;
RETURN out_recorded_by_id;
END$$

DELIMITER ;


