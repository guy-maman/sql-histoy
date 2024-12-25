

select Orange,round(sum(callDuration)/60) On_Net
from (
      select callReference, toYYYYMMDD(eventTimeStamp) Orange, max(callDuration) callDuration
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 1
        and incomingTKGPName not in ('Comium', 'LoneStar', 'BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2', 'OLIB_SBC_OFR')
        and outgoingTKGPName not in ('Comium', 'LoneStar', 'BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2', 'OLIB_SBC_OFR')
        and length(calledNumber) > 6
      group by Orange,callReference
         )
group by Orange

/***** All Traffic *****/

select Orange,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange,DATA
from
(
select Orange,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange
from
(
select Orange,On_Net,International_Outgoing,International_Incoming
from (
         select toDate(EventDate) MTN, round(sum(toUnixTimestamp(chargeableDuration)) / 60) On_Net
         from ericsson
         where EventDate >= toDateTime(:dateFrom)
           and EventDate <= toDateTime(:dateTo)
           and originForCharging = '1'
           and incomingRoute not in
               ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
                'L2MBC2I', 'CELLCI')
           and outgoingRoute not in
               ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO')
           and length(calledPartyNumber) > 7
           and length(callingPartyNumber) > 7
         group by MTN
         )any left join
---------------------------------------------------INTL-------------------------------------------------------------------------------------------
(
    select MTN, International_Outgoing, International_Incoming
    from (
             select MTN
                  , sum(International_Outgoing) International_Outgoing
             from (
                   select toDate(EventDate)                                MTN,
                          round(sum(toUnixTimestamp(chargeableDuration)) / 60) International_Outgoing
                   from ericsson
                   where EventDate >= toDateTime(:dateFrom)
                     and EventDate < toDateTime(:dateTo)
                     and originForCharging not in ('0')
                     and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
                   group by MTN
                      )GROUP BY MTN
             ) any
             left join
         (
             select toDate(EventDate)                                MTN,
                    round(sum(toUnixTimestamp(chargeableDuration)) / 60) International_Incoming
             from ericsson
             where EventDate >= toDateTime(:dateFrom)
               and EventDate <= toDateTime(:dateTo)
               and originForCharging not in ('0')
               and incomingRoute in
                   ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
                    'L2MBC2I')
             group by MTN
             ) using MTN
    )using MTN
)any left join
----------------------------------------------Off Net-------------------------------------------------------------------------------
(
select MTN, Orange_To_MTN, MTN_To_Orange
from (
         select toDate(EventDate) MTN, round(sum(toUnixTimestamp(chargeableDuration)) / 60) Orange_To_MTN
         from ericsson
         where EventDate >= toDateTime(:dateFrom)
           and EventDate <= toDateTime(:dateTo)
           and originForCharging = '1'
           and incomingRoute = 'CELLCI'
         group by MTN
         ) any
             left join
     (
         select toDate(EventDate) MTN, round(sum(toUnixTimestamp(chargeableDuration)) / 60) MTN_To_Orange
         from ericsson
         where EventDate >= toDateTime(:dateFrom)
           and EventDate <= toDateTime(:dateTo)
           and outgoingRoute = 'CELLCO'
         group by MTN
         ) using MTN
    )using MTN
)any left join
    ------------------------------DATA-----------------------------------------------------------------------------------------------------
(
    select toDate(recordOpeningTime)                                                          MTN
         , round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as DATA
    from data_ericsson
    where recordOpeningTime >= toDateTime(:dateFrom)
      and recordOpeningTime < toDateTime(:dateTo)
      and ((filePath like '%LIMO%' )
        or (filePath like '%chsLog%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                                          accessPointNameOI <> 'mnc001.mcc618.gprs')))
    group by MTN
    )using MTN
order by MTN
;



--------------------------------------------------------end-----------------------------------------------------------------------------------
