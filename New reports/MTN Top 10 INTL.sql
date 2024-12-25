
/*
create table mediation.Top10 (DateMonth String,Operator String,CountryName String,Incoming int,Outgoing int)
ENGINE = Memory;
*/
-------------------------MTN----------------------------------------------------------------------------------
insert into mediation.Top10

select  DateMonth,Operator,CountryName,Incoming,Outgoing
from (

         select (:st) DateMonth, 'MTN' Operator, CountryName, round(sum(duration) / 60, 2) Incoming
         from (
                  select CountryName, toString(CountryCode) CountryCode from CountryCodes
                  ) any
                  left join
              (
                  select case
                             when substring(callingPartyNumber, 1, 2) = '14'
                                 then '231'
                             else (case
                                       when substring(callingPartyNumber, 3) like ('1%')
                                           then substring(callingPartyNumber, 3, 4)
                                       else substring(callingPartyNumber, 3, 3) end) end as CountryCode
                       , sum(toUnixTimestamp(chargeableDuration))                           duration
                  from ericsson
                  where toYear(EventDate) = (:year)
                    and toMonth(EventDate) = (:month)
                    and originForCharging = '1'
--            and CountryCode not in ('231')
                    and incomingRoute in
                        ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I',
                         'L1MBC2I', 'L2MBC2I')
                  group by CountryCode
                  ) using CountryCode
         group by DateMonth, Operator, CountryName
         )any left join
(
select  (:st) DateMonth,'MTN' Operator,CountryName,round(sum(duration)/60,2) Outgoing
from (
         select CountryName, toString(CountryCode) CountryCode from CountryCodes
         ) any left join
     (
         select     case when substring(calledPartyNumber, 3,3) = '088' then '231'
                    else (case when substring(calledPartyNumber, 3) like ('1%') then substring(calledPartyNumber, 3, 4)
                    else (case when (substring(calledPartyNumber, 3,3) in ('025','074','095','096') and
                                    substring(calledPartyNumber, 6,3) = '001') then substring(calledPartyNumber, 8, 4)
                    else (case when (substring(calledPartyNumber, 3,3) in ('025','074','095','096') and
                                    substring(calledPartyNumber, 6,3) <> '001') then substring(calledPartyNumber, 8, 3)
                    else (case when substring(calledPartyNumber, 3,3) = '001' then substring(calledPartyNumber, 5, 4)
                    else (case when (substring(calledPartyNumber, 3,3) like '00%' and
                                    substring(calledPartyNumber, 3,3) not like '001') then substring(calledPartyNumber, 5, 3)
                    else substring(calledPartyNumber, 3, 3)
                        end) end) end) end) end) end as CountryCode
              , sum(toUnixTimestamp(chargeableDuration))   duration
         from ericsson
         where toYear(EventDate) = (:year)
           and toMonth(EventDate) = (:month)
--            and CountryCode not in ('231')
           and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
         group by CountryCode
         ) using CountryCode
group by DateMonth,Operator,CountryName
)using CountryName

-----------------------------ORANGE-----------------------------------------------------------------------
