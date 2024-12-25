/*
select distinct left(callingPartyNumber,4) from mediation.ericsson
where EventDate between '2019-03-01 00:00:00' and '2019-03-01 23:59:59'
and length(callingPartyNumber) >10
and type not in ('M_S_TERMINATING_SMS_IN_MSC','M_S_ORIGINATING_SMS_IN_MSC','S_S_PROCEDURE');

select * from mediation.ericsson
where EventDate between '2019-03-01 00:00:00' and '2019-03-01 23:59:59'
and type not in ('M_S_TERMINATING_SMS_IN_MSC','M_S_ORIGINATING_SMS_IN_MSC','S_S_PROCEDURE')
and originForCharging not in ('0')
and callingPartyNumber like '11%'
and callingPartyNumber not like '1488%'
--and calledPartyNumber like ''
;

On Net
callingPartyNumber like '1488%'
callingPartyNumber like '1455%'


select distinct left(calledPartyNumber,2) from mediation.ericsson
where EventDate between '2019-03-01 00:00:00' and '2019-03-01 23:59:59'
and type not in ('M_S_TERMINATING_SMS_IN_MSC','M_S_ORIGINATING_SMS_IN_MSC','S_S_PROCEDURE')
and length(callingPartyNumber) >10;

select * from mediation.ericsson where EventDate between '2019-03-01 00:00:00' and '2019-03-01 23:59:59'
    and callingPartyNumber like '14%'
    and callingPartyNumber not like '147%' and callingPartyNumber not like '148%' and callingPartyNumber not like '145%';

select --length(callingPartyNumber) LenCalling, length(calledPartyNumber) LenCalled
       case when (length(callingPartyNumber) <10) then 'Short'
            when right(callingPartyNumber,length(callingPartyNumber)-2) like '88%' and right(calledPartyNumber,length(calledPartyNumber)-2) like '088%' then 'On Net'
         else '' end as Dest
     , right(callingPartyNumber,length(callingPartyNumber)-2) calling
     , right(calledPartyNumber,length(calledPartyNumber)-2) called
     , type,originForCharging,EventDate,callIdentificationNumber,relatedCallNumber,callingPartyNumber,calledPartyNumber,translatedNumber
     , incomingRoute,outgoingRoute,redirectionCounter,redirectingNumber,filepath
from ericsson where EventDate between '2019-03-01 00:00:00' and '2019-03-01 23:59:59'
and type not in ('M_S_TERMINATING_SMS_IN_MSC','M_S_ORIGINATING_SMS_IN_MSC','S_S_PROCEDURE')
and originForCharging not in ('0')
--and  left(callingPartyNumber,2) = ''
order by EventDate,callingPartyNumber,calledPartyNumber --limit 1000000
--group by type limit 1000;
;
--distinct type, count()

select originForCharging,count() from ericsson where EventDate between '2019-03-01 00:00:00' and '2019-03-01 23:59:59'
group by originForCharging;

ROAMING_CALL_FORWARDING	1583840
CALL_FORWARDING	97418
M_S_TERMINATING_SMS_IN_MSC	3551531
M_S_ORIGINATING_SMS_IN_MSC	86630
TRANSIT	2361190
S_S_PROCEDURE	2438851
M_S_TERMINATING	1562857
M_S_ORIGINATING	1564400


--select * from zte where callingNumber like '%770078153'
*/
--on net

select  type
        ,callingPartyNumber
        ,calledPartyNumber
        ,incomingRoute,outgoingRoute,toUnixTimestamp(chargeableDuration) Duration
from    ericsson
where   type not in ('M_S_TERMINATING_SMS_IN_MSC','M_S_ORIGINATING_SMS_IN_MSC','S_S_PROCEDURE')
        and EventDate >= toDateTime('2019-04-01 00:00:00')
        and EventDate < toDateTime('2019-05-01 00:00:00')
        and originForCharging = '1'
        and length(callingPartyNumber) >10
        and toUnixTimestamp(chargeableDuration) >0
        and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')
--         and ((callingPartyNumber like '14%' and callingPartyNumber not like '1477%')
--             or (callingPartyNumber like '11231%' and callingPartyNumber not like '1123177%'))
limit 1000;

select  left(calledPartyNumber,2) prefix,count(),round(sum(toUnixTimestamp(chargeableDuration))/60) duration
from    ericsson
where   type not in ('M_S_TERMINATING_SMS_IN_MSC','M_S_ORIGINATING_SMS_IN_MSC','S_S_PROCEDURE')
        and EventDate >= toDateTime('2019-04-01 00:00:00')
        and EventDate < toDateTime('2019-05-01 00:00:00')
        and originForCharging = '1'
        and length(callingPartyNumber) >10
        and toUnixTimestamp(chargeableDuration) >0
--         and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
group by prefix;


/****** Incoming International ********/

select  type
        ,substring(callingPartyNumber,3) CallingNumber
        ,case when left(calledPartyNumber,2)='12' then substring(calledPartyNumber,6)
            else substring(calledPartyNumber,3) end as CalledNumber
        ,incomingRoute,toUnixTimestamp(chargeableDuration) Duration
from    ericsson
where   type not in ('M_S_TERMINATING_SMS_IN_MSC','M_S_ORIGINATING_SMS_IN_MSC','S_S_PROCEDURE')
        and EventDate >= toDateTime('2019-04-01 00:00:00')
        and EventDate < toDateTime('2019-05-01 00:00:00')
        and originForCharging = '1'
        and toUnixTimestamp(chargeableDuration) >0
        and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
--         and CallingNumber  like '23155%'
--         and CalledNumber not like '23155%'

;


/****** Outgoing International ********/

select  type
        ,substring(callingPartyNumber,3) CallingNumber
        ,substring(calledPartyNumber,3) CalledNumber
        ,outgoingRoute,toUnixTimestamp(chargeableDuration) Duration
from    ericsson
where   type in ('M_S_ORIGINATING', 'TRANSIT')
        and EventDate >= toDateTime('2019-04-01 00:00:00')
        and EventDate < toDateTime('2019-05-01 00:00:00')
        and toUnixTimestamp(chargeableDuration) >0
        and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')
;

--distinct left(calledPartyNumber,2)