
-- create table mediation.Top10 (Date DateTime,Operator String,Direction String,CountryName String,callDuration Nullable(Int32))
-- ENGINE = Memory;
--(86400*59)
---------------------ORANGE------------------------------------------------------
-----Insert------------------

insert into mediation.Top10

select  toDate(now() - (86400*30)) Date,'ORANGE' Operator,'Incoming' Direction,CountryName
        ,round(sum(duration) / 60, 2) callDuration
from (
       select CountryName, toString(CountryCode) CountryCode from CountryCodes
    ) any left join
(
       select  case when (substring(callingNumber,1,4) = '1900' and
                          substring(callingNumber,3) like '001%') then substring(callingNumber,5,4)
               else (case when (substring(callingNumber,1,4) = '1900' and
                                substring(callingNumber,3) not like '001%') then substring(callingNumber,5,3)
               else (case when (substring(callingNumber,1,2) = '19' and
                                substring(callingNumber,3) like '1%') then substring(callingNumber,3,4)
               else (case when (substring(callingNumber,1,2) = '19' and
                                substring(callingNumber,3,1) in ('2','3','4','5','6','7','8','9')) then substring(callingNumber,3,3)
               else (case when (substring(callingNumber,1,6) in ('113800','113A00') and
                                substring(callingNumber,5) like ('001%')) then substring(callingNumber,7,4)
               else (case when (substring(callingNumber,1,6) in ('113800','113A00') and
                                substring(callingNumber,5) not like ('001%')) then substring(callingNumber,7,3)
               else (case when (substring(callingNumber,1,2) = '11' and
                                substring(callingNumber,5) like ('1%')) then substring(callingNumber,5,4)
               else (case when (substring(callingNumber,1,2) = '11' and
                                substring(callingNumber,5,1) in ('2','3','4','5','6','7','8','9')) then substring(callingNumber,5,3)
               else '999999' end) end) end) end) end) end) end) end as CountryCode
               ,sum(callDuration) duration
       from    mediation.zte
       where   toYear(eventTimeStamp) = (:year)
           and toMonth(eventTimeStamp) = (:month)
           and CountryCode not in ('231')
           and type in ('MT_CALL_RECORD')
           and callDuration > 0
           and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                                                      'Orange-12482', 'BARAK SIP 2',
                                                      'OLIB_SBC_OFR')
       group by CountryCode
    ) using CountryCode
group by CountryName;

insert into mediation.Top10

select toDate(now() - (86400*30)) Date,'ORANGE' Operator,'Outgoing' Direction,CountryName
        ,round(sum(duration) / 60, 2) callDuration
from (
       select CountryName, toString(CountryCode) CountryCode from CountryCodes
    ) any left join
(
       select  case       when  length(calledNumber) < 7 then '999999'
               else (case when (substring(calledNumber,1,2) = '18' and
                                substring(calledNumber,3,2) in ('07','77')) then '231'
               else (case when (substring(calledNumber,1,4) = '1800' and
                                substring(calledNumber,3) like '001%') then substring(calledNumber,5,4)
               else (case when (substring(calledNumber,1,4) = '1800' and
                                substring(calledNumber,3) not like '001%') then substring(calledNumber,5,3)
               else (case when (substring(calledNumber,1,2) = '19' and
                                substring(calledNumber,3,2) in ('07')) then '231'
               else (case when (substring(calledNumber,1,2) = '19' and
                                substring(calledNumber,3) like '1%') then substring(calledNumber,3,4)
               else (case when (substring(calledNumber,1,2) = '19' and
                                substring(calledNumber,3,1) in ('2','3','4','5','6','7','8','9')) then substring(calledNumber,3,3)
               else (case when (substring(calledNumber,1,4) = '1900' and
                                substring(calledNumber,3) like ('001%')) then substring(calledNumber,5,4)
               else (case when (substring(calledNumber,1,4) in '1900' and
                                substring(calledNumber,3) not like ('001%')) then substring(calledNumber,5,3)
               else '999999' end) end) end) end) end) end) end) end) end as CountryCode
               ,sum(callDuration) duration
       from    mediation.zte
       where   toYear(eventTimeStamp) = (:year)
           and toMonth(eventTimeStamp) = (:month)
           and CountryCode not in ('231')
           and type in ('MO_CALL_RECORD')
           and callDuration > 0
           and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                                                      'Orange-12482', 'BARAK SIP 2',
                                                      'OLIB_SBC_OFR')
       group by CountryCode
    ) using CountryCode
group by CountryName;

--------------------MTN-----------------------------------------------------------------------------

insert into mediation.Top10

select toDate(now() - (86400*30)) Date,'MTN' Operator,'Incoming' Direction,CountryName
        ,round(sum(duration) / 60, 2) callDuration
from (
         select CountryName, toString(CountryCode) CountryCode from CountryCodes
         ) any
         left join
     (
         select case when substring(callingPartyNumber, 1, 2) = '14'
                        then '231'
                    else (case when substring(callingPartyNumber, 3) like ('1%')
                                  then substring(callingPartyNumber, 3, 4)
                              else substring(callingPartyNumber, 3, 3) end) end as CountryCode
              , sum(toUnixTimestamp(chargeableDuration))                           duration
         from   ericsson
         where  toYear(EventDate) = (:year)
            and toMonth(EventDate) = (:month)
            and originForCharging = '1'
            and CountryCode not in ('231')
            and incomingRoute in
               ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I',
                'L1MBC2I', 'L2MBC2I')
         group by CountryCode
         ) using CountryCode
group by Date, Operator, CountryName

insert into mediation.Top10

select  toDate(now() - (86400*30)) Date,'MTN' Operator,'Outgoing' Direction,CountryName
        ,round(sum(duration)/60,2) callDuration
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
group by Date,Operator,CountryName

-----------------------------------------------------------------------------------------------------------------
--------Print-------------------------

select Operator,Direction,CountryName,callDuration
from (
      select Top 10 1 ind, Operator, Direction, CountryName, sum(callDuration) callDuration
      from Top10
      where toYear(Date) = (:year)
        and toMonth(Date) = (:month)
        and CountryName not in ('Liberia')
        and Operator = 'ORANGE'
        and Direction = 'Incoming'
      group by Operator, Direction, CountryName
      order by callDuration desc
      union all
      select Top 10 2 ind, Operator, Direction, CountryName, sum(callDuration) callDuration
      from Top10
      where toYear(Date) = (:year)
        and toMonth(Date) = (:month)
        and CountryName not in ('Liberia')
        and Operator = 'MTN'
        and Direction = 'Incoming'
      group by Operator, Direction, CountryName
      order by callDuration desc
      union all
      select Top 10 3 ind, 'Merged' Operator, Direction, CountryName, sum(callDuration) callDuration
      from Top10
      where toYear(Date) = (:year)
        and toMonth(Date) = (:month)
        and CountryName not in ('Liberia')
--     and Operator = 'MTN'
        and Direction = 'Incoming'
      group by Operator, Direction, CountryName
      order by callDuration desc
      union all
      select Top 10 4 ind, Operator, Direction, CountryName, sum(callDuration) callDuration
      from Top10
      where toYear(Date) = (:year)
        and toMonth(Date) = (:month)
        and CountryName not in ('Liberia')
        and Operator = 'ORANGE'
        and Direction = 'Outgoing'
      group by Operator, Direction, CountryName
      order by callDuration desc
      union all
      select Top 10 5 ind, Operator, Direction, CountryName, sum(callDuration) callDuration
      from Top10
      where toYear(Date) = (:year)
        and toMonth(Date) = (:month)
        and CountryName not in ('Liberia')
        and Operator = 'MTN'
        and Direction = 'Outgoing'
      group by Operator, Direction, CountryName
      order by callDuration desc
      union all
      select Top 10 6 ind, 'Merged' Operator, Direction, CountryName, sum(callDuration) callDuration
      from Top10
      where toYear(Date) = (:year)
        and toMonth(Date) = (:month)
        and CountryName not in ('Liberia')
--     and Operator = 'ORANGE'
        and Direction = 'Outgoing'
      group by Operator, Direction, CountryName
      order by callDuration desc
         )
order by ind,callDuration desc;

-- select * from Top10