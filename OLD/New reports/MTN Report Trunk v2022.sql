

select MTN,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange,DATA
from
(
select  MTN,round(sum(On_Net)/60) On_Net,round(sum(International_Incoming)/60) International_Incoming
        ,round(sum(International_Outgoing)/60) International_Outgoing,round(sum(Orange_To_MTN)/60) Orange_To_MTN
        ,round(sum(MTN_To_Orange)/60) MTN_To_Orange
from (
      select toDate(EventDate) MTN
           , case
                 when originForCharging = '1'
                     and incomingRoute not in
                         ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I',
                          'L1MBC2I',
                          'L2MBC2I', 'CELLCI')
                     and outgoingRoute not in
                         ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO')
                     and length(calledPartyNumber) > 7
                     and length(callingPartyNumber) > 7
                     then toUnixTimestamp(chargeableDuration)
                 else 0 end as On_Net
           , case
                 when originForCharging = '1'
                     and incomingRoute in
                         ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I',
                          'L1MBC2I', 'L2MBC2I')
                     then toUnixTimestamp(chargeableDuration)
                 else 0 end as International_Incoming
           , case
                 when outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
                     then toUnixTimestamp(chargeableDuration)
                 else 0 end as International_Outgoing
           , case
                 when originForCharging = '1'
                     and incomingRoute in ('CELLCI', 'ORGSBCI')
                     then toUnixTimestamp(chargeableDuration)
                 else 0 end as Orange_To_MTN
           , case
                 when outgoingRoute in ('CELLCO', 'ORGSBCO')
                     then toUnixTimestamp(chargeableDuration)
                 else 0 end as MTN_To_Orange
      from mediation.ericsson
      where toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
         )group by MTN
         )any left join

    ------------------------------DATA-----------------------------------------------------------------------------------------------------
(
    select  toDate(recordOpeningTime)                                                          MTN
            ,round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as DATA
    from    mediation.data_ericsson
    where   toYear(recordOpeningTime) = (:year)
        and toMonth(recordOpeningTime) = (:month)
        and ((filePath like '%LIMO%' )
        or  (filePath like '%chsLog%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                                          accessPointNameOI <> 'mnc001.mcc618.gprs')))
    group by MTN
    )using MTN
order by MTN
;
