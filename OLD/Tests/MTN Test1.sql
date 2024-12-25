select  type,EventDate,originForCharging,callingPartyNumber,calledPartyNumber,incomingRoute,outgoingRoute
        ,toUnixTimestamp(chargeableDuration)
from    ericsson
where   EventDate >= toDateTime('2018-11-01 00:00:00')
        and EventDate < toDateTime('2018-12-01 00:00:00')
        and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and length(calledPartyNumber) > 10
        and calledPartyNumber like '11%'
        and originForCharging = '1'
        and calledPartyNumber not like '1123188%' and calledPartyNumber not like '1123155%'
--         and calledPartyNumber not like '120023155%' and calledPartyNumber not like '12055%'
--         and calledPartyNumber not like '1202523188%' and calledPartyNumber not like '1207423188%'
--         and calledPartyNumber not like '1202523155%' and calledPartyNumber not like '1207423155%'
--         and calledPartyNumber not like '1223188%'
order by EventDate,callingPartyNumber,calledPartyNumber
limit 1000;

-- select * from ericsson where  type = 'M_S_ORIGINATING_SMS_IN_MSC'  limit 100;

select  distinct left(calledPartyNumber, 2) prefix, count() count,sum(toUnixTimestamp(chargeableDuration))/60
from    ericsson
where   EventDate >= toDateTime('2018-11-01 00:00:00')
        and EventDate < toDateTime('2018-12-01 00:00:00')
        and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and length(calledPartyNumber) > 9
        and calledPartyNumber like '112316%'
        and originForCharging = '1'
--         and calledPartyNumber not like '1423188%' and calledPartyNumber not like '1423155%'
--         and calledPartyNumber not like '14088%' and calledPartyNumber not like '14055%'
--         and calledPartyNumber not like '120023188%' and calledPartyNumber not like '12088%'
--         and calledPartyNumber not like '120023155%' and calledPartyNumber not like '12055%'
--         and calledPartyNumber not like '1202523188%' and calledPartyNumber not like '1207423188%'
--         and calledPartyNumber not like '1202523155%' and calledPartyNumber not like '1207423155%'
--         and calledPartyNumber not like '1223188%'
group by prefix;

/*********On Net Called Number************/

select  type,EventDate,originForCharging,callingPartyNumber,calledPartyNumber,incomingRoute,outgoingRoute
        ,toUnixTimestamp(chargeableDuration)
from    ericsson
where   EventDate >= toDateTime('2018-11-01 00:00:00')
        and EventDate < toDateTime('2018-12-01 00:00:00')
        and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and calledPartyNumber like '14%'
        and length(calledPartyNumber) > 9
        and originForCharging = '1'
        and (calledPartyNumber like '1423188%' or calledPartyNumber  like '1423155%'
                or calledPartyNumber  like '14088%' or calledPartyNumber  like '14055%'
                or calledPartyNumber  like '120023188%' or calledPartyNumber  like '12088%'
                or calledPartyNumber  like '120023155%' or calledPartyNumber  like '12055%'
                or calledPartyNumber  like '1202523188%' or calledPartyNumber  like '1207423188%'
                or calledPartyNumber  like '1202523155%' or calledPartyNumber  like '1207423155%'
                or calledPartyNumber  like '1223188%')
--         and (calledPartyNumber like '1423188%' or calledPartyNumber like '1423155%'
--                 OR calledPartyNumber like '14088%' or calledPartyNumber like '14055%')
order by EventDate,callingPartyNumber,calledPartyNumber
limit 1000;

/*********On Net Calling Number************/

select  type,EventDate,originForCharging,callingPartyNumber,calledPartyNumber,incomingRoute,outgoingRoute
        ,toUnixTimestamp(chargeableDuration)
from    ericsson
where   EventDate >= toDateTime('2018-11-01 00:00:00')
        and EventDate < toDateTime('2018-12-01 00:00:00')
        and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and originForCharging = '1'
        and length(callingPartyNumber) > 9
        and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%'
                OR callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
order by EventDate,callingPartyNumber,calledPartyNumber
limit 1000;


/********On Net All**********/

select   'OnNet' Dest  ,round(sum(toUnixTimestamp(chargeableDuration))/60)
--        type,EventDate,originForCharging,callingPartyNumber,calledPartyNumber,incomingRoute,outgoingRoute
        from    ericsson
where   EventDate >= toDateTime('2019-04-01 00:00:00')
        and EventDate < toDateTime('2019-05-01 00:00:00')
        and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
--         and calledPartyNumber like '14%'
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
group by Dest
-- order by EventDate,callingPartyNumber,calledPartyNumber
limit 1000;


/*select substring(filepath, 1, position(filepath, 'VTF')-2) fp, count()
from ericsson
where EventDate < toDateTime('2018-01-01 00:00:00')
/*where callingPartyNumber = '116281903910545'
  and EventDate like '2017-11-17%'
order by EventDate, callingPartyNumber*/
group by fp
limit 100;*/

select 5 ordr,'OffNet Voice incoming'                    desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from ericsson
where   originForCharging = '1'
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and incomingRoute = 'CELLCI';


select 4 ordr,'OffNet Voice'                    desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from ericsson -- 619002
where type in ('M_S_ORIGINATING', 'TRANSIT')
  and EventDate >= toDateTime(:from_v)
  and EventDate < toDateTime(:to_v)
  and outgoingRoute = 'CELLCO'
;