
--------------- Orange

select DR_Type,accessPointNameNI
        ,sum(listOfTrafficIn) listOfTrafficIn
        ,sum(listOfTrafficOut) listOfTrafficOut
        ,round(sum(SUM)) SUM
from (
      select case
                 when filePath like '%GGSN%' then 'GGSN'
                 when filePath like '%SGSN%' then 'SGSN'
                 else 'Other' end                 as DR_Type
           , case
                 when accessPointNameOI = 'Roaming'
                     then 'Roaming'
                 else accessPointNameNI
          end                                     as accessPointNameNI
           , case
                 when ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                       accessPointNameOI <> 'mnc007.mcc618.gprs')
                     then 'Roaming'
                 else accessPointNameOI
          end                                     as accessPointNameOI
           , sum(listOfTrafficIn) / 1024 / 1024      listOfTrafficIn
           , sum(listOfTrafficOut) / 1024 / 1024     listOfTrafficOut
           , (listOfTrafficIn + listOfTrafficOut) as SUM
      from data_zte
      where recordOpeningTime >= toDateTime(:from_v)
        and recordOpeningTime < toDateTime(:to_v)
        and ((DR_Type = 'GGSN' and accessPointNameNI in ('web.cellcomnet.net','roducate2','orangetdd','orangelbr','cellcom4g','cellcom'))
                or (DR_Type = 'SGSN' and accessPointNameNI in ('Roaming')))
      group by DR_Type, accessPointNameNI, accessPointNameOI
         )
group by DR_Type,accessPointNameNI
order by SUM desc, accessPointNameNI
;

accessPointNameNI
'web.cellcomnet.net',
'roducate2',
'orangetdd',
'orangelbr',
'cellcom4g',
'cellcom'
'Roaming'


----------------- MTN

select DR_Type,accessPointNameNI
        ,sum(listOfTrafficIn) listOfTrafficIn
        ,sum(listOfTrafficOut) listOfTrafficOut
        ,round(sum(SUM)) SUM
from (
      select case
                 when filePath like '%LIMO%' then 'LIMO'
                 when filePath like '%chsLog%' then 'chsLog'
                 else 'Other' end                 as DR_Type
           , case
                 when accessPointNameOI = 'Roaming'
                     then 'Roaming'
                 else accessPointNameNI
          end                                     as accessPointNameNI
           , case
                 when ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                       accessPointNameOI <> 'mnc001.mcc618.gprs')
                     then 'Roaming'
                 else accessPointNameOI
          end                                     as accessPointNameOI
           , sum(listOfTrafficIn) / 1024 / 1024      listOfTrafficIn
           , sum(listOfTrafficOut) / 1024 / 1024     listOfTrafficOut
           , (listOfTrafficIn + listOfTrafficOut) as SUM
      from data_ericsson
      where recordOpeningTime >= toDateTime(:from_v)
        and recordOpeningTime < toDateTime(:to_v)
      group by DR_Type, accessPointNameNI, accessPointNameOI
         )
group by DR_Type,accessPointNameNI
order by SUM desc, accessPointNameNI
;

select toYYYYMMDD(recordOpeningTime)                                                          MTN
     , round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as DATA
from data_ericsson
where recordOpeningTime >= toDateTime(:from_v)
  and recordOpeningTime < toDateTime(:to_v)
  and ((filePath like '%LIMO%' and accessPointNameNI in
                                   ('internet.novafone.com.lr', 'internetlcc', 'internet'))
    or (filePath like '%chsLog%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                                    accessPointNameOI <> 'mnc001.mcc618.gprs')))
group by MTN


accessPointNameNI
internetlcc
internet
internet.novafone.com.lr


select *
from data_ericsson
where filePath like '%chsLog%'
order by recordOpeningTime
LIMIT 1000;

select *
from data_ericsson
where filePath like '%LIMO%'
order by recordOpeningTime
LIMIT 1000;

select recordOpeningTime,servedMSISDN,servedIMSI,servedIMEI,cellIdentifier,chargingID,listOfRecordSequenceNumber,localSequenceNumber,accessPointNameNI,accessPointNameOI
       , listOfTrafficIn,listOfTrafficOut
from data_zte
where filePath like '%GGSN%'
        and recordOpeningTime >= toDateTime(:from_v)
        and recordOpeningTime < toDateTime(:to_v)
        and filePath = '/home/app/ftp/data_zte/july/GGSN_2019070150217.dat'
--         and chargingID = '1239023935'
order by recordOpeningTime
LIMIT 1000
;

select filePath,recordOpeningTime,servedMSISDN,chargingID,/*listOfRecordSequenceNumber,*/localSequenceNumber,accessPointNameNI--,accessPointNameOI
       , listOfTrafficIn,listOfTrafficOut
;
select localSequenceNumber,count() count
from data_zte
where filePath like '%GGSN%'
        and recordOpeningTime >= toDateTime(:from_v)
        and recordOpeningTime < toDateTime(:to_v)
        and filePath = '/home/app/ftp/data_zte/july/GGSN_2019070150217.dat'
group by localSequenceNumber
order by count desc
-- order by recordOpeningTime,filePath
LIMIT 1000
;

select recordOpeningTime,servedMSISDN,servedIMSI,servedIMEI,cellIdentifier,chargingID,listOfRecordSequenceNumber,localSequenceNumber,accessPointNameNI,accessPointNameOI
       , listOfTrafficIn,listOfTrafficOut
from data_zte
where filePath like '%SGSN%'
        and recordOpeningTime >= toDateTime(:from_v)
        and recordOpeningTime < toDateTime(:to_v)
order by recordOpeningTime
LIMIT 1000
;

-- /home/app/ftp/data_ericsson/20190313/chsLog.2123_000607
-- /home/app/ftp/data2_ericsson/LIMO3PGW01_20190807000022_53786-070819