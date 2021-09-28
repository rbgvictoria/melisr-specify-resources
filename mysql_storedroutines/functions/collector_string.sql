DROP function IF EXISTS `collectorstring`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `collectorstring`(p_collectingeventid int, p_separator varchar(4), p_primary bit) RETURNS varchar(256) CHARSET utf8
    READS SQL DATA
BEGIN
  DECLARE out_collector_string varchar(256);
  IF p_primary=true THEN
    SELECT REPLACE(GROUP_CONCAT(IF(!isnull(a.FirstName), CONCAT(a.LastName, ', ', a.FirstName), a.LastName) ORDER BY c.OrderNumber SEPARATOR 'placeholder-sep'), 'placeholder-sep', p_separator)
    INTO out_collector_string
    FROM collector c
    JOIN agent a ON c.AgentID=a.AgentID
    WHERE c.CollectingEventID=p_collectingeventid AND c.IsPrimary=p_primary
    GROUP BY c.CollectingEventID;
  ELSE
    SELECT REPLACE(GROUP_CONCAT(IF(!isnull(a.FirstName), CONCAT(a.LastName, ', ', a.FirstName), a.LastName) ORDER BY c.OrderNumber SEPARATOR 'placeholder-sep'), 'placeholder-sep', p_separator)
    INTO out_collector_string
    FROM collector c
    JOIN agent a ON c.AgentID=a.AgentID
    WHERE c.CollectingEventID=p_collectingeventid
    GROUP BY c.CollectingEventID;
  END IF;

  RETURN out_collector_string;
END$$

DELIMITER ;

