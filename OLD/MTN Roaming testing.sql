select type,timeForStartOfCharge,callingPartyNumber,calledPartyNumber,mobileStationRoamingNumber,translatedNumber,callingSubscriberIMSI,calledSubscriberIMSI
        ,callIdentificationNumber,relatedCallNumber
       ,incomingRoute,outgoingRoute,toUnixTimestamp(chargeableDuration) Minutes
from ericsson
where   type not in  ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC')
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
--         and eosInfo <> '2'
--         and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
order by timeForStartOfCharge
;

select type,timeForStartOfCharge,callingPartyNumber,calledPartyNumber,mobileStationRoamingNumber,translatedNumber,callingSubscriberIMSI,calledSubscriberIMSI
        ,callIdentificationNumber,relatedCallNumber
       ,incomingRoute,outgoingRoute,toUnixTimestamp(chargeableDuration) Minutes
from ericsson
where   type not in  ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC')
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and callingSubscriberIMSI not like '61801%'
        and callingSubscriberIMSI not like ''
--         and eosInfo <> '2'
--         and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
order by timeForStartOfCharge
limit 100
;

select time,round(sum(Minutes)/60) Minutes,count() count
from (
      select topK(type),dateForStartOfCharge as time
           , case
                 when (toUnixTimestamp(chargeableDuration) >= 10 and
                       substring(substring(toString(timeForStartOfCharge), 12), 8) < '9')
                     then substring(substring(toString(dateForStartOfCharge), 1, 10) || ' ' ||
                                    substring(toString(timeForStartOfCharge), 12), 1, 18) || '' || '0'
                 else (case
                           when substring(substring(toString(timeForStartOfCharge), 12), 8) = '9'
                               then substring(toString(dateForStartOfCharge), 1, 10) || ' ' ||
                                    substring(toString(timeForStartOfCharge + 1), 12)
                           else substring(toString(dateForStartOfCharge), 1, 10) || ' ' ||
                                substring(toString(timeForStartOfCharge), 12)
                     end)
          end as                                      timeForStartOf_Charge
           , callingPartyNumber
           , min(calledPartyNumber) calledParty_Number
           , max(mobileStationRoamingNumber) mobileStationRoaming_Number
           , max(callingSubscriberIMSI) callingSubscriber_IMSI
           , max(calledSubscriberIMSI) calledSubscriber_IMSI
           , topK(incomingRoute) incoming_Route
           , topK(outgoingRoute) outgoing_Route
           , max(toUnixTimestamp(chargeableDuration)) Minutes
      from ericsson
      where type in ('M_S_ORIGINATING', 'M_S_TERMINATING', 'TRANSIT', 'ROAMING_CALL_FORWARDING','CALL_FORWARDING')
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
      group by timeForStartOf_Charge, callingPartyNumber,time
      order by timeForStartOf_Charge
         ) group by time
            order by time
-- where  (callingSubscriber_IMSI like '61801%' or callingSubscriber_IMSI like '61804%')
--         and (calledSubscriber_IMSI like '61801%' or calledSubscriber_IMSI like '61804%')
;

select case when type = 'CALL_FORWARDING' then 1
            when type = 'M_S_ORIGINATING' then 2
            when type = 'M_S_TERMINATING' then 3
            when type = 'ROAMING_CALL_FORWARDING' then 4
            when type = 'TRANSIT' then 5
        else 0 end as No
     , (type)
     , toDateTime(substring(toString(dateForStartOfCharge), 1, 10) || ' ' || substring(toString(timeForStartOfCharge), 12) )  timeForStartOf_Charge
     , callingPartyNumber
     , (calledPartyNumber) calledParty_Number
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
     , (incomingRoute) incoming_Route
     , (outgoingRoute) outgoing_Route
     , toUnixTimestamp(chargeableDuration) Minutes
from    ericsson
where   EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and (callingPartyNumber like '14%'
--         and callingPartyNumber like '11%'
        or callingPartyNumber  like '11231%')
        and incomingRoute  in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
--         and (callingPartyNumber like (:phoneNumber) or calledPartyNumber like (:phoneNumber))
--         and (Inbound_CC in ('221','224','225','228','229','232') or Outbound_CC in ('221','224','225','228','229','232'))
--         and ((mobileStationRoamingNumber not like '' and mobileStationRoamingNumber not like '112318%')
--         or (mscAddress not like '' and mscAddress not like '112318%'))
order by timeForStartOf_Charge,callingPartyNumber,callIdentificationNumber,relatedCallNumber
;
type in (/*'M_S_ORIGINATING', 'M_S_TERMINATING', 'TRANSIT',*/ 'ROAMING_CALL_FORWARDING'/*,'CALL_FORWARDING'*/)
        and
-- select  substring(callingPartyNumber,3,3) CountryCode,round(sum(toUnixTimestamp(chargeableDuration))/60) chargeableDuration,count() count

select  substring(callingPartyNumber,1,5) CountryCode
from    ericsson
where   type in (/*'M_S_ORIGINATING', 'M_S_TERMINATING', 'TRANSIT',*/ 'ROAMING_CALL_FORWARDING'/*,'CALL_FORWARDING'*/)
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and callingPartyNumber like '11881%'
--         and callingPartyNumber like '11%'
--         and callingPartyNumber  like '11231%'
--         and CountryCode in ('221','224','225','228','229','232')
--         and incomingRoute  in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
group by CountryCode
-- order by timeForStartOf_Charge,callingPartyNumber,callIdentificationNumber,relatedCallNumber
;


select  CountryCode,InboundRoamersDuration,OutboundRoamersDuration
from (
      select substring(mscAddress, 3, 3)                          CountryCode,
             round(sum(toUnixTimestamp(chargeableDuration)) / 60) InboundRoamersDuration
      from ericsson
      where type in ('M_S_ORIGINATING', 'M_S_TERMINATING', 'TRANSIT', 'ROAMING_CALL_FORWARDING', 'CALL_FORWARDING')
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and substring(mscAddress, 3, 3) in ('221', '224', '225', '228', '229', '232')
      group by CountryCode
         )any inner join
     (
         select substring(mobileStationRoamingNumber, 3, 3)          CountryCode,
                round(sum(toUnixTimestamp(chargeableDuration)) / 60) OutboundRoamersDuration
         from ericsson
         where type in ('M_S_ORIGINATING', 'M_S_TERMINATING', 'TRANSIT', 'ROAMING_CALL_FORWARDING', 'CALL_FORWARDING')
           and EventDate >= toDateTime(:from_v)
           and EventDate < toDateTime(:to_v)
           and substring(mobileStationRoamingNumber, 3, 3) in ('221', '224', '225', '228', '229', '232')
         group by CountryCode
         )using CountryCode
;



select 2 ordr,dateForStartOfCharge time,'International Outgoing'  MTN
       ,sum(Minutes) Minutes, sum(count)
from (
        select dateForStartOfCharge,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes,count() count
        from ericsson
        where EventDate >= toDateTime(:from_v)
                and EventDate < toDateTime(:to_v)
                and type in ('ROAMING_CALL_FORWARDING')
                and mobileStationRoamingNumber not like '11231%'
        group by dateForStartOfCharge
        union all
        select dateForStartOfCharge,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes,count() count
        from ericsson
        where EventDate >= toDateTime(:from_v)
                and EventDate < toDateTime(:to_v)
                and type in ('CALL_FORWARDING')
                and translatedNumber like '14%'
                and translatedNumber not like '14231%'
        group by dateForStartOfCharge
        union all
        select dateForStartOfCharge,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes,count() count
        from ericsson
        where EventDate >= toDateTime(:from_v)
                and EventDate < toDateTime(:to_v)
                and type in ('CALL_FORWARDING')
                and translatedNumber like '11%'
                and translatedNumber not like '11231%'
        group by dateForStartOfCharge
        union all
        select dateForStartOfCharge,round(sum(Minutes) / 60) Minutes,count() count
        from (
                select dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge,
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
                group by dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge, callingPartyNumber, translatedNumber,chargeableDuration
                )group by dateForStartOfCharge
        )group by dateForStartOfCharge order by time
;


select  type,topK(callIdentificationNumber,relatedCallNumber),/*substring(callingPartyNumber,1,2) callingPartyNumber,*/round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes,count() count
from    ericsson
where   EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
group by type
order by type
;


select  type,substring(mobileStationRoamingNumber,1,2) calledPartyNumber,round(sum(toUnixTimestamp(chargeableDuration)) / 60) Minutes,count() count
from    ericsson
where   EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
group by type,calledPartyNumber
order by type,calledPartyNumber
;


/*select  /*topK(type),*/ case when substring(substring(toString(timeForStartOfCharge), 12), 8) < '9'
                then 0 else 1
            end Time
--         ,case when toUnixTimestamp(chargeableDuration)>= 10
--             then substring(substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12), 1, 18)  || '' || '0'
--             else substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12)
--             end as timeForStartOf_Charge
--         ,callingPartyNumber,min(calledPartyNumber),max(callingSubscriberIMSI),max(calledSubscriberIMSI)
--         ,topK(incomingRoute),topK(outgoingRoute),max(toUnixTimestamp(chargeableDuration)) Minutes
from ericsson
where   type in  ('M_S_ORIGINATING','M_S_TERMINATING','TRANSIT')
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and callingPartyNumber = '14880268588'
--         and eosInfo <> '2'
--         and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
group by callingPartyNumber,timeForStartOfCharge
*/
-- substring(toString(timeForStartOfCharge), 1, 18)  || ' ' || "0", 19) end_date
/*select distinct type from ericsson



type
CALL_FORWARDING
M_S_ORIGINATING
M_S_ORIGINATING_SMS_IN_MSC
M_S_TERMINATING
M_S_TERMINATING_SMS_IN_MSC
ROAMING_CALL_FORWARDING
S_S_PROCEDURE
TRANSIT
*/