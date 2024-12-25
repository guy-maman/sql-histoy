
/*create table ActiveSubs(Operator String,Type String,MSISDN String)
ENGINE = MergeTree() order by Operator;*/

truncate table ActiveSubs

insert into ActiveSubs

select  'MTN' Operator,'Appear on Voice' Type,substring(callingPartyNumber, 3) MSISDN
from    ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and substring(callingPartyNumber, 1, 2) = '14'
    and type = 'M_S_ORIGINATING'
group by Operator,Type,MSISDN

insert into ActiveSubs

select  'MTN' Operator,'Appear on DATA' Type, substring(servedMSISDN, 6) MSISDN
from    mediation.data_ericsson
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
    and substring(servedMSISDN, 3, 4) in ('2318', '2315')
group by Operator,Type,MSISDN

insert into ActiveSubs

select  'ORANGE' Operator,'Appear on Voice' Type,substring(servedMSISDN,3) MSISDN
from    zte
where   toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and substring(servedMSISDN,3,5) = '23177'
        and type = 'MO_CALL_RECORD'
group by Operator,Type,MSISDN

insert into ActiveSubs

select  'ORANGE' Operator,'Appear on DATA' Type, substring(servedMSISDN, 3) MSISDN
from    data_zte
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
group by Operator,Type,MSISDN

--ActiveSubs

select  Operator,Type,Subs
from (
      select Operator, Type, count(distinct MSISDN) Subs
      from ActiveSubs
      group by Operator, Type
-- order by Operator,Type
      union all
      select Operator, 'Active (Marged)' Type, count(distinct MSISDN) Subs
      from ActiveSubs
      group by Operator, Type
         )
order by Operator,Type




/*
select  x,ORANGE,MTN
from
(
select  'Appear on Voice' x,COUNT(distinct substring(callingPartyNumber, 3)) MTN
from    ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and substring(callingPartyNumber, 1, 2) = '14'
    and type = 'M_S_ORIGINATING'
union all
select  'Appear on DATA' x,COUNT(distinct substring(servedMSISDN, 6)) MTN
from    mediation.data_ericsson
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
    and substring(servedMSISDN, 3, 4) in ('2318', '2315')
union all
select 'Active (Merged)' x,count(distinct y) MTN
from (
      select    distinct substring(callingPartyNumber, 3) y
      from      ericsson
      where     toYear(EventDate) = (:year)
            and toMonth(EventDate) = (:month)
            and substring(callingPartyNumber, 1, 2) = '14'
            and type = 'M_S_ORIGINATING'
      union all
      select    distinct substring(servedMSISDN, 6) y
      from      mediation.data_ericsson
      where     toYear(recordOpeningTime) = (:year)
            and toMonth(recordOpeningTime) = (:month)
            and substring(servedMSISDN, 3, 4) in ('2318', '2315')
         )
)any left join
(
select  'Appear on Voice' x,count(distinct substring(servedMSISDN,3)) ORANGE
from    zte
where   toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and substring(servedMSISDN,3,5) = '23177'
        and type = 'MO_CALL_RECORD'
union all
select  'Appear on DATA' x, count(distinct substring(servedMSISDN, 3)) ORANGE
from    data_zte
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
union all
select  'Active (Merged)' x, count(distinct y) ORANGE
from (
        select  substring(servedMSISDN, 3) y
        from    data_zte
        where   toYear(recordOpeningTime) = (:year)
            and toMonth(recordOpeningTime) = (:month)
        union all
        select  substring(servedMSISDN, 3) y
        from    zte
        where   toYear(eventTimeStamp) = (:year)
            and toMonth(eventTimeStamp) = (:month)
            and substring(servedMSISDN, 3, 5) = '23177'
            and type = 'MO_CALL_RECORD'
         )
)using x
order by x

 */