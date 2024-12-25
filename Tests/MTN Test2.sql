-- 'Incoming calls from International'
select callingPartyNumber, calledPartyNumber, incomingRoute,outgoingRoute
--incomingRoute, count(), round(sum(toUnixTimestamp(chargeableDuration))/60) duration
from ericsson
where  EventDate >= toDateTime('2018-11-01 00:00:00')
  and EventDate < toDateTime('2018-12-01 00:00:00')
  and callingPartyNumber like '14%'
  and callingPartyNumber not like '1488%'
  and length(callingPartyNumber) > 11
--   and callingPartyNumber not like '11231%'
--   and callingPartyNumber like '11%'
--   and callingPartyNumber not like '11231%'
  and originForCharging = '1'
-- group by incomingRoute
-- limit 100
;



select *
--select incomingRoute,count()
--select substring(callingPartyNumber, 1,5) prefix,count()
from ericsson
where EventDate >= toDateTime('2018-11-01 00:00:00')
  and EventDate < toDateTime('2018-12-01 00:00:00')
  and incomingRoute = 'RNC3I'
  and originForCharging = '1'
  and callingPartyNumber <> ''
  and callingPartyNumber not like '14%'
  and  substring(callingPartyNumber, 1,5) not like '11231%' and length(callingPartyNumber) > 10
--limit 1000
group by incomingRoute
order by count() desc ;

/*
select * from ericsson
where EventDate = '2018-11-26 08:57:28'
    and callingPartyNumber = '110013479642095'
    and calledPartyNumber = '140555595949';
  */

select toYYYYMM(EventDate) date,count()
from ericsson
where type not in ('M_S_TERMINATING_SMS_IN_MSC','M_S_ORIGINATING_SMS_IN_MSC','S_S_PROCEDURE')
/*EventDate >= toDateTime('2019-03-01 00:00:00')
  and EventDate < toDateTime('2019-04-01 00:00:00')
   and originForCharging = ''*/
group by date
order by date;

select type,EventDate,originForCharging,callingPartyNumber, calledPartyNumber, incomingRoute,outgoingRoute
from ericsson
where EventDate >= toDateTime('2018-11-01 00:00:00')
  and EventDate < toDateTime('2018-12-01 00:00:00')
  and type not in ('M_S_TERMINATING_SMS_IN_MSC','M_S_ORIGINATING_SMS_IN_MSC','S_S_PROCEDURE')
order by EventDate,callingPartyNumber,calledPartyNumber
limit 100;

/*
CALL_FORWARDING
M_S_ORIGINATING
M_S_ORIGINATING_SMS_IN_MSC
M_S_TERMINATING
M_S_TERMINATING_SMS_IN_MSC
ROAMING_CALL_FORWARDING
S_S_PROCEDURE
TRANSIT

GENI
ZURI
BRFI
BRGI
BRG2I
BRF2I
ZUR2I
GEN2I
RNC3I
BSC2EVI
BSC4EVI
RNC2I
BSC3W2I
NOVA2I
MBC1I

*/
