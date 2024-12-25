

/*
create table Active_Subs(date datetime,Operator String,Activity String,subscount int)           --int,MSISDN String)
ENGINE = MergeTree() order by date;

*/

truncate table mediation.ActiveSubs

insert into mediation.ActiveSubs

select  date,Operator,sum(Type) Activity,MSISDN
from    (
select  toStartOfMonth(EventDate) date,'MTN' Operator,1 Type,substring(callingPartyNumber, 3) MSISDN
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and substring(callingPartyNumber, 1, 2) = '14'
    and type = 'M_S_ORIGINATING'
group by date,Operator,Type,MSISDN
union all
select  toStartOfMonth(recordOpeningTime) date,'MTN' Operator,2 Type, substring(servedMSISDN, 6) MSISDN
from    mediation.data_ericsson
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
    and substring(servedMSISDN, 3, 4) in ('2318', '2315')
group by date,Operator,Type,MSISDN
)group by date,Operator,MSISDN;

insert into mediation.ActiveSubs

select  date,Operator,sum(Type) Activity,MSISDN
from    (
select  toStartOfMonth(eventTimeStamp) date,'ORANGE' Operator,1 Type,substring(servedMSISDN,3) MSISDN
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and substring(servedMSISDN,3,5) = '23177'
        and type = 'MO_CALL_RECORD'
group by date,Operator,Type,MSISDN
union all
select  toStartOfMonth(recordOpeningTime) date,'ORANGE' Operator,2 Type, substring(servedMSISDN, 3) MSISDN
from    mediation.data_zte
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
group by date,Operator,Type,MSISDN
union all
select  toStartOfMonth(recordOpeningTime) date,'ORANGE' Operator,2 Type, substring(servedMSISDN, 3) MSISDN
from    mediation.zte_wtp
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
--     and servedMSISDN not like '91327%'
--     and servedMSISDN not like '00327%'
group by date,Operator,Type,MSISDN
)group by date,Operator,MSISDN;


--ActiveSubs

insert into default.Active_Subs

select  date,Operator,
        case when Activity = 1 then 'Voice'
            when Activity = 2 then 'DATA'
            else 'Voice&DATA' end as Activity,
        count() subscount
from    mediation.ActiveSubs
where   toYear(date) = (:year)
    and toMonth(date) = (:month)
group by Operator,date,Activity
order by Operator,date,Activity;


-- select * from default.Active_Subs
-- select * from mediation.ActiveSubs
 */
/*
-- select count(distinct MSISDN) count
select /*src,*/toStartOfDay(recordOpeningTime) recordOpeningTime,/*servedIMSI,*/substring(servedMSISDN,1,5) servedMSISDN
from mediation.zte_wtp
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
    and toDayOfMonth(recordOpeningTime) =(:day)
    and servedMSISDN not like '91327%'
    and servedMSISDN not like '00327%'
group by /*src,*/recordOpeningTime,/*servedIMSI,*/servedMSISDN
order by recordOpeningTime
limit 5000

/*
select  Operator,Type,Subs
from (
      select Operator, Activity, count(distinct MSISDN) Subs
      from mediation.ActiveSubs
        where   toYear(date) = (:year)
            and toMonth(date) = (:month)
      group by Operator, Activity
-- order by Operator,Type
      union all
      select Operator, 'Active (Marged)' Type, count(distinct MSISDN) Subs
      from mediation.ActiveSubs
        where   toYear(date) = (:year)
            and toMonth(date) = (:month)
      group by Operator, Type
         )
order by Operator,Type;

select  Operator,case when count(distinct Type)>1 then 'V&D' else Type end as Type


from    mediation.ActiveSubs
where   toYear(date) = (:year)
    and toMonth(date) = (:month)
group by Operator,Type

-- select * from mediation.ActiveSubs



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