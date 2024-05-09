/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 12/11/2020
 */
DROP FUNCTION IF EXISTS melisr.recorded_by_id;

DELIMITER $$
$$
CREATE DEFINER=`admin`@`%` FUNCTION `melisr`.`recorded_by_id`(in_collecting_event_id int) RETURNS varchar(256) CHARSET utf8 COLLATE utf8_general_ci
BEGIN
	DECLARE out_recorded_by_id varchar(256);
	select group_concat(distinct coalesce(ai1.Identifier, ai2.Identifier) order by c.OrderNumber separator ' | ')
	into out_recorded_by_id
	from collector c
	join agent a on c.AgentID=a.AgentID 
	left join agentidentifier ai1 on a.AgentID=ai1.AgentID and ai1.IdentifierType = 1
	left join agentidentifier ai2 on a.AgentID = ai2.AgentID and ai2.IdentifierType = 2
	where c.CollectingEventID=in_collecting_event_id and (ai1.AgentIdentifierID is not null or ai2.AgentIdentifierID is not null)
	group by c.CollectingEventID ;
	RETURN out_recorded_by_id;
END  $$
DELIMITER ;


