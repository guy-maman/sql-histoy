
select case when type = 'CALL_FORWARDING' then 1
            when type = 'M_S_ORIGINATING' then 2
            when type = 'M_S_TERMINATING' then 3
            when type = 'ROAMING_CALL_FORWARDING' then 4
            when type = 'TRANSIT' then 5
        else 0 end as No
     , (type)
     , substring(toString(dateForStartOfCharge), 1, 10) || ' ' ||
       substring(toString(timeForStartOfCharge), 12)              timeForStartOf_Charge
     , callingPartyNumber
     , (calledPartyNumber) calledParty_Number
     , (originalCalledNumber)
     , (mobileStationRoamingNumber) mobileStationRoaming_Number
     , (translatedNumber)
     , (callingSubscriberIMSI) callingSubscriber_IMSI
     , (calledSubscriberIMSI) calledSubscriber_IMSI
     , (mscIdentification)
     , (mscAddress)
     , substring(mobileStationRoamingNumber,3,3) Outbound_CC
     , substring(mscAddress,3,3) Inbound_CC
     , (callIdentificationNumber)
     , (relatedCallNumber)
     , (firstCallingLocationInformation)
     , (incomingRoute) incoming_Route
     , (outgoingRoute) outgoing_Route
     , toUnixTimestamp(chargeableDuration) Minutes
from    ericsson
where   type not in ('M_S_ORIGINATING_SMS_IN_MSC', 'M_S_TERMINATING_SMS_IN_MSC')
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
--         and (callingPartyNumber like (:phoneNumber) or calledPartyNumber like (:phoneNumber))
--         and (Inbound_CC in ('221','224','225','228','229','232') or Outbound_CC in ('221','224','225','228','229','232'))
--         and ((mobileStationRoamingNumber not like '' and mobileStationRoamingNumber not like '112318%')
--         or (mscAddress not like '' and mscAddress not like '112318%'))
order by timeForStartOf_Charge,callingPartyNumber,callIdentificationNumber,relatedCallNumber
;


select  substring(callingPartyNumber,3) CallingNumber
        ,substring(calledPartyNumber,3) CalledNumber
        ,dateForStartOfCharge date
        ,timeForStartOfCharge answerTime
        ,timeForStopOfCharge releaseTime
        ,outgoingRoute,toUnixTimestamp(chargeableDuration) Duration;

select 'International Outgoing'  MTN,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes
from    ericsson
where   type in ('M_S_ORIGINATING', 'TRANSIT','ROAMING_CALL_FORWARDING')
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and toUnixTimestamp(chargeableDuration) >0
        and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')
;

-- order by date,answerTime
;






select substring(callingPartyNumber,3) callingPartyNumber
     ,case when length(substring(calledPartyNumber,3)) <5
         then '00' || '' || calledPartyNumber || '' || '9245'
         else substring(calledPartyNumber,3)
         end calledPartyNumber
     ,StartOf_Charge,chargeableDuration
from (
        select callingPartyNumber,mobileStationRoamingNumber calledPartyNumber
             ,substring(toString(dateForStartOfCharge), 1, 10) || ' ' || substring(toString(timeForStartOfCharge), 12) StartOf_Charge
             ,toUnixTimestamp(chargeableDuration) chargeableDuration
        from ericsson
        where EventDate >= toDateTime(:from_v)
                and EventDate < toDateTime(:to_v)
                and type in ('ROAMING_CALL_FORWARDING')
                and mobileStationRoamingNumber not like '11231%'
        union all
        select callingPartyNumber,translatedNumber calledPartyNumber
             ,substring(toString(dateForStartOfCharge), 1, 10) || ' ' || substring(toString(timeForStartOfCharge), 12) StartOf_Charge
             ,toUnixTimestamp(chargeableDuration) chargeableDuration
        from ericsson
        where EventDate >= toDateTime(:from_v)
                and EventDate < toDateTime(:to_v)
                and type in ('CALL_FORWARDING')
                and translatedNumber like '14%'
                and translatedNumber not like '14231%'
        union all
        select callingPartyNumber,translatedNumber calledPartyNumber
             ,substring(toString(dateForStartOfCharge), 1, 10) || ' ' || substring(toString(timeForStartOfCharge), 12) StartOf_Charge
             ,toUnixTimestamp(chargeableDuration) chargeableDuration
        from ericsson
        where EventDate >= toDateTime(:from_v)
                and EventDate < toDateTime(:to_v)
                and type in ('CALL_FORWARDING')
                and translatedNumber like '11%'
                and translatedNumber not like '11231%'
        union all
        select callingPartyNumber,calledPartyNumber,StartOf_Charge,chargeableDuration
        from (
                select callingPartyNumber,translatedNumber calledPartyNumber
                     ,substring(toString(dateForStartOfCharge), 1, 10) || ' ' || substring(toString(timeForStartOfCharge), 12) StartOf_Charge
                     ,toUnixTimestamp(chargeableDuration) chargeableDuration
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
                        and length(translatedNumber) > 6
                )
        )order by StartOf_Charge
;





select substring(callingPartyNumber,3) callingPartyNumber,substring(calledPartyNumber,3) calledPartyNumber
        ,substring(toString(dateForStartOfCharge), 1, 10) || ' ' || substring(toString(timeForStartOfCharge), 12) StartOf_Charge
        ,toUnixTimestamp(chargeableDuration) chargeableDuration
from ericsson
where   type in  ('TRANSIT')
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and eosInfo <> '2'
        and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
;