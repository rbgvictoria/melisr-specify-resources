UPDATE address
SET Phone2=TypeOfAddr, TypeOfAddr=NULL;

INSERT INTO address (TimestampCreated, TimestampModified, Version, Address, TypeOfAddr, AgentID, CreatedByAgentID)
SELECT NOW(), NOW(), 1, Address5, 'Exchange paperwork', AgentID, 1
FROM address
WHERE Address5 IS NOT NULL;

UPDATE address SET Address5=NULL;
UPDATE address SET Address5=Address4, Address4=RoomOrBuilding, RoomOrBuilding=NULL;

INSERT INTO address (TimestampCreated, TimestampModified, Version, Address, TypeOfAddr, AgentID, CreatedByAgentID)
SELECT NOW(), NOW(), 1, Remarks, 'Loan paperwork', AgentID, 1
FROM address
WHERE Remarks IS NOT NULL;

UPDATE address SET Remarks=NULL;
