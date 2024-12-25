select 3 ordr,'International Incoming'                  MTN,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
from ericsson
where type not in  ('M_S_TERMINATING','ROAMING_CALL_FORWARDING')
  and EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and eosInfo <> '2'
  and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')


/*type
CALL_FORWARDING
M_S_ORIGINATING
M_S_ORIGINATING_SMS_IN_MSC
M_S_TERMINATING
ROAMING_CALL_FORWARDING
TRANSIT
M_S_TERMINATING_SMS_IN_MSC
S_S_PROCEDURE
*/






timeForStartOfCharge,timeForStopOfCharge
select substring(translatedNumber,1,2) prefix
     ,case when timeForStartOfCharge like ('2019-%') then '1' else '2' end as test
     ,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
-- select type,EventDate,dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge,callingPartyNumber,calledPartyNumber
--         ,translatedNumber,toUnixTimestamp(chargeableDuration)
from ericsson -- 619002
where EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and type in  ('M_S_ORIGINATING')
group by prefix,test
limit 1000;


/*select   1 ordr,'OnNet' MTN
        ,round(sum(toUnixTimestamp(chargeableDuration))/60) Minutes
select callingSubscriberIMSI,calledSubscriberIMSI
from    ericsson
where type in  ('M_S_ORIGINATING')
  and EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and callingSubscriberIMSI like '618%'
  and calledSubscriberIMSI like '618%'*/

--   941020

select type,EventDate,callingPartyNumber,calledPartyNumber,substring(translatedNumber,3),toUnixTimestamp(chargeableDuration)
/*select 2 ordr,'International Outgoing'                    MTN,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
        ,count() count*/
from ericsson
where EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')

-- select type,callingPartyNumber,calledPartyNumber,substring(translatedNumber,3)
select 2 ordr,'International Outgoing'                    MTN,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
        ,count() count
from ericsson
where type in  ('M_S_ORIGINATING'/*,'M_S_TERMINATING','CALL_FORWARDING','ROAMING_CALL_FORWARDING'*/)
  and EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
--   and translatedNumber like '12%'
--   OR translatedNumber like '11%'
--   and translatedNumber not like '11231%'
  and substring(translatedNumber,3) not like '05%'
  and substring(translatedNumber,3) not like '07%'
  and substring(translatedNumber,3) not like '08%'
  and substring(translatedNumber,3) not like '00231%'
  and substring(translatedNumber,3) not like '231%'
  and length(substring(translatedNumber,3)) > 6
limit 1000;

select type,EventDate,callingPartyNumber,calledPartyNumber,substring(translatedNumber,3),toUnixTimestamp(chargeableDuration)
from ericsson
where mobileStationRoamingNumber like '%4917201231276'
  and EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
order by EventDate

select type,EventDate,dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge,callingPartyNumber,calledPartyNumber
        ,translatedNumber,mobileStationRoamingNumber,toUnixTimestamp(chargeableDuration)
from ericsson
where EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC')
  and substring(callingPartyNumber,1,2) = '14'
  and callingPartyNumber not like '1488%'
  and callingPartyNumber not like '1477%'
  and callingPartyNumber not like '1455%'
  and callingPartyNumber not like '141699'
order by EventDate
limit 1000;

select substring(mobileStationRoamingNumber,1,3) prefix,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes,count() count
from ericsson
where EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and type in  ('ROAMING_CALL_FORWARDING')
  and mobileStationRoamingNumber  like '11231%'
--   or translatedNumber  like '120023177%'
--   or translatedNumber  like '127%'
--   or translatedNumber  like '1207%'
--   or translatedNumber  like '1123177%')
group by prefix;


select /*substring(translatedNumber,1,2) prefix,*/round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes,count() count
from ericsson
where EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and type in  ('TRANSIT')
  and eosInfo = '0'
--   and translatedNumber like '14%'
  and translatedNumber not like '1488%'
  and translatedNumber not like '1477%'
  and translatedNumber not like '1455%'
  and translatedNumber not like '14088%'
  and translatedNumber not like '14077%'
  and translatedNumber not like '14055%'
  and translatedNumber not like '1400231%'
  and translatedNumber not like '11231%'
  and length(substring(translatedNumber,3)) > 6
group by prefix;

select round(sum(Minutes) / 60)
from (
         select dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge,
                callingPartyNumber,
                translatedNumber,
                toUnixTimestamp(chargeableDuration)/count() Minutes
         from ericsson
         where EventDate >= toDateTime(:from_v)
           and EventDate < toDateTime(:to_v)
           and type in ('M_S_ORIGINATING')
--            and eosInfo = '0'
           and translatedNumber not like '1488%'
           and translatedNumber not like '1477%'
           and translatedNumber not like '1455%'
           and translatedNumber not like '14088%'
           and translatedNumber not like '14077%'
           and translatedNumber not like '14055%'
           and translatedNumber not like '14231%'
           and translatedNumber not like '1400231%'
--            and translatedNumber not like '1288%'
--            and translatedNumber not like '1277%'
--            and translatedNumber not like '1255%'
           and translatedNumber not like '12088%'
           and translatedNumber not like '12077%'
           and translatedNumber not like '12055%'
           and translatedNumber not like '12231%'
           and translatedNumber not like '1200231%'
           and translatedNumber not like '11231%'
           and length(substring(translatedNumber, 3)) > 6
         group by dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge, callingPartyNumber, translatedNumber,chargeableDuration
         );




select 2 ordr,'Off Net Outgoing'                    MTN,
       sum(Minutes) Minutes
from (
--         select round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
--         from ericsson
--         where type in ('M_S_ORIGINATING', 'TRANSIT','CALL_FORWARDING')
--           and EventDate >= toDateTime(:from_v)
--           and EventDate < toDateTime(:to_v)
--           and outgoingRoute = 'CELLCO'
--         union all
        select round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
        from ericsson
        where EventDate >= toDateTime(:from_v)
                and EventDate < toDateTime(:to_v)
                and type in ('CALL_FORWARDING')
                and (translatedNumber like '1477%'
                or translatedNumber  like '1423177%')
--                 and length(substring(translatedNumber, 3)) > 6
        union all
        select round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
        from ericsson
        where EventDate >= toDateTime(:from_v)
                and EventDate < toDateTime(:to_v)
                and type in ('CALL_FORWARDING')
                and (translatedNumber like '1177%'
                or translatedNumber  like '1123177%')
--                 and length(substring(translatedNumber, 3)) > 6
        union all
        select round(sum(Minutes) / 60) Minutes
        from (
                select dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge,
                        callingPartyNumber,translatedNumber,
                        toUnixTimestamp(chargeableDuration)/count() Minutes
                from ericsson
                where EventDate >= toDateTime(:from_v)
                  and EventDate < toDateTime(:to_v)
                  and type in  ('M_S_ORIGINATING')
                  and (translatedNumber  like '1407%'
                  or translatedNumber  like '120023177%'
                  or translatedNumber  like '127%'
                  or translatedNumber  like '1207%'
                  or translatedNumber  like '1123177%'
                  or outgoingRoute = 'CELLCO')
--                   and length(substring(translatedNumber, 3)) > 6
                group by dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge, callingPartyNumber, translatedNumber,toUnixTimestamp(chargeableDuration)
                )
        );

        select outgoingAssignedRoute,round(sum(Minutes) / 60) Minutes
        from (
                select dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge,
                        callingPartyNumber,translatedNumber,outgoingAssignedRoute,
                        toUnixTimestamp(chargeableDuration)/count() Minutes
                from ericsson
                where EventDate >= toDateTime(:from_v)
                        and EventDate < toDateTime(:to_v)
                        and outgoingRoute = 'CELLCO'
                group by dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge, callingPartyNumber, translatedNumber,outgoingAssignedRoute,chargeableDuration
                )
group by outgoingAssignedRoute

                select type,EventDate,dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge,
                        callingPartyNumber,calledPartyNumber,translatedNumber,mobileStationRoamingNumber,
                        toUnixTimestamp(chargeableDuration) Minutes
                from ericsson
                where EventDate >= toDateTime(:from_v)
                        and EventDate < toDateTime(:to_v)
                        and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC')
                order by dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge
                limit 1000;

