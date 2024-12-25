/*
create table mediation.MTN_Subs(Date String,MSISDN String)
ENGINE = Memory;

drop table mediation.MTN_Subs
truncate table mediation.Orange_Subs
*/
-- select   count(distinct MSISDN) MSISDN
-- from     mediation.Orange_Subs;

insert into mediation.Orange_Subs

select  (substring(toString(eventTimeStamp),1,4) || '' || substring(toString(eventTimeStamp),6,2)) Date,
        substring(servedMSISDN, 3) MSISDN
from    mediation.zte
where   toDate(eventTimeStamp) between now() - (86400*90)  and now()
    and type in ('MO_CALL_RECORD', 'MCF_CALL_RECORD', 'MO_SMS_RECORD', 'MO_LCS_RECORD', 'ROAM_RECORD')
    and substring(servedMSISDN, 3, 4) = '2317'
group by Date,MSISDN;

insert into mediation.Orange_Subs

select  (substring(toString(recordOpeningTime),1,4) || '' || substring(toString(recordOpeningTime),6,2)) Date,
        substring(servedMSISDN, 3) MSISDN
from    data_zte
where   toDate(recordOpeningTime) between now() - (86400*90)  and now()
group by Date,MSISDN;

-- truncate table mediation.MTN_Subs
-- select   count(distinct MSISDN) MSISDN
-- from     mediation.MTN_Subs

insert into mediation.MTN_Subs

select  Date,MSISDN
from (
select  (substring(toString(EventDate),1,4) || '' || substring(toString(EventDate),6,2)) Date,
        case
           when substring(callingPartyNumber, 3, 2) in ('55', '88', '77')
               then '231' || '' || substring(callingPartyNumber, 3)
           else substring(callingPartyNumber, 3) end as MSISDN
from    mediation.ericsson
where   toDate(EventDate) between now() - (86400 * 90) and now()
        and MSISDN like ('23155%')
        or MSISDN like ('23188%'))
group by Date,MSISDN;

insert into mediation.MTN_Subs

select count(MSISDN) from (
select  Date,MSISDN
from (
select  (substring(toString(EventDate),1,4) || '' || substring(toString(EventDate),6,2)) Date,
        case
         when substring(calledPartyNumber, 3, 3) in ('055', '077', '088')
             then '231' || '' || substring(calledPartyNumber, 4)
         else
             (case
                  when substring(calledPartyNumber, 3, 6)
                      in ('025055', '025088', '025077', '074055', '074088', '074077', '095055', '095088',
                          '095077', '096055', '096088', '096077')
                      then ('231' || '' || substring(calledPartyNumber, 7))
           else
               (case
                    when substring(calledPartyNumber, 3, 5) in ('02500', '07400', '09500', '09600')
                        then substring(calledPartyNumber, 8)
            else
               (case
                    when substring(calledPartyNumber, 3, 5) in
                         ('02506', '07406', '09506', '09606')
                        then ('23188' || '' || substring(calledPartyNumber, 7))
            else
                (case
                     when substring(calledPartyNumber, 3, 2) = '00'
                         then substring(calledPartyNumber, 5)
            else
                (case
                     when substring(calledPartyNumber, 3, 3) in ('025', '074', '095', '096')
                         then substring(calledPartyNumber, 6)
                  else substring(calledPartyNumber, 3) end) end) end) end) end) end as MSISDN
from    mediation.ericsson
where   toDate(EventDate) between now() - (86400*90)  and now()
        and toUnixTimestamp(chargeableDuration) > 0
        and MSISDN like ('23155%') or MSISDN like ('23188%'))
group by Date,MSISDN);

insert into mediation.MTN_Subs

select  Date,MSISDN
from (
select  (substring(toString(recordOpeningTime),1,4) || '' || substring(toString(recordOpeningTime),6,2)) Date,
       substring(servedMSISDN,3) MSISDN
from mediation.data_ericsson
where   toDate(recordOpeningTime) between now() - (86400*90)  and now() - (86400 * 60)
        and MSISDN like ('2315%') or MSISDN like ('2318%'))
group by Date,MSISDN;


