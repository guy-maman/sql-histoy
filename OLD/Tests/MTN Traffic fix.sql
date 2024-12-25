truncate table MTN_Daily

-- select * from Daily_Traffic_d

truncate table Daily_Traffic_d

insert into MTN_Daily (Date,On_Net)

select  toDate(EventDate) Date,sum(toUnixTimestamp(chargeableDuration)/60) On_Net
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and originForCharging = '1'
    and incomingRoute not in
        ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I'
            ,'L1MBC2I','L2MBC2I', 'CELLCI')
    and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO')
    and length(calledPartyNumber) > 7
    and length(callingPartyNumber) > 7
group by Date

insert into MTN_Daily (Date,International_Outgoing)

select  toDate(EventDate) Date,sum(chargeableDuration)/60 International_Outgoing
from
(
select  EventDate,max(toUnixTimestamp(chargeableDuration)) chargeableDuration,callingPartyNumber
        ,case   when substring(calledPartyNumber, 3, 3) in ('055', '077', '088')
                then '231' || '' || substring(calledPartyNumber, 4)
                else
        (case   when substring(calledPartyNumber,1,5) in ('12025','12073','12074','12076','12085','12086','12095','12096')
                        and substring(calledPartyNumber,6,3) in ('055', '077', '088')
                then ('231' || '' || substring(calledPartyNumber, 7))
                else
        (case   when substring(calledPartyNumber,1,5) in ('12025','12073','12074','12076','12085','12086','12095','12096')
                        and substring(calledPartyNumber,6,2) = '00'
                then substring(calledPartyNumber, 8)
                else
        (case   when substring(calledPartyNumber,1,5) in ('12025','12073','12074','12076','12085','12086','12095','12096')
                then substring(calledPartyNumber, 6)
                else
        (case   when substring(calledPartyNumber, 3, 2) = '00'
                then substring(calledPartyNumber, 5)
                else
        (case   when substring(calledPartyNumber, 3, 3) in ('025', '074', '095', '096')
                then substring(calledPartyNumber, 6)
                else substring(calledPartyNumber, 3) end) end) end) end) end) end as calledPartyNumber
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and type in  ('TRANSIT','M_S_ORIGINATING')  -- ('M_S_ORIGINATING','ROAMING_CALL_FORWARDING','TRANSIT','CALL_FORWARDING')--,'M_S_TERMINATING')
    and calledPartyNumber not like '231%'
    and length(calledPartyNumber) >7
group by EventDate,calledPartyNumber,callingPartyNumber--,chargeableDuration
order by EventDate
) group by Date

---------------------------------------------------;

select  sum(toUnixTimestamp(chargeableDuration))/60  from (
select  filepath,EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and filepath like '%VTF17085_20221231173448%'
    and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
order by EventDate
group by EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
    )

-----------------------------------------------------;

insert into MTN_Daily (Date,MTN_To_Orange)

select  toDate(EventDate) Date,sum(toUnixTimestamp(chargeableDuration)/60) MTN_To_Orange
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and outgoingRoute in ('CELLCO', 'ORGSBCO')
group by Date

insert into MTN_Daily (Date,Orange_To_MTN)

select  toDate(EventDate) Date,sum(toUnixTimestamp(chargeableDuration)/60) Orange_To_MTN
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and originForCharging = '1'
    and incomingRoute in ('CELLCI', 'ORGSBCI')
group by Date

insert into MTN_Daily (Date,International_Incoming)

select  toDate(EventDate) Date,sum(callDuration)/60 International_Incoming
from (
select  EventDate
        ,max(toUnixTimestamp(chargeableDuration)) callDuration
        ,substring(callingPartyNumber,3) callingPartyNumber
        ,substring(calledPartyNumber,3) calledPartyNumber
        ,incomingRoute
from    mediation.ericsson
where   toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
        and incomingRoute in
            ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I',
             'L1MBC2I', 'L2MBC2I')
        and type in ('M_S_TERMINATING','ROAMING_CALL_FORWARDING','TRANSIT','CALL_FORWARDING')--,'M_S_ORIGINATING')
        and filepath not like ('/ex')
group by EventDate,callingPartyNumber,calledPartyNumber,incomingRoute
     ) group by Date

-- select distinct type from ericsson
-- where   toYear(EventDate) = (:year)
--         and toMonth(EventDate) = (:month)

insert into MTN_Daily (Date,DATA)

select  toDate(recordOpeningTime)  Date
        ,round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as DATA
from    mediation.data_ericsson
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
    and ((filePath like '%LIMO%' )
    or  (filePath like '%chsLog%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                                      accessPointNameOI <> 'mnc001.mcc618.gprs')))
group by Date

insert into mediation.Daily_Traffic_d

select  'MTN' Operator,Date,sum(On_Net) On_Net,sum(International_Incoming)International_Incoming
        ,sum(International_Outgoing) International_Outgoing,sum(Orange_To_MTN) Orange_To_MTN
        ,sum(MTN_To_Orange) MTN_To_Orange,sum(DATA) DATA
from    MTN_Daily
group by Date
order by Date

select * from Daily_Traffic_d


/*
 select  toDate(EventDate) Date,sum(callDuration)/60 International_Outgoing
from (
select  EventDate
        ,max(toUnixTimestamp(chargeableDuration)) callDuration
        ,substring(callingPartyNumber,3) callingPartyNumber
        ,substring(calledPartyNumber,3) calledPartyNumber
        ,outgoingRoute
from    mediation.ericsson
where   toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
        and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
        and type in ('ROAMING_CALL_FORWARDING','TRANSIT','CALL_FORWARDING','M_S_ORIGINATING')
        and filepath not like ('/ex')
group by EventDate,callingPartyNumber,calledPartyNumber,outgoingRoute
     ) group by Date
 */

/*
insert into mediation.Daily_Traffic_d

select 'MTN' Operator,Date,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange,DATA
from
(
select  Date,round(sum(On_Net)/60) On_Net,round(sum(International_Incoming)/60) International_Incoming
        ,round(sum(International_Outgoing)/60) International_Outgoing,round(sum(Orange_To_MTN)/60) Orange_To_MTN
        ,round(sum(MTN_To_Orange)/60) MTN_To_Orange
from (
select  toDate(EventDate) Date
        ,case    when originForCharging = '1'
                    and incomingRoute not in
                        ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I'
                            ,'L1MBC2I','L2MBC2I', 'CELLCI')
                    and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO')
                    and length(calledPartyNumber) > 7
                    and length(callingPartyNumber) > 7
                then toUnixTimestamp(chargeableDuration)
        else 0 end as On_Net
        ,case   when originForCharging = '1'
                     and incomingRoute in
                         ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I',
                          'L1MBC2I', 'L2MBC2I')
                     then toUnixTimestamp(chargeableDuration)
        else 0 end as International_Incoming
        ,case   when outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
                     then toUnixTimestamp(chargeableDuration)
        else 0 end as International_Outgoing
        ,case   when originForCharging = '1'
                     and incomingRoute in ('CELLCI', 'ORGSBCI')
                     then toUnixTimestamp(chargeableDuration)
        else 0 end as Orange_To_MTN
        ,case   when outgoingRoute in ('CELLCO', 'ORGSBCO')
                     then toUnixTimestamp(chargeableDuration)
        else 0 end as MTN_To_Orange
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
         )group by Date
         )any left join

    ------------------------------DATA-----------------------------------------------------------------------------------------------------
(
select  toDate(recordOpeningTime)  Date
        ,round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as DATA
from    mediation.data_ericsson
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
    and ((filePath like '%LIMO%' )
    or  (filePath like '%chsLog%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                                      accessPointNameOI <> 'mnc001.mcc618.gprs')))
group by Date
)using   Date
order by Date;
*/