/***** All Traffic Daily *****/

select desc,date,sum(duration) from (
select   1 ordr,'OnNet' desc
        ,toYYYYMMDD(EventDate) date
        ,round(sum(toUnixTimestamp(chargeableDuration))/60) duration
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
group by ordr,desc,date
union all
select 2 ordr,'International Outgoing'                    desc
        ,toYYYYMMDD(EventDate) date
        ,round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from ericsson -- 619002
where type in ('M_S_ORIGINATING', 'TRANSIT')
  and EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')
group by ordr,desc,date
union all
select 3 ordr,'International Incoming'                  desc
        ,toYYYYMMDD(EventDate) date
       ,round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from ericsson
where originForCharging = '1'
  and EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
group by ordr,desc,date
union all
select 4 ordr,'Incoming from Orange' desc
               ,toYYYYMMDD(EventDate) date ,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from ericsson
where   originForCharging = '1'
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and incomingRoute = 'CELLCI'
group by ordr,desc,date
union all
select 5 ordr,'Outgoing to Orange'                    desc
               ,toYYYYMMDD(EventDate) date ,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from ericsson -- 619002
where type in ('M_S_ORIGINATING', 'TRANSIT')
  and EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and outgoingRoute = 'CELLCO'
group by ordr,desc,date
) group by ordr,desc,date
order by ordr,date
;