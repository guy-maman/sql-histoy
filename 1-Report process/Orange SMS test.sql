
select /*distinct errorCode*/ top 100 * --eventTimeStamp,deliveryTime,callReference,servedMSISDN,smsLength,originationNumber,errorCode
from mediation.zte
where toYYYYMM(eventTimeStamp) = 202411
    and type in ('MT_SMS_RECORD')
order by eventTimeStamp desc

--and ussdServiceCode = '0'
;

MT_SMS_RECORD
MO_SMS_RECORD
USSD_RECORD

select top 10 * --distinct direction
from mediation.vas_statistics
;

select 'orange' operator,toStartOfHour(eventTimeStamp) timestamp,'SMS' type1,'MT' direction,originationNumber shortcode,count() row_count
from mediation.zte
where toYYYYMM(eventTimeStamp) = 202411
    and type in ('MT_SMS_RECORD')
    and shortcode not like '19231%'
group by timestamp,shortcode
order by timestamp desc;

select serviceCentre sc,
    'orange'                                                                                                 operator,
    toStartOfMonth(eventTimeStamp)                                                                            timestamp,
    'SMS'                                                                                                    typett,
    'MT'                                                                                                     direction,
    if(match(originationNumber, '[A-Za-z]') > 0, zte.originationNumber, substr(zte.originationNumber, 2)) as shortcode,
    count()                                                                                                  row_count
from mediation.zte
where
    zte.type = 'MT_SMS_RECORD'
--   and toYYYYMMDD(eventTimeStamp) = '20241019'
  and eventTimeStamp > '2024-11-19 13:57:00'
  and (match(originationNumber, '[A-Za-z]') > 0 or length(originationNumber) < 7)
group by timestamp, shortcode,sc
order by row_count desc;