
/***** All Traffic *****/

select  Orange,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange,DATA
from (
    select Orange, On_Net, International_Incoming, International_Outgoing, MTN_To_Orange, Orange_To_MTN
    from (
             select Orange, On_Net, International_Incoming, International_Outgoing
             from (
             select Orange, On_Net
             from (
                   select toDate(Orange) Orange, sum(Minutes) On_Net
                   from report
                   where Destination = 'On Net'
                   group by Destination, Orange order by Orange
                      )group by Orange, On_Net
                      ) any
                      left join
                  -------------------------------------------------------------------------------------------------------------------------------------------------
                      (
                          select Orange, International_Incoming, International_Outgoing
                          from (
                          select Orange, International_Incoming
                          from (
                                select toDate(Orange) Orange, sum(Minutes) International_Incoming
                                from report
                                where Destination = 'International_Incoming'
                                group by Destination, Orange
                                   )group by Orange, International_Incoming
                                   ) any
                                   left join
                               (
                          select Orange, International_Outgoing
                          from (
                                select toDate(Orange) Orange, sum(Minutes) International_Outgoing
                                from report
                                where Destination = 'International_Outgoing'
                                group by Destination, Orange
                                   )group by Orange, International_Outgoing
                                   ) using Orange
                          ) using Orange
             ) any
             left join
         ----------------------------------------------------------------------------------------------------------------------------------------------
             (
                 select Orange, MTN_To_Orange, Orange_To_MTN
                 from (
                          select Orange, MTN_To_Orange
                          from (
                                select toDate(Orange) Orange, sum(Minutes) MTN_To_Orange
                                from report
                                where Destination = 'MTN_To_Orange'
                                group by Destination, Orange
                                   )group by Orange, MTN_To_Orange
                          ) any
                          left join
                      (
                          select Orange, Orange_To_MTN
                          from (
                                select toDate(Orange) Orange, sum(Minutes) Orange_To_MTN
                                from report
                                where Destination = 'Orange_To_MTN'
                                group by Destination, Orange
                                   )group by Orange, Orange_To_MTN
                          ) using Orange
                 ) using Orange
    )any left join
----------------------------------------------------------------------------------------------------------------------------------------------------------------
    (
        select toDate(recordOpeningTime)                                                          Orange
             , round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as DATA
        from data_zte
        where toYear(recordOpeningTime) = (:year)
        and toMonth(recordOpeningTime) = (:month)
          and ((filePath like '%GGSN%' and accessPointNameNI in
                                           ('web.cellcomnet.net', /*'roducate2', 'orangetdd',*/ 'orangelbr', 'cellcom4g',
                                            'cellcom'))
            or (filePath like '%SGSN%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                                            accessPointNameOI <> 'mnc007.mcc618.gprs')))
        group by Orange
        )using Orange
order by Orange
;
-------------------------END---------------------------------------------------------------------------------------------------

