/***** All Traffic *****/

select desc,duration from (
select   1 ordr,'OnNet' desc
        ,round(sum(toUnixTimestamp(chargeableDuration))/60) duration
        from    ericsson
where   type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
--         and length(calledPartyNumber) > 8
        and originForCharging = '1'
        and (calledPartyNumber like '1423188%' or calledPartyNumber  like '1423155%'
                or calledPartyNumber  like '14088%' or calledPartyNumber  like '14055%'
                or calledPartyNumber  like '120023188%' or calledPartyNumber  like '12088%'
                or calledPartyNumber  like '120023155%' or calledPartyNumber  like '12055%'
                or calledPartyNumber  like '1202523188%' or calledPartyNumber  like '1207423188%'
                or calledPartyNumber  like '1202523155%' or calledPartyNumber  like '1207423155%'
                or calledPartyNumber  like '1223188%')
        and length(callingPartyNumber) > 8
        and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%'
                OR callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
union all
select 2 ordr,'International Outgoing'                    desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from ericsson -- 619002
where type in ('M_S_ORIGINATING', 'TRANSIT')
  and EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')
union all
select 3 ordr,'International Incoming'                  desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from ericsson
where originForCharging = '1'
  and EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
union all
select 4 ordr,'Incoming from Orange' desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from ericsson
where   originForCharging = '1'
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and incomingRoute = 'CELLCI'
union all
select 5 ordr,'Outgoing to Orange'                    desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from ericsson -- 619002
where type in ('M_S_ORIGINATING', 'TRANSIT')
  and EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and outgoingRoute = 'CELLCO'
)
order by ordr
;

/****** Incoming International ********/

select  substring(callingPartyNumber,3) CallingNumber
        ,case when left(calledPartyNumber,2)='12' then substring(calledPartyNumber,6)
            else substring(calledPartyNumber,3) end as CalledNumber
        ,dateForStartOfCharge date
        ,timeForStartOfCharge answerTime
        ,timeForStopOfCharge releaseTime
        ,toUnixTimestamp(chargeableDuration) Duration
        ,incomingRoute Trunk
from    ericsson
where   type not in ('M_S_TERMINATING_SMS_IN_MSC','M_S_ORIGINATING_SMS_IN_MSC','S_S_PROCEDURE')
        and EventDate >= toDateTime('2019-04-01 00:00:00')
        and EventDate < toDateTime('2019-05-01 00:00:00')
        and originForCharging = '1'
        and toUnixTimestamp(chargeableDuration) >0
        and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
order by date,answerTime;

/****** Outgoing International ********/

select  substring(callingPartyNumber,3) CallingNumber
        ,substring(calledPartyNumber,3) CalledNumber
        ,dateForStartOfCharge date
        ,timeForStartOfCharge answerTime
        ,timeForStopOfCharge releaseTime
        ,outgoingRoute,toUnixTimestamp(chargeableDuration) Duration
from    ericsson
where   type in ('M_S_ORIGINATING', 'TRANSIT')
        and EventDate >= toDateTime('2019-04-01 00:00:00')
        and EventDate < toDateTime('2019-05-01 00:00:00')
        and toUnixTimestamp(chargeableDuration) >0
        and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')
order by date,answerTime;

/*
/*******On Net All*********/

select   3 ordr,'OnNet' desc
        ,round(sum(toUnixTimestamp(chargeableDuration))/60)
        from    ericsson
where   EventDate >= toDateTime('2019-04-01 00:00:00')
        and EventDate < toDateTime('2019-05-01 00:00:00')
        and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
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
group by desc
;


select 3 ordr,desc, sum(mins) from (
    select 'On Net' desc, round(sum(toUnixTimestamp(chargeableDuration)) / 60) mins
    from ericsson
    where type = 'M_S_ORIGINATING'
    and (callingPartyNumber like '1488%'
         or callingPartyNumber like '1455%'
         or callingPartyNumber like '1123188%'
         or callingPartyNumber like  '1123155%')
    and (translatedNumber like '12088%'
         or translatedNumber like '120023188%'
         or translatedNumber like '1123188%'
         or translatedNumber like '12055%'
         or translatedNumber like '120023155%'
         or translatedNumber like '1123155%')
      and EventDate >= toDateTime(:from_v)
      and EventDate < toDateTime(:to_v)
union all
    select 'On Net' desc, round (sum(toUnixTimestamp(chargeableDuration)) / 60) minutes
    from ericsson where
        type = 'CALL_FORWARDING'
    and (callingPartyNumber like '1488%'
         or callingPartyNumber like '1455%'
         or callingPartyNumber like '1123188%'
         or callingPartyNumber like '1123155%')
    and (translatedNumber like '12088%'
         or translatedNumber like '120023188%'
         or translatedNumber like '1123188%'
         or translatedNumber like '12055%'
         or translatedNumber like '120023155%'
         or translatedNumber like '1123155%')
      and EventDate >= toDateTime(:from_v)
      and EventDate < toDateTime(:to_v)
)group by desc*/