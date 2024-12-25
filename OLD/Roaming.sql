
--------------------- MTN Roaming

create table CountryCode (Direction String,CountryCode String) ENGINE = Memory;

insert into CountryCode
values ('Incoming','221'),('Incoming','224'),('Incoming','225'),('Incoming','228'),('Incoming','229'),('Incoming','232')
        ,('Outgoing','221'),('Outgoing','224'),('Outgoing','225'),('Outgoing','228'),('Outgoing','229'),('Outgoing','232')
        ,('Incoming','Other'),('Incoming','Unknown All'),('Outgoing','Other'),('Outgoing','Unknown All')
;

select  Direction,CountryCode,Inbound,Outbound
from (
      select Direction,
             CountryCode,
             Inbound--,Outbound
      from (

               select Direction, CountryCode from CountryCode

               ) any
               left join
           (
               select case
                          when substring(mscAddress, 3, 3) in ('221', '224', '225', '228', '229', '232')
                              then substring(mscAddress, 3, 3)
                          else 'Other' end                                 CountryCode,
                      'Incoming'                                           Direction,
                      round(sum(toUnixTimestamp(chargeableDuration)) / 60) Inbound
               from ericsson
               where type in
                     ('M_S_ORIGINATING', 'M_S_TERMINATING', 'TRANSIT', 'ROAMING_CALL_FORWARDING', 'CALL_FORWARDING')
                 and EventDate >= toDateTime(:from_v)
                 and EventDate < toDateTime(:to_v)
                 and ((mobileStationRoamingNumber not like '' and mobileStationRoamingNumber not like '112318%')
                   or (mscAddress not like '' and mscAddress not like '112318%'))
               group by CountryCode
               union all
               select case
                          when substring(callingPartyNumber, 3, 3) in ('221', '224', '225', '228', '229', '232')
                              then substring(callingPartyNumber, 3, 3)
                          else 'Other' end                                 CountryCode
                    , 'Outgoing'                                           Direction
                    , round(sum(toUnixTimestamp(chargeableDuration)) / 60) Inbound
               from ericsson
               where type in ('ROAMING_CALL_FORWARDING')
                 and EventDate >= toDateTime(:from_v)
                 and EventDate < toDateTime(:to_v)
                 and callingPartyNumber like '11%'
                 and callingPartyNumber not like '11231%'
                 and incomingRoute not in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
               group by CountryCode, Direction
               ) using CountryCode, Direction
         )any
            left join
(
    select Direction, CountryCode, Outbound
    from (
          select case
                     when substring(mobileStationRoamingNumber, 3, 3) in
                          ('221', '224', '225', '228', '229', '232')
                         then substring(mobileStationRoamingNumber, 3, 3)
                     else 'Other' end                                 CountryCode,
                 'Incoming'                                           Direction,
                 round(sum(toUnixTimestamp(chargeableDuration)) / 60) Outbound
          from ericsson
          where type in
                ('M_S_ORIGINATING', 'M_S_TERMINATING', 'TRANSIT', 'ROAMING_CALL_FORWARDING',
                 'CALL_FORWARDING')
            and EventDate >= toDateTime(:from_v)
            and EventDate < toDateTime(:to_v)
            and ((mobileStationRoamingNumber not like '' and
                  mobileStationRoamingNumber not like '112318%')
              or (mscAddress not like '' and mscAddress not like '112318%'))
          group by CountryCode
          union all
          select case
                     when substring(callingPartyNumber, 3, 3) = '000'
                         then substring(mobileStationRoamingNumber, 3, 3)
                     else 'Unknown All' end                           CountryCode
               , 'Outgoing'                                           Direction
               , round(sum(toUnixTimestamp(chargeableDuration)) / 60) Outbound
          from ericsson
          where type in ('ROAMING_CALL_FORWARDING')
            and EventDate >= toDateTime(:from_v)
            and EventDate < toDateTime(:to_v)
            and (callingPartyNumber like '14%'
              or callingPartyNumber like '11231%')
            and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
          group by CountryCode
             )
    ) using  CountryCode,Direction
order by CountryCode,Direction
;
----------------- Oramge Roaming


select  CountryCode,round(sum(callDuration)/60) callDuration
from (
      select substring(callingNumber, 5)                  callingNumber
           , substring(servedMSISDN, 3)                   calledNumber
           , substring(roamingNumber, 5)                  roamingNumber
           , substring(roamingNumber, 1,3)                CountryCode
           , answerTime
           , callDuration
      from zte
      where type in ('ROAM_RECORD')
--         and outgoingTKGPName in
--              ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and CountryCode in ('221','224','225','228','229','232')
         )group by CountryCode;


--------------------- MTN Roaming

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







select  distinct substring(roamingNumber,1,4)
from    zte
where type in ('ROAM_RECORD')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
;

-------------------------------------------------------------------------------------------------------------------------------------
--------------------MTN Test-----------------------------------------


--------------------- MTN Roaming

create table CountryCode (Direction String,CountryCode String) ENGINE = Memory;

insert into CountryCode
values ('Incoming','221'),('Incoming','224'),('Incoming','225'),('Incoming','228'),('Incoming','229'),('Incoming','232')
        ,('Outgoing','221'),('Outgoing','224'),('Outgoing','225'),('Outgoing','228'),('Outgoing','229'),('Outgoing','232')
        ,('Incoming','Other'),('Incoming','Unknown All'),('Outgoing','Other'),('Outgoing','Unknown All')
;

select  Direction,CountryCode,Inbound,Outbound
from (
      select Direction,
             CountryCode,
             Inbound--,Outbound
      from (

               select Direction, CountryCode from CountryCode

               ) any
               left join
           (
               select case
                          when substring(mscAddress, 3, 3) in ('221', '224', '225', '228', '229', '232')
                              then substring(mscAddress, 3, 3)
                          else 'Other' end                                 CountryCode,
                      substring(case  when callingPartyNumber like '1100%' then substring(callingPartyNumber,5)
                        when substring(callingPartyNumber,1,4) in ('1455','1477','1488') then '231' || '' || substring(callingPartyNumber,3)
                        else substring(callingPartyNumber,3)
                        end,1,3) as calling_Number,
                      'Incoming'                                           Direction,
                      round(sum(toUnixTimestamp(chargeableDuration)) / 60) Inbound
               from ericsson
               where type in
                     ('M_S_ORIGINATING', 'M_S_TERMINATING', 'TRANSIT', 'ROAMING_CALL_FORWARDING', 'CALL_FORWARDING')
                 and EventDate >= toDateTime(:from_v)
                 and EventDate < toDateTime(:to_v)
                 and ((mobileStationRoamingNumber not like '' and mobileStationRoamingNumber not like '112318%')
                   or (mscAddress not like '' and mscAddress not like '112318%'))
               group by CountryCode,calling_Number
               union all
               select case
                          when substring(callingPartyNumber, 3, 3) in ('221', '224', '225', '228', '229', '232')
                              then substring(callingPartyNumber, 3, 3)
                          else 'Other' end                                 CountryCode
                    , 'Outgoing'                                           Direction
                    , round(sum(toUnixTimestamp(chargeableDuration)) / 60) Inbound
               from ericsson
               where type in ('ROAMING_CALL_FORWARDING')
                 and EventDate >= toDateTime(:from_v)
                 and EventDate < toDateTime(:to_v)
                 and callingPartyNumber like '11%'
                 and callingPartyNumber not like '11231%'
                 and incomingRoute not in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
               group by CountryCode, Direction
               ) using CountryCode, Direction
         )any
            left join
(
    select Direction, CountryCode, Outbound
    from (
          select case
                     when substring(mobileStationRoamingNumber, 3, 3) in
                          ('221', '224', '225', '228', '229', '232')
                         then substring(mobileStationRoamingNumber, 3, 3)
                     else 'Other' end                                 CountryCode,
                 substring(case  when callingPartyNumber like '1100%' then substring(callingPartyNumber,5)
                        when substring(callingPartyNumber,1,4) in ('1455','1477','1488') then '231' || '' || substring(callingPartyNumber,3)
                        else substring(callingPartyNumber,3)
                        end,1,3) as calling_Number,
                 'Incoming'                                           Direction,
                 round(sum(toUnixTimestamp(chargeableDuration)) / 60) Outbound
          from ericsson
          where type in
                ('M_S_ORIGINATING', 'M_S_TERMINATING', 'TRANSIT', 'ROAMING_CALL_FORWARDING',
                 'CALL_FORWARDING')
            and EventDate >= toDateTime(:from_v)
            and EventDate < toDateTime(:to_v)
            and ((mobileStationRoamingNumber not like '' and
                  mobileStationRoamingNumber not like '112318%')
              or (mscAddress not like '' and mscAddress not like '112318%'))
          group by CountryCode,calling_Number
          union all
          select case
                     when substring(callingPartyNumber, 3, 3) = '000'
                         then substring(mobileStationRoamingNumber, 3, 3)
                     else 'Unknown All' end                           CountryCode
               , 'Outgoing'                                           Direction
               , round(sum(toUnixTimestamp(chargeableDuration)) / 60) Outbound
          from ericsson
          where type in ('ROAMING_CALL_FORWARDING')
            and EventDate >= toDateTime(:from_v)
            and EventDate < toDateTime(:to_v)
            and (callingPartyNumber like '14%'
              or callingPartyNumber like '11231%')
            and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
          group by CountryCode
             )
    ) using  CountryCode,Direction
order by CountryCode,Direction
;


select /*callIdentificationNumber,relatedCallNumber,type
     ,dateForStartOfCharge,timeForStartOfCharge*/
     toDateTime(substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12)) start_date
     ,toUnixTimestamp(chargeableDuration) chargeableDuration
     ,type
     ,case   when callingPartyNumber like '1100%' then substring(callingPartyNumber,5)
             when substring(callingPartyNumber,1,4) in ('1455','1477','1488') then '231' || '' || substring(callingPartyNumber,3)
             else substring(callingPartyNumber,3)
             end as calling_Number
     ,case   when substring(calledPartyNumber,3,3) like '00%' then substring(calledPartyNumber,5)
             when substring(calledPartyNumber,3,3) in ('055','077','088') then '231' || '' || substring(calledPartyNumber,4)
             when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) like '00%'
                 then substring(calledPartyNumber,8)
             when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) in ('055','077','088')
                 then '231' || '' || substring(calledPartyNumber,7)
             when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) not like '0%'
                 then substring(calledPartyNumber,6)
             else substring(calledPartyNumber,3)
             end as called_Number
     ,callingPartyNumber
--      ,callingSubscriberIMSI
     ,calledPartyNumber
--      ,calledSubscriberIMSI
     ,mobileStationRoamingNumber
--      ,chargedParty
--      ,originForCharging
--      ,mscIdentification
     ,mscAddress
--      ,switchIdentity
     ,translatedNumber
--      ,eosInfo
     ,outgoingRoute
     ,incomingRoute
-- select round(sum(toUnixTimestamp(chargeableDuration) ) / 60) chargeableDuration
from ericsson
where EventDate >= toDateTime(:from_v)
      and EventDate < toDateTime(:to_v)
--       and mscAddress <> ''
--       and mscAddress not like '11231%'
      and type in ('M_S_ORIGINATING')
--       and mobileStationRoamingNumber <> ''
--       and mobileStationRoamingNumber not like '11231%'
      and calling_Number not like '231%'
--       and substring(mobileStationRoamingNumber,3,3) like ('233')
--       and incomingRoute in
--             ('ZURI', 'Z ('')UR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
--                     'L2MBC2I')
order by dateForStartOfCharge,timeForStartOfCharge,callingPartyNumber
limit 500;

------------------outbound incoming calls-----------------------------

select  substring(case  when callingPartyNumber like '1100%' then substring(callingPartyNumber,5)
                        when substring(callingPartyNumber,1,4) in ('1455','1477','1488') then '231' || '' || substring(callingPartyNumber,3)
                        else substring(callingPartyNumber,3)
                        end,1,3) as calling_Number
        ,substring(mobileStationRoamingNumber,3,3) Called_Number
    ,round(sum(toUnixTimestamp(chargeableDuration)) / 60) OutboundIncomingcalls
from ericsson
where EventDate >= toDateTime(:from_v)
      and EventDate < toDateTime(:to_v)
      and mobileStationRoamingNumber <> ''
      and mobileStationRoamingNumber not like '11231%'
group by calling_Number,Called_Number
;

-------------------------Inbound outgoing-----------------------------------------

select  substring(case  when callingPartyNumber like '1100%' then substring(callingPartyNumber,5)
                        when substring(callingPartyNumber,1,4) in ('1455','1477','1488') then '231' || '' || substring(callingPartyNumber,3)
                        else substring(callingPartyNumber,3)
                        end,1,3) as calling_Number
        ,substring(case   when substring(calledPartyNumber,3,3) like '00%' then substring(calledPartyNumber,5)
                         when substring(calledPartyNumber,3,3) in ('055','077','088') then '231' || '' || substring(calledPartyNumber,4)
                         when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) like '00%'
                             then substring(calledPartyNumber,8)
                         when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) in ('055','077','088')
                             then '231' || '' || substring(calledPartyNumber,7)
                         when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) not like '0%'
                             then substring(calledPartyNumber,6)
                         else substring(calledPartyNumber,3)
                         end,1,3) Called_Number
    ,round(sum(toUnixTimestamp(chargeableDuration)) / 60) OutboundIncomingcalls
from ericsson
where EventDate >= toDateTime(:from_v)
      and EventDate < toDateTime(:to_v)
      and type in ('M_S_ORIGINATING')
      and calling_Number not like '231%'
--       and mobileStationRoamingNumber <> ''
--       and mobileStationRoamingNumber not like '11231%'
group by calling_Number,Called_Number


type
CALL_FORWARDING
M_S_ORIGINATING
M_S_ORIGINATING_SMS_IN_MSC
M_S_TERMINATING
M_S_TERMINATING_SMS_IN_MSC
ROAMING_CALL_FORWARDING
S_S_PROCEDURE
TRANSIT



