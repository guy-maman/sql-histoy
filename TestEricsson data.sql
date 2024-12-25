
select  toStartOfHour(recordOpeningTime)  Date
        ,round(sum(listOfTrafficIn + listOfTrafficOut) / 1024 / 1024) as DATA
from    mediation.data_ericsson
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
--     and toDayOfMonth(recordOpeningTime) = (:day)
    and (listOfTrafficIn <> 0 or listOfTrafficOut <> 0)
    and accessPointNameOI <> 'mnc001.mcc618.gprs'
group by Date
order by Date;


select  toDate(ts) ts
        ,round(sum(down + up) / 1024 / 1024) as DATA
from    mediation.data_ericsson_traffic_summary
where   toYear(ts) = (:year)
    and toMonth(ts) = (:month)
--     and toDayOfMonth(ts) = (:day)
group by ts
order by ts;