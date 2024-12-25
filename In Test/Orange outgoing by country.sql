select  CountryName,round(sum(duration)/60,2) duration
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
                and type in ('MO_CALL_RECORD')
                and callDuration > 0
                and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                                                           'Orange-12482', 'BARAK SIP 2',
                                                           'OLIB_SBC_OFR')
            group by CountryCode
         ) using CountryCode
group by CountryName
order by duration desc
/*
--          select substring(calledPartyNumber, 8,1) x--,calledPartyNumber,callingPartyNumber,outgoingRoute,incomingRoute

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
                    ,calledNumber
            from    mediation.zte
            where   toYear(eventTimeStamp) = (:year)
                and toMonth(eventTimeStamp) = (:month)
                and type in ('MO_CALL_RECORD')
                and CountryCode = '999999'
                and callDuration > 0
                and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                                                           'Orange-12482', 'BARAK SIP 2',
                                                           'OLIB_SBC_OFR')
top 500
*/