DELIMITER $$

DROP FUNCTION IF EXISTS collectorstring $$
CREATE FUNCTION collectorstring(p_collectingeventid int, p_primary bit) RETURNS varchar(128)
    READS SQL DATA
BEGIN
RETURN (
  SELECT GROUP_CONCAT(IF(!isnull(a.FirstName), CONCAT(a.LastName, ', ', a.FirstName), a.LastName) ORDER BY c.OrderNumber SEPARATOR '; ')
  FROM collector c
  JOIN agent a ON c.AgentID=a.AgentID
  WHERE c.CollectingEventID=p_collectingeventid AND c.IsPrimary=p_primary
  GROUP BY c.CollectingEventID
);

END $$

DELIMITER ;