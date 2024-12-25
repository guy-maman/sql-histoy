/***** All Traffic *****/

select MTN,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange,DATA
from
(
select MTN,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange
from
(
select MTN,On_Net,International_Outgoing,International_Incoming
from (
         select toDate(EventDate) MTN, round(sum(toUnixTimestamp(chargeableDuration)) / 60) On_Net
         from mediation.ericsson
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
--            and substring(filepath,24,23) not in ('VTF17345_20210221233043','VTF17504_20210222074800','VTF17508_20210222075049')
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
                   from mediation.ericsson
                   where EventDate >= toDateTime(:dateFrom)
                     and EventDate < toDateTime(:dateTo)
                     and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
--                    and substring(filepath,24,23) not in ('VTF17345_20210221233043','VTF17504_20210222074800','VTF17508_20210222075049')
                   group by MTN
                      )GROUP BY MTN
             ) any
             left join
         (
             select toDate(EventDate)                                MTN,
                    round(sum(toUnixTimestamp(chargeableDuration)) / 60) International_Incoming
             from mediation.ericsson
             where EventDate >= toDateTime(:dateFrom)
               and EventDate <= toDateTime(:dateTo)
               and originForCharging = '1'
               and incomingRoute in
                   ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
                    'L2MBC2I')
--              and substring(filepath,24,23) not in ('VTF17345_20210221233043','VTF17504_20210222074800','VTF17508_20210222075049')
             group by MTN
             ) using MTN
    )using MTN
)any left join
----------------------------------------------Off Net-------------------------------------------------------------------------------
(
select MTN, Orange_To_MTN, MTN_To_Orange
from (
         select toDate(EventDate) MTN, round(sum(toUnixTimestamp(chargeableDuration)) / 60) Orange_To_MTN
         from mediation.ericsson
         where EventDate >= toDateTime(:dateFrom)
           and EventDate <= toDateTime(:dateTo)
           and originForCharging = '1'
           and incomingRoute in ('CELLCI','ORGSBCI')
--          and substring(filepath,24,23) not in ('VTF17345_20210221233043','VTF17504_20210222074800','VTF17508_20210222075049')
         group by MTN
         ) any
             left join
     (
         select toDate(EventDate) MTN, round(sum(toUnixTimestamp(chargeableDuration)) / 60) MTN_To_Orange
         from mediation.ericsson
         where EventDate >= toDateTime(:dateFrom)
           and EventDate <= toDateTime(:dateTo)
           and outgoingRoute in ('CELLCO','ORGSBCO')
--          and substring(filepath,24,23) not in ('VTF17345_20210221233043','VTF17504_20210222074800','VTF17508_20210222075049')
         group by MTN
         ) using MTN
    )using MTN
)any left join
    ------------------------------DATA-----------------------------------------------------------------------------------------------------
(
    select toDate(recordOpeningTime)                                                          MTN
         , round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as DATA
    from mediation.data_ericsson
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



/*

select distinct incomingRoute,count() from ericsson
                   where EventDate >= toDateTime(:from_v)
                     and EventDate < toDateTime(:to_v)
group by incomingRoute

select --case when filePath like '%LIMO%' then 'LIMO' else 'ChsLog' end as MTN,accessPointNameNI
     distinct filePath MTN,count()
     --,round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as DATA
from data_ericsson
where recordOpeningTime >= toDateTime(:from_v)
  and recordOpeningTime < toDateTime(:to_v)
    and filePath like '%LIMO%' --'%chsLog%'
   group by MTN--,accessPointNameNI
order by MTN


select /*dateForStartOfCharge, */filepath,count()
from ericsson
where /*filepath like '%VTF13692%'
        and */EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
        and length(filepath) = 46
group by filepath--,dateForStartOfCharge
order by filepath


select dateForStartOfCharge,timeForStartOfCharge,callingPartyNumber,calledPartyNumber
from ericsson
where filepath =  '/home/app/ftp/ericsson/VTF13686' -- '/home/app/ftp/ericsson/VTF_2_13686_20191130164002'
        and EventDate >= toDateTime(:from_v)
        and EventDate < toDateTime(:to_v)
order by dateForStartOfCharge,timeForStartOfCharge

alter table ericsson delete where filepath = '/home/app/ftp/ericsson/Temp/VTF13686'


select  substring(callingPartyNumber,1,2) prefix
        ,substring(callingPartyNumber,3,2) prefix1
        ,type
        ,toDateTime(substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12)) start_date
        ,toUnixTimestamp(chargeableDuration) chargeableDuration
        ,case   when callingPartyNumber like '1100%' then substring(callingPartyNumber,5)
                when substring(callingPartyNumber,1,4) in ('1455','1477','1488') then '231' || '' || substring(callingPartyNumber,3)
                else substring(callingPartyNumber,3)
                end as calling_Number
        ,callingPartyNumber
        ,case   when substring(calledPartyNumber,3,3) like '00%' then substring(calledPartyNumber,5)
                when substring(calledPartyNumber,3,3) in ('055','077','088') then '231' || '' || substring(calledPartyNumber,4)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) like '00%'
                    then substring(calledPartyNumber,8)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) in ('055','077','088')
                    then '231' || '' || substring(calledPartyNumber,7)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) not like '0%'
                    then substring(calledPartyNumber,6)
                else substring(calledPartyNumber,3)
                end as called_Number
        ,calledPartyNumber
--         ,mobileStationRoamingNumber
--         ,translatedNumber
        ,outgoingRoute
        ,incomingRoute
--         ,count() cnt
from    ericsson
where   EventDate >= toDateTime(:from_v)
  and   EventDate < toDateTime(:to_v)
--   and type in ('M_S_TERMINATING')
  and calling_Number  like ('231%')
  and calling_Number not like ('23177%')
--   and eosInfo <> '2'
--   and   type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC','S_S_PROCEDURE')
--   and   translatedNumber = ''
--   and   outgoingRoute in ('BRFO','GENO','ZURO','BRGO','L1MBC1O','L2MBC1O','L1MBC2O','L2MBC2O')
--   and   incomingRoute not in  ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
-- --                     'L2MBC2I')
--   and   prefix in ('14')
--   and   prefix1  in ('07')--,'88','77','55','16')
group by start_date,chargeableDuration,calling_Number,called_Number,outgoingRoute
-- order by cnt desc
limit 500;

select  substring(callingPartyNumber,1,2) prefix
        ,substring(callingPartyNumber,3,2) prefix1
        ,count() cnt
from    ericsson
where   EventDate >= toDateTime(:from_v)
  and   EventDate < toDateTime(:to_v)
  and   type in ('M_S_TERMINATING')
  and   prefix = '14'
group by prefix,prefix1
;

INTL 11
Nat 1123188,1123155
Off 1123177
else Check trunk
Nat 14
Nat 1488,1455
Off 1477
else Check trunk

INTL Incomming
case    when substring(callingPartyNumber,1,5) not in ('11231') and substring(callingPartyNumber,1,2) in ('11')
        then 'INTL'
        else
            (case  when incomingRoute in  ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I','L2MBC2I')
                    then 'INTL' else '' end)
        end = 'INTL'

select  /*incomingRoute prefix
--         ,substring(calledPartyNumber,3,3) prefix1
        ,*/sum(toUnixTimestamp(chargeableDuration))/60 chargeableDuration
        ,count() cnt
from    ericsson
where   EventDate >= toDateTime(:from_v)
  and   EventDate < toDateTime(:to_v)
  and   type in ('CALL_FORWARDING')
--   and eosInfo <> '2'
--   and   outgoingRoute in ('BRFO','GENO','ZURO','BRGO','L1MBC1O','L2MBC1O','L1MBC2O','L2MBC2O')
--   and   case    when substring(callingPartyNumber,1,5) not in ('11231') and substring(callingPartyNumber,1,2) in ('11')
--         then 'INTL'
--         else
--             (case  when incomingRoute in  ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I','L2MBC2I')
--                     then 'INTL' else '' end)
--         end = 'INTL'
  and         case   when callingPartyNumber like '1100%' then substring(callingPartyNumber,5)
                when substring(callingPartyNumber,1,4) in ('1455','1477','1488') then '231' || '' || substring(callingPartyNumber,3)
                else substring(callingPartyNumber,3)
                end  like ('23177%')
--   and   incomingRoute  in  ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
--                     'L2MBC2I')
--   and   type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC','S_S_PROCEDURE')
--   and   prefix = '12'
group by prefix--,prefix1
;
select sum(chargeableDuration) chargeableDuration
from
(
select  sum(toUnixTimestamp(chargeableDuration))/60 chargeableDuration
        ,count() cnt
from    ericsson
where   EventDate >= toDateTime(:from_v)
  and   EventDate < toDateTime(:to_v)
  and   type in ('M_S_TERMINATING')
  and         case   when callingPartyNumber like '1100%' then substring(callingPartyNumber,5)
                when substring(callingPartyNumber,1,4) in ('1455','1477','1488') then '231' || '' || substring(callingPartyNumber,3)
                else substring(callingPartyNumber,3)
                end  like ('23177%')
union all
select  sum(toUnixTimestamp(chargeableDuration))/60 chargeableDuration
        ,count() cnt
from    ericsson
where   EventDate >= toDateTime(:from_v)
  and   EventDate < toDateTime(:to_v)
  and   type in ('CALL_FORWARDING')
  and         case   when callingPartyNumber like '1100%' then substring(callingPartyNumber,5)
                when substring(callingPartyNumber,1,4) in ('1455','1477','1488') then '231' || '' || substring(callingPartyNumber,3)
                else substring(callingPartyNumber,3)
                end  like ('23177%')
);

select sum(chargeableDuration) chargeableDuration
from
(
select  sum(toUnixTimestamp(chargeableDuration))/60 chargeableDuration
        ,count() cnt
from    ericsson
where   EventDate >= toDateTime(:from_v)
  and   EventDate < toDateTime(:to_v)
  and   type in ('M_S_ORIGINATING')
  and   case   when substring(calledPartyNumber,3,3) like '00%' then substring(calledPartyNumber,5)
                when substring(calledPartyNumber,3,3) in ('055','077','088') then '231' || '' || substring(calledPartyNumber,4)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) like '00%'
                    then substring(calledPartyNumber,8)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) in ('055','077','088')
                    then '231' || '' || substring(calledPartyNumber,7)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) not like '0%'
                    then substring(calledPartyNumber,6)
                when calledPartyNumber = '' and outgoingRoute in ('CELLCO') then '23177'
                else substring(calledPartyNumber,3)
                end like ('23177%')
union all
select  sum(toUnixTimestamp(chargeableDuration))/60 chargeableDuration
        ,count() cnt
from    ericsson
where   EventDate >= toDateTime(:from_v)
  and   EventDate < toDateTime(:to_v)
  and   type in ('CALL_FORWARDING')
  and   case   when substring(calledPartyNumber,3,3) like '00%' then substring(calledPartyNumber,5)
                when substring(calledPartyNumber,3,3) in ('055','077','088') then '231' || '' || substring(calledPartyNumber,4)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) like '00%'
                    then substring(calledPartyNumber,8)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) in ('055','077','088')
                    then '231' || '' || substring(calledPartyNumber,7)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) not like '0%'
                    then substring(calledPartyNumber,6)
                when calledPartyNumber = '' and outgoingRoute in ('CELLCO') then '23177'
                else substring(calledPartyNumber,3)
                end like ('23177%')
);

11
1400
14055,77,88
12055,77,88
1200
1202500
12025055,77,88
1207400
12074055,77,88


type
CALL_FORWARDING
M_S_ORIGINATING
M_S_ORIGINATING_SMS_IN_MSC
M_S_TERMINATING
M_S_TERMINATING_SMS_IN_MSC
ROAMING_CALL_FORWARDING
S_S_PROCEDURE
TRANSIT

;
select incomingRoute,sum(chargeableDuration)/60
from
(
select  toDateTime(substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12)) start_date
        ,toUnixTimestamp(chargeableDuration) chargeableDuration
        ,case   when callingPartyNumber like '1100%' then substring(callingPartyNumber,5)
                when substring(callingPartyNumber,1,4) in ('1455','1477','1488') then '231' || '' || substring(callingPartyNumber,3)
                else substring(callingPartyNumber,3)
                end as calling_Number
        ,case   when substring(calledPartyNumber,3,3) like '00%' then substring(calledPartyNumber,5)
                when substring(calledPartyNumber,3,3) in ('055','077','088') then '231' || '' || substring(calledPartyNumber,4)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) like '00%'
                    then substring(calledPartyNumber,8)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) in ('055','077','088')
                    then '231' || '' || substring(calledPartyNumber,7)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) not like '0%'
                    then substring(calledPartyNumber,6)
                else substring(calledPartyNumber,3)
                end as called_Number
--         ,topK(outgoingRoute) outgoingRoute
--         ,outgoingRoute
        ,incomingRoute
        ,count() cnt
from    ericsson
where   EventDate >= toDateTime(:from_v)
  and   EventDate < toDateTime(:to_v)
  and   type in ('M_S_TERMINATING')
  and   calling_Number not like ('231%')
  and   incomingRoute not like ('IVR%')
  and   incomingRoute not like ('CELL%')
--   and   type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC','S_S_PROCEDURE')
--   and   called_Number not like ('231%')
--   and   length(called_Number) > 4
  and   incomingRoute  in ('L1MBC1I')--('BRFO','GENO','ZURO','BRGO','L1MBC1O','L2MBC1O','L1MBC2O','L2MBC2O')
--             ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
--                     'L2MBC2I')
group by start_date,chargeableDuration,calling_Number,called_Number,incomingRoute
order by start_date,chargeableDuration,calling_Number,called_Number
)group by incomingRoute
;
select callIdentificationNumber,relatedCallNumber,type
     ,dateForStartOfCharge,timeForStartOfCharge
     ,toUnixTimestamp(chargeableDuration) chargeableDuration
     ,callingPartyNumber
     ,callingSubscriberIMSI
     ,calledPartyNumber
     ,calledSubscriberIMSI
     ,mobileStationRoamingNumber
     ,chargedParty
     ,originForCharging
     ,mscIdentification
     ,mscAddress
     ,switchIdentity
     ,translatedNumber
     ,eosInfo
     ,outgoingRoute
     ,incomingRoute
-- select round(sum(toUnixTimestamp(chargeableDuration) ) / 60) chargeableDuration
from ericsson
where EventDate >= toDateTime(:from_v)
      and EventDate < toDateTime(:to_v)
--       and callingPartyNumber like '%888493722'
--       and substring(calledPartyNumber,3,4) in ('0250','0740')
--     and callingPartyNumber like ('%880515514')
--       and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
--       and type in ('M_S_TERMINATING')
--       and incomingRoute in
--             ('ZURI', 'Z ('')UR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
--                     'L2MBC2I')
order by dateForStartOfCharge,timeForStartOfCharge,callingPartyNumber
limit 500;


select round(sum(toUnixTimestamp(chargeableDuration) ) / 60) chargeableDuration
from ericsson
where EventDate >= toDateTime(:from_v)
      and EventDate < toDateTime(:to_v)
--       and type in ('M_S_TERMINATING')
      and outgoingRoute in
          ('BRFO','GENO','ZURO','BRGO','L1MBC1O','L2MBC1O','L1MBC2O','L2MBC2O')
--             ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
--                     'L2MBC2I')
-- order by dateForStartOfCharge,timeForStartOfCharge,callingPartyNumber
;

select  toDate(EventDate) MTN
        ,round(sum(toUnixTimestamp(chargeableDuration))/60) On_Net--,count(),type
from ericsson
where EventDate >= toDateTime(:from_v)
      and EventDate < toDateTime(:to_v)
--       and originForCharging in ('1') group by type
      and type in ('M_S_TERMINATING','CALL_FORWARDING')
      and case   when callingPartyNumber like '1100%' then substring(callingPartyNumber,5)
                when substring(callingPartyNumber,1,4) in ('1455','1477','1488') then '231' || '' || substring(callingPartyNumber,3)
                else substring(callingPartyNumber,3)
                end like '231%'
      and case   when callingPartyNumber like '1100%' then substring(callingPartyNumber,5)
                when substring(callingPartyNumber,1,4) in ('1455','1477','1488') then '231' || '' || substring(callingPartyNumber,3)
                else substring(callingPartyNumber,3)
                end not like '23177%'
      and case   when substring(calledPartyNumber,3,3) like '00%' then substring(calledPartyNumber,5)
                when substring(calledPartyNumber,3,3) in ('055','077','088') then '231' || '' || substring(calledPartyNumber,4)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) like '00%'
                    then substring(calledPartyNumber,8)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) in ('055','077','088')
                    then '231' || '' || substring(calledPartyNumber,7)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) not like '0%'
                    then substring(calledPartyNumber,6)
                else substring(calledPartyNumber,3)
                end like '231%'
      and case   when substring(calledPartyNumber,3,3) like '00%' then substring(calledPartyNumber,5)
                when substring(calledPartyNumber,3,3) in ('055','077','088') then '231' || '' || substring(calledPartyNumber,4)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) like '00%'
                    then substring(calledPartyNumber,8)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) in ('055','077','088')
                    then '231' || '' || substring(calledPartyNumber,7)
                when substring(calledPartyNumber,3,3) in ('025','074') and substring(calledPartyNumber,6,3) not like '0%'
                    then substring(calledPartyNumber,6)
                when calledPartyNumber = '' and incomingRoute not in
                                    ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
                                            'L2MBC2I','CELLCI') then '23188'
                else substring(calledPartyNumber,3)
                end not like '23177%'
      and incomingRoute not in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
                    'L2MBC2I','CELLCI')
--       and (callingSubscriberIMSI like '61801%'
--       or callingSubscriberIMSI like '61804%')
-- group by callingSubscriberIMSI,calledSubscriberIMSI
group by MTN
-- select distinct incomingRoute from ericsson

outgoingRoute
COMIUMO
CELLCO
'BRFO',
'GENO',
'ZURO',
'BRGO',
'L1MBC1O',
'L2MBC1O',
'L1MBC2O',
'L2MBC2O'
*/