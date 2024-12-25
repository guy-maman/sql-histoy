
--    MTN Aggregation query for tables

select  'On_Net_ericsson' CallType,date,sum(chargeableDuration) callDuration
from (
select  toStartOfHour(EventDate) date,networkCallReference,max(toUnixTimestamp(chargeableDuration)/60) chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and toDayOfMonth(EventDate) = (:day)
    and incomingRoute not in
        ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I','L1MBC2I','L2MBC2I', 'CELLCI','ORGSBCI')
    and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO','ORGSBCO'
                ,'BCPBX1O','ISON1O','IVR1O','MAV2O','VIAMOO')
    and length(calledPartyNumber) > 7
    and length(callingPartyNumber) > 7
group by date,networkCallReference
)group by date
order by date
;

select  'Orange_To_MTN_ericsson' CallType,date,sum(chargeableDuration) callDuration
from (
select  toStartOfHour(EventDate) date,networkCallReference,max(toUnixTimestamp(chargeableDuration)/60) chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and toDayOfMonth(EventDate) = (:day)
    and incomingRoute in ('CELLCI', 'ORGSBCI')
group by date,networkCallReference
)group by date
order by date
;

select  'MTN_To_Orange_ericsson' CallType,date,sum(chargeableDuration) callDuration
from (
select  toStartOfHour(EventDate) date,networkCallReference,max(toUnixTimestamp(chargeableDuration)/60) chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and toDayOfMonth(EventDate) = (:day)
    and outgoingRoute in ('CELLCO', 'ORGSBCO')
group by date,networkCallReference
)group by date
order by date
;

select  'International_Incoming_ericsson' CallType,date,sum(chargeableDuration) callDuration
from (
select  toStartOfHour(EventDate) date,networkCallReference,max(toUnixTimestamp(chargeableDuration)/60) chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and toDayOfMonth(EventDate) = (:day)
    and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I','L1MBC2I', 'L2MBC2I')
group by date,networkCallReference
)group by date
order by date
;

select  'International_Outgoing_ericsson' CallType,date,sum(chargeableDuration) callDuration
from (
select  toStartOfHour(EventDate) date,networkCallReference,max(toUnixTimestamp(chargeableDuration)/60) chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and toDayOfMonth(EventDate) = (:day)
    and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
group by date,networkCallReference
)group by date
order by date
;

---------------------------------------------------------------------------------------------------------------------------------

--   ORANGE Aggregation query for tables


select  'On_Net_zte' CallType,toStartOfHour(eventTimeStamp) date,round(sum(callDuration)/60,2) callDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and toDayOfMonth(eventTimeStamp) = (:day)
    and type in ('MO_CALL_RECORD')
    and (incomingTKGPName in
      ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat','SBC_siptrunk', 'VOIPE_PBX_SIP')
    and outgoingTKGPName in
        ('',  'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat','SBC_siptrunk'))
    and callDuration > 0
group by CallType,date
order by date
;

select  'Orange_To_MTN_zte' CallType,toStartOfHour(eventTimeStamp) date,round(sum(callDuration)/60,2) callDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and toDayOfMonth(eventTimeStamp) = (:day)
    and callDuration > 0
    and type in ('OUT_GATEWAY_RECORD')
    and outgoingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
group by CallType,date
order by date
;

select  'MTN_To_Orange_zte' CallType,toStartOfHour(eventTimeStamp) date,round(sum(callDuration)/60,2) callDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and toDayOfMonth(eventTimeStamp) = (:day)
    and callDuration > 0
    and type in ('INC_GATEWAY_RECORD')
    and incomingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
group by CallType,date
order by date
;

select  'International_Incoming_zte' CallType,date,round(sum(chargeableDuration)/60,2) callDuration
from (
select  toStartOfHour(eventTimeStamp) date,callReference,max(callDuration) chargeableDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and toDayOfMonth(eventTimeStamp) = (:day)
    and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
group by date,callReference
)group by CallType,date
order by date
;


select  'International_Outgoing_zte' CallType,date,round(sum(chargeableDuration)/60,2) callDuration
from (
select  toStartOfHour(eventTimeStamp) date,callReference,max(callDuration) chargeableDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and toDayOfMonth(eventTimeStamp) = (:day)
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
group by date,callReference
)group by CallType,date
order by date
;