
-- check traffic
select op,ty,duration
from
(
select  o.value op,toString(t.operatorId) id,t.value ty,--sum(h.duration)/60
        if(t.operatorId = 2,toFloat64(sum(h.duration)),round(sum(h.duration)/60)) duration
from    mediation.hourly_traffic h
    join mediation.operators o on h.operator = o.operatorId
    join mediation.traffic_types t on h.trafficType = t.operatorId
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and t.operatorId not in (3,4)
group by o.value, t.value,o.operatorId,t.operatorId
union all
select   Operator op, Direction id,t.value ty,round(sum(callDuration)/60) duration
from    default.Pre_INTL i
    join mediation.traffic_types t on i.Direction = toString(t.operatorId)
where   toYYYYMM(Date) = (:yyyymm)
GROUP BY Operator, Direction,t.value
    )
order by op desc,id
;

-- Active Subs
truncate table default.subsList;

insert into default.subsList

select  date,Operator,sum(Type) Activity,MSISDN
from    (
select  toStartOfMonth(EventDate) date,'MTN' Operator,1 Type,substring(callingPartyNumber, 3) MSISDN
from    mediation.ericsson
where   toYYYYMM(EventDate) = (:yyyymm)
    and substring(callingPartyNumber, 1, 2) = '14'
    and type = 'M_S_ORIGINATING'
group by date,Operator,Type,MSISDN
union all
select  toStartOfMonth(recordOpeningTime) date,'MTN' Operator,2 Type, substring(servedMSISDN, 6) MSISDN
from    mediation.data_ericsson
where   toYYYYMM(recordOpeningTime) = (:yyyymm)
    and substring(servedMSISDN, 3, 4) in ('2318', '2315')
group by date,Operator,Type,MSISDN
)group by date,Operator,MSISDN;

insert into default.subsList

select  date,Operator,sum(Type) Activity,MSISDN
from    (
select  toStartOfMonth(eventTimeStamp) date,'ORANGE' Operator,1 Type,substring(servedMSISDN,3) MSISDN
from    mediation.zte
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
        and substring(servedMSISDN,3,5) = '23177'
        and type = 'MO_CALL_RECORD'
group by date,Operator,Type,MSISDN
union all
select  toStartOfMonth(recordOpeningTime) date,'ORANGE' Operator,2 Type, substring(servedMSISDN, 3) MSISDN
from    mediation.data_zte
where   toYYYYMM(recordOpeningTime) = (:yyyymm)
group by date,Operator,Type,MSISDN
union all
select  toStartOfMonth(recordOpeningTime) date,'ORANGE' Operator,2 Type, substring(servedMSISDN, 3) MSISDN
from    mediation.zte_wtp
where   toYYYYMM(recordOpeningTime) = (:yyyymm)
group by date,Operator,Type,MSISDN
)group by date,Operator,MSISDN;

insert into default.Active_Subs

select  date,Operator,
        case when subsList.Activity = 1 then 'Voice'
            when subsList.Activity  = 2 then 'DATA'
            else 'Voice&DATA' end as Activity,
        count() subscount
from    default.subsList
where   toYYYYMM(date) = (:yyyymm)
group by Operator,date,Activity
order by Operator,date,Activity;

-- Active Subs
select  Activity,ORANGE,MTN
from
(
select 1 ind, 'Active Subs' Activity, sum(subscount) ORANGE
 from default.Active_Subs
 where toYYYYMM(date) = (:yyyymm)
   and Operator = 'ORANGE'
 group by Operator
 union all
 select case
            when Activity = 'Voice&DATA' then 2
            when Activity = 'DATA' then 3
            when Activity = 'Voice' then 4
            end   ind,
        Activity,
        subscount ORANGE
 from default.Active_Subs
 where toYYYYMM(date) = (:yyyymm)
   and Operator = 'ORANGE'
 order by ind
) a
join
(
select  1 ind,'Active Subs' Activity,sum(subscount) MTN
from    default.Active_Subs
where   toYYYYMM(date) = (:yyyymm)
    and Operator = 'MTN'
group by Operator
union all
select  case
            when Activity = 'Voice&DATA' then 2
            when Activity = 'DATA' then 3
            when Activity = 'Voice' then 4
        end ind,
        Activity,subscount MTN
from    default.Active_Subs
where   toYYYYMM(date) = (:yyyymm)
    and Operator = 'MTN'
order by ind
) b on a.ind = b.ind
order by ind;
