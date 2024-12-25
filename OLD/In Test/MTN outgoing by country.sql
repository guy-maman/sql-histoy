select  CountryName,round(sum(duration)/60,2) duration
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
           and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
         group by CountryCode
         ) using CountryCode
group by CountryName
order by duration desc
/*
--          select substring(calledPartyNumber, 8,1) x--,calledPartyNumber,callingPartyNumber,outgoingRoute,incomingRoute

         select    round(sum(toUnixTimestamp(chargeableDuration))/60) dur,--calledPartyNumber,
                    case when substring(calledPartyNumber, 3,3) = '088' then '231'
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
--                 ,callingPartyNumber,outgoingRoute,incomingRoute,terminatingLocationNumber,mscAddress,destinationAddress
         from ericsson
         where toYear(EventDate) = (:year)
           and toMonth(EventDate) = (:month)
           and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
--            and CountryCode = '001'
--            and substring(calledPartyNumber, 1, 2) = '12'
--            and substring(calledPartyNumber, 1, 5) in ('12096','12074','12025','12095')
         group by CountryCode*/