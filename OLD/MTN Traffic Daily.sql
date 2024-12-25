/***** All Traffic *****/

select  Day,MTN,Minutes from (
select   1 ordr,toYYYYMMDD(EventDate) Day,'OnNet' MTN
        ,round(sum(toUnixTimestamp(chargeableDuration))/60) Minutes
        from    ericsson
where   type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and length(calledPartyNumber) > 9
        and originForCharging = '1'
        and (calledPartyNumber like '1423188%' or calledPartyNumber  like '1423155%'
                or calledPartyNumber  like '14088%' or calledPartyNumber  like '14055%'
                or calledPartyNumber  like '120023188%' or calledPartyNumber  like '12088%'
                or calledPartyNumber  like '120023155%' or calledPartyNumber  like '12055%'
                or calledPartyNumber  like '1202523188%' or calledPartyNumber  like '1207423188%'
                or calledPartyNumber  like '1202523155%' or calledPartyNumber  like '1207423155%'
                or calledPartyNumber  like '1223188%')
        and length(callingPartyNumber) > 9
        and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%'
                OR callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
GROUP BY Day,MTN
union all
select 2 ordr,Day,'International Outgoing'  MTN
       ,sum(Minutes) Minutes
from (
        select toYYYYMMDD(EventDate) Day,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
        from ericsson
        where EventDate >= toDateTime(:from_v)
                and EventDate < toDateTime(:to_v)
                and type in ('ROAMING_CALL_FORWARDING')
                and mobileStationRoamingNumber not like '11231%'
        GROUP BY Day
        union all
        select toYYYYMMDD(EventDate) Day,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
        from ericsson
        where EventDate >= toDateTime(:from_v)
                and EventDate < toDateTime(:to_v)
                and type in ('CALL_FORWARDING')
                and translatedNumber like '14%'
                and translatedNumber not like '14231%'
        GROUP BY Day
        union all
        select toYYYYMMDD(EventDate) Day,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
        from ericsson
        where EventDate >= toDateTime(:from_v)
                and EventDate < toDateTime(:to_v)
                and type in ('CALL_FORWARDING')
                and translatedNumber like '11%'
                and translatedNumber not like '11231%'
        GROUP BY Day
        union all
        select  Day,round(sum(Minutes) / 60) Minutes
        from (
                select toYYYYMMDD(EventDate) Day,dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge,
                        callingPartyNumber,translatedNumber,
                        toUnixTimestamp(chargeableDuration)/count() Minutes
                from ericsson
                where EventDate >= toDateTime(:from_v)
                        and EventDate < toDateTime(:to_v)
                        and type in ('M_S_ORIGINATING')
                        and translatedNumber not like '1488%'
                        and translatedNumber not like '1477%'
                        and translatedNumber not like '1455%'
                        and translatedNumber not like '14088%'
                        and translatedNumber not like '14077%'
                        and translatedNumber not like '14055%'
                        and translatedNumber not like '14231%'
                        and translatedNumber not like '1400231%'
                        and translatedNumber not like '12088%'
                        and translatedNumber not like '12077%'
                        and translatedNumber not like '12055%'
                        and translatedNumber not like '12231%'
                        and translatedNumber not like '1200231%'
                        and translatedNumber not like '11231%'
                        and length(substring(translatedNumber, 3)) > 6
                group by toYYYYMMDD(EventDate),dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge, callingPartyNumber, translatedNumber,chargeableDuration
                )GROUP BY Day
        )GROUP BY Day,MTN
union all
select 3 ordr,toYYYYMMDD(EventDate) Day,'International Incoming' MTN
       ,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
from ericsson
where   type in  ('TRANSIT')
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and eosInfo <> '2'
        and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
GROUP BY Day,MTN
union all
select 5 ordr,toYYYYMMDD(EventDate) Day,'Orange To MTN' MTN
       ,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
from ericsson
where   originForCharging = '1'
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and incomingRoute = 'CELLCI'
GROUP BY Day,MTN
union all
select 4 ordr,toYYYYMMDD(EventDate) Day,'MTN to Orange' MTN
       ,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
from ericsson -- 619002
where EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and outgoingRoute = 'CELLCO'
GROUP BY Day,MTN
    )
GROUP BY ordr,Day,MTN,Minutes
order by ordr,Day
;
