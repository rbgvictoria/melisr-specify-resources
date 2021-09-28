use specify_development;

start transaction;

select a.AgentID, ad.TypeOfAddr, if(ad.TypeOfAddr='Yes', 1, 0)
from agent a
join address ad on a.AgentID=ad.AgentID
where ad.TypeOfAddr is not null;

update agent a
join address ad on a.AgentID=ad.AgentID
set a.Integer1=if(ad.TypeOfAddr='Yes', 1, 0), ad.TypeOfAddr=null
where ad.TypeOfAddr is not null;

commit;

start transaction;

select PositionHeld, count(*)
from address
group by PositionHeld;

select a.AgentID, ad.PositionHeld, case PositionHeld when 'None' then 0 when 'ABCD 2.06 (AVH)' then 1 when 'CSV' then 2 when 'CSV and ABCD 2.06 (AVH)' then 3 else null end
from agent a
join address ad on a.AgentID=ad.AgentID
where ad.PositionHeld is not null;

update agent a
join address ad on a.AgentID=ad.AgentID
set a.Integer2=case PositionHeld when 'None' then 0 when 'ABCD 2.06 (AVH)' then 1 when 'CSV' then 2 when 'CSV and ABCD 2.06 (AVH)' then 3 else null end,
  ad.PositionHeld=null
where ad.PositionHeld is not null;

commit;

start transaction;

update agent a
join address ad on a.AgentID=ad.AgentID
set ad.TypeOfAddr='postal'
where a.AgentType=0;

update agent a
join address ad on a.AgentID=ad.AgentID
set ad.TypeOfAddr='postal'
where a.AgentID in (select AgentID from addressofrecord);

commit;

start transaction;

select * from address where Address5 is not null;

insert into address (TimestampCreated, TimestampModified, Version, Address, TypeOfAddr, AgentID, CreatedByAgentID)
select now(), now(), 1, Address5, 'exchangePaperwork', AgentID, 1
from address
where Address5 is not null;

select * from address where Remarks is not null;

insert into address (TimestampCreated, TimestampModified, Version, Address, TypeOfAddr, AgentID, CreatedByAgentID)
select now(), now(), 1, Remarks, 'loanPaperwork', AgentID, 1
from address
where Remarks is not null;

commit;

start transaction;

update address
set Address5=null, Remarks=null
where Address5 is not null or Remarks is not null;

commit;
