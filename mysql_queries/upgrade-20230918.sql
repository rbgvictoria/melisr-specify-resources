set @sheet = 164; -- MIXTA – sheet
set @packet = 165; -- MIXTA – packet
set @sonder_packet = 166; -- MIXTA – Sonder lichen packet

-- update MIXTA preptype for Sheets
update preparation 
set PrepTypeID = @sheet
where PreparationID in (
	select p.PreparationID 
	from collectionobject co
	join preparation p on co.CollectionObjectID = p.CollectionObjectID 
	join preptype pt on p.PrepTypeID = pt.PrepTypeID 
	where co.CollectionID = 4 and co.Modifier != 'A'
		and pt.Name in ('Sheet')
);
	
-- update MIXTA preptype for Packets
update preparation 
set PrepTypeID = @packet
where PreparationID in (
	select p.PreparationID 
	from collectionobject co
	join preparation p on co.CollectionObjectID = p.CollectionObjectID 
	join preptype pt on p.PrepTypeID = pt.PrepTypeID 
	where co.CollectionID = 4 and co.Modifier != 'A'
		and pt.Name in ('Packet')
);

-- update MIXTA preptype for Sonder lichen packets
update preparation 
set PrepTypeID = @sonder_packet
where PreparationID in (
	select p.PreparationID 
	from collectionobject co
	join preparation p on co.CollectionObjectID = p.CollectionObjectID 
	join preptype pt on p.PrepTypeID = pt.PrepTypeID 
	where co.CollectionID = 4 and co.Modifier != 'A'
		and pt.Name in ('Sonder lichen packet')
);

-- Change 'decimal' data types back to 'double'
ALTER TABLE locality MODIFY COLUMN MaxElevation double;
ALTER TABLE locality MODIFY COLUMN MinElevation double;
ALTER TABLE locality MODIFY COLUMN LatLongAccuracy double;
ALTER TABLE localitydetail MODIFY COLUMN StartDepth double;
ALTER TABLE localitydetail MODIFY COLUMN EndDepth double;
ALTER TABLE geocoorddetail MODIFY COLUMN GeoRefAccuracy double;


-- Move AgentVariant records to AgentIdentifier (Need to set picklist on identifierType column in schema config.)
insert into agentidentifier (TimestampCreated, TimestampModified, `Version`, Identifier, IdentifierType, CreatedByAgentID, AgentID, ModifiedByAgentID)
select TimestampCreated, TimestampCreated, `Version`, Name, 1, CreatedByAgentID, AgentID, ModifiedByAgentID
from agentvariant
where VarType = 11;

insert into agentidentifier (TimestampCreated, TimestampModified, `Version`, Identifier, IdentifierType, CreatedByAgentID, AgentID, ModifiedByAgentID)
select TimestampCreated, TimestampCreated, `Version`, Name, 2, CreatedByAgentID, AgentID, ModifiedByAgentID
from agentvariant
where VarType = 9;

insert into agentidentifier (TimestampCreated, TimestampModified, `Version`, Identifier, IdentifierType, CreatedByAgentID, AgentID, ModifiedByAgentID)
select TimestampCreated, TimestampCreated, `Version`, Name, 3, CreatedByAgentID, AgentID, ModifiedByAgentID
from agentvariant
where VarType = 6;

insert into agentidentifier (TimestampCreated, TimestampModified, `Version`, Identifier, IdentifierType, CreatedByAgentID, AgentID, ModifiedByAgentID)
select TimestampCreated, TimestampCreated, `Version`, Name, 4, CreatedByAgentID, AgentID, ModifiedByAgentID
from agentvariant
where VarType = 5;

insert into agentidentifier (TimestampCreated, TimestampModified, `Version`, Identifier, IdentifierType, CreatedByAgentID, AgentID, ModifiedByAgentID)
select TimestampCreated, TimestampCreated, `Version`, Name, 5, CreatedByAgentID, AgentID, ModifiedByAgentID
from agentvariant
where VarType = 13;

insert into agentidentifier (TimestampCreated, TimestampModified, `Version`, Identifier, IdentifierType, CreatedByAgentID, AgentID, ModifiedByAgentID)
select TimestampCreated, TimestampCreated, `Version`, Name, 6, CreatedByAgentID, AgentID, ModifiedByAgentID
from agentvariant
where VarType = 7;

insert into agentidentifier (TimestampCreated, TimestampModified, `Version`, Identifier, IdentifierType, CreatedByAgentID, AgentID, ModifiedByAgentID)
select TimestampCreated, TimestampCreated, `Version`, Name, 7, CreatedByAgentID, AgentID, ModifiedByAgentID
from agentvariant
where VarType = 8;

select * from agentidentifier;

-- delete from agentvariant where VarType in (7, 5, 6, 8, 11, 9, 13);



