
/*type
CALL_FORWARDING
M_S_ORIGINATING
M_S_ORIGINATING_SMS_IN_MSC
M_S_TERMINATING
M_S_TERMINATING_SMS_IN_MSC
ROAMING_CALL_FORWARDING
S_S_PROCEDURE
TRANSIT
*/
------------------------------------------------Inbound-----------------------------

-- create table MTNInbound_2019 (Month String,Country String,CountryCode String,NetworkCode String, OperatorName String,Inbound_MOC int,Inbound_MTC int) ENGINE = Memory;
--drop table MTNInbound_2019
/*
select * --Month,Country,sum(Inbound_MOC)/60 Inbound_MOC,sum(Inbound_MTC)/60 Inbound_MTC
from MTNInbound_2019
group by Month,Country
order by Month,Country;
select Country,OperatorName from MTNInbound_2019 group by Country,OperatorName;

*/
insert into MTNInbound_2019

select Month,
       Country,
       CountryCode,
       NetworkCode,
       OperatorName,
       Inbound_MOC,
       Inbound_MTC
from (

         select Month, NetworkCode, sum(Inbound_MOC) Inbound_MOC, sum(Inbound_MTC) Inbound_MTC
         from (
               select toMonth(EventDate)     Month,
                      case
                          when type = ('M_S_ORIGINATING')
                              then substring(callingSubscriberIMSI, 1, 5)
                          when type in ('M_S_TERMINATING')
                              then substring(calledSubscriberIMSI, 1, 5)
                          else '0' end as           NetworkCode,
                      case
                          when type = ('M_S_ORIGINATING') and (callingSubscriberIMSI not like ('61801%') and callingSubscriberIMSI not like ('61804%'))
                              then sum(toUnixTimestamp(chargeableDuration))
                          else 0 end as           Inbound_MOC,
                      case
                          when type = ('M_S_TERMINATING') and (calledSubscriberIMSI not like ('61801%') and calledSubscriberIMSI not like ('61804%') and calledSubscriberIMSI not like (''))
                              then sum(toUnixTimestamp(chargeableDuration))
                          else 0 end as           Inbound_MTC
               from ericsson
               where type in ('M_S_TERMINATING', 'M_S_ORIGINATING')
--                  and servedIMSI not like ('61807%')
                 and toYear(EventDate) = (:year)
                 and toMonth(EventDate) between (:month) and (:monthEND)
               group by Month, NetworkCode, type,callingSubscriberIMSI,calledSubscriberIMSI
                  )
         group by Month, NetworkCode
         ) any
         left join
     (

        select Country, NetworkCode, CountryCode, OperatorName from CountryOperatorsCode

         ) using NetworkCode
where Country <> ''
order by Month, Country
;

------------------------------------------Outbound----------------------------

create table MTNOutbound_2019 (Month String,Country String,CountryCode String/*, Outbound_MOC int*/,Outbound_MTC int) ENGINE = Memory;

insert into MTNOutbound_2019

select Month,
       Country,
       CountryCode,
--        Outbound_MOC,
       Outbound_MTC
from (
         select Month, CountryCode, sum(Outbound_MTC) Outbound_MTC
         from (
               select toMonth(EventDate)        Month,
                      substring(mobileStationRoamingNumber, 3, 3) CountryCode,
                      sum(toUnixTimestamp(chargeableDuration))              Outbound_MTC
               from  ericsson
               where toYear(EventDate) = (:year)
                 and toMonth(EventDate) between (:month) and (:monthEND)
               group by Month, CountryCode
                  )group by  CountryCode,Month --order by Month, CountryCode
         ) any
         left join
     (
         select Country, /*NetworkCode,*/ CountryCode from CountryOperatorsCode group by Country, /*NetworkCode,*/ CountryCode

         )using CountryCode
where Country <> ''
group by Country, CountryCode,Month,Outbound_MTC
order by Month, Country





/*

select  toMonth(EventDate) Month,substring(callingSubscriberIMSI) NetworkCode,toUnixTimestamp(chargeableDuration) Inbound_MOC
from    ericsson
where   type in ('M_S_ORIGINATING')
        and (callingSubscriberIMSI not like ('61801%') and callingSubscriberIMSI not like ('61804%'))
        and toYear(EventDate) = (:year)
--         and toMonth(EventDate) = (:month)

;

select  type,callingPartyNumber,callingSubscriberIMSI,calledPartyNumber,calledSubscriberIMSI,mobileStationRoamingNumber,mscAddress
from    ericsson
where   type in ('M_S_TERMINATING')
        and (calledSubscriberIMSI not like ('61801%') and calledSubscriberIMSI not like ('61804%') and calledSubscriberIMSI not like (''))
--         and callingPartyNumber like ('11231%')
        and toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
limit 500;

---------------------------------------------------------------

select  type,callingPartyNumber,callingSubscriberIMSI,calledPartyNumber,calledSubscriberIMSI,mobileStationRoamingNumber,mscAddress
from    ericsson
where   /*type in ('M_S_ORIGINATING')
        and */(mobileStationRoamingNumber not like ('11231%') and mobileStationRoamingNumber not like (''))
        and toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
limit 500;

select  type,callingPartyNumber,callingSubscriberIMSI,calledPartyNumber,calledSubscriberIMSI,mobileStationRoamingNumber,mscAddress
from    ericsson
where   /*type in ('M_S_TERMINATING')
        and */(mscAddress not like ('') and mscAddress not like ('11231%'))
        and callingPartyNumber like ('11231%')
--         and (callingSubscriberIMSI  like ('61801%') or callingSubscriberIMSI  like ('61804%'))
        and toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
limit 500;


 */