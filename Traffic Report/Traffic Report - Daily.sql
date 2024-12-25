
/*
select * from Orange_Pre where toYear(Date) = (:year) and toMonth(Date) = (:month)
and Call_Type not in ('DATA','Ex','On_Net','International_Incoming','International_Outgoing','MTN_To_Orange','Orange_To_MTN')
*/
-- create table mediation.Orange_Daily (Date DateTime,Call_Type String,callDuration int)
-- ENGINE = Memory;



truncate table Orange_Daily
truncate table MTN_Daily
truncate table Daily_Traffic_d
truncate table Daily_Traffic_Temp

------------------------------------------------------------------  ORANGE  ---------------------------------------------
-------------------------------------------------------- On_Net

insert into mediation.Daily_Traffic_Temp (Operator,Date,On_Net)

select  'ORANGE' Operator,toDate(eventTimeStamp) Date,round(sum(callDuration)/60,2) On_Net
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and type in ('MO_CALL_RECORD')
    and (incomingTKGPName in
      ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat','SBC_siptrunk', 'VOIPE_PBX_SIP')
    and outgoingTKGPName in
        ('',  'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat','SBC_siptrunk'))
    and callDuration > 0
group by Operator,Date
order by Date

---------------------------------------- International_Incoming

insert into mediation.Daily_Traffic_Temp (Operator,Date,International_Incoming)

select  Operator,toDate(Date) Date,round(sum(callDuration)/60,2) International_Incoming
from    mediation.INTL
where   toYear(Date) = (:year)
    and toMonth(Date) = (:month)
    and Operator = 'ORANGE'
    and Direction = 'Incoming'
group by Operator,Date
order by Date

---------------------------------------- International_Outgoing

insert into mediation.Daily_Traffic_Temp (Operator,Date,International_Outgoing)

select  Operator,toDate(Date) Date,round(sum(callDuration)/60,2) International_Outgoing
from    mediation.INTL
where   toYear(Date) = (:year)
    and toMonth(Date) = (:month)
    and Operator = 'ORANGE'
    and Direction = 'Outgoing'
group by Operator,Date
order by Date;

---------------------------------------- Orange_To_MTN

insert into mediation.Daily_Traffic_Temp (Operator,Date,Orange_To_MTN)

select  'ORANGE' Operator,toDate(eventTimeStamp) Date,round(sum(callDuration)/60,2) Orange_To_MTN
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('OUT_GATEWAY_RECORD')
    and outgoingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
group by Operator,Date
order by Date

---------------------------------------- MTN_To_Orange

insert into mediation.Daily_Traffic_Temp (Operator,Date,MTN_To_Orange)

select  'ORANGE' Operator,toDate(eventTimeStamp) Date,round(sum(callDuration)/60,2) MTN_To_Orange
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('INC_GATEWAY_RECORD')
    and incomingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
group by Operator,Date
order by Date

---------------------------------------- DATA

insert into mediation.Daily_Traffic_Temp (Operator,Date,DATA)

select  'ORANGE' Operator, toDate(recordOpeningTime)  Date
        ,round(sum(listOfTrafficIn + listOfTrafficOut) / 1024 / 1024) as DATA
from    mediation.data_zte
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
    and (filePath like '%GGSN%' and accessPointNameNI in ('web.cellcomnet.net', 'orangelbr', 'cellcom4g','cellcom'))
group by Operator,Date
order by Date


----------------------- Print ------------

insert into Daily_Traffic_d

select  Operator,Date,sum(On_Net) On_Net,sum(International_Incoming) International_Incoming
        ,sum(International_Outgoing) International_Outgoing,sum(Orange_To_MTN) Orange_To_MTN
        ,sum(MTN_To_Orange) MTN_To_Orange,sum(DATA) DATA
from    Daily_Traffic_Temp
where   toYear(Date) = (:year)
    and toMonth(Date) = (:month)
--         and Operator = (:op)
group by Operator,Date
order by Operator,Date


------------------------------------------------------------------  MTN  ------------------------------------------------
----------------------------------------- On_Net

insert into MTN_Daily (Date,On_Net)

select  toDate(EventDate) Date,sum(toUnixTimestamp(chargeableDuration)/60) On_Net
from (
select  EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and originForCharging = '1'
    and incomingRoute not in
        ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I','L1MBC2I','L2MBC2I', 'CELLCI')
    and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO'
                ,'BCPBX1O','ISON1O','IVR1O','MAV2O','VIAMOO')
    and length(calledPartyNumber) > 7
    and length(callingPartyNumber) > 7
group by EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
        )group by Date

------------------------------------------------ International_Incoming

insert into MTN_Daily (Operator,Date,International_Incoming)

select  Operator,toDate(Date) Date,round(sum(callDuration)/60,2) International_Incoming
from (
select  Operator,Date,callReference,callDuration
from    mediation.INTL
where   toYear(Date) = (:year)
    and toMonth(Date) = (:month)
    and Operator = 'MTN'
    and Direction = 'Incoming'
group by Operator,Date,callReference,callDuration
order by Date,callReference
)
group by Operator,Date
order by Date;

------------------------------------------------ International_Outgoing

insert into MTN_Daily (Operator,Date,International_Outgoing)

select  Operator,toDate(Date) Date,round(sum(callDuration)/60,2) International_Outgoing
from (
select  Operator,Date,callReference,callDuration
from    mediation.INTL
where   toYear(Date) = (:year)
    and toMonth(Date) = (:month)
    and Operator = 'MTN'
    and Direction = 'Outgoing'
group by Operator,Date,callReference,callDuration
order by Date,callReference
)
group by Operator,Date
order by Date;

------------------------------------------------ Orange_To_MTN

insert into MTN_Daily (Date,Orange_To_MTN)

select  toDate(EventDate) Date,sum(toUnixTimestamp(chargeableDuration)/60) Orange_To_MTN
from (
select  EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and originForCharging = '1'
    and incomingRoute in ('CELLCI', 'ORGSBCI')
group by EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
        )group by Date

------------------------------------------------ MTN_To_Orange

insert into MTN_Daily (Date,MTN_To_Orange)

select  toDate(EventDate) Date,sum(toUnixTimestamp(chargeableDuration)/60) MTN_To_Orange
from (
select  EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and outgoingRoute in ('CELLCO', 'ORGSBCO')
group by EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
        )group by Date

------------------------------------------------ DATA

insert into MTN_Daily (Date,DATA)

select  toDate(recordOpeningTime)  Date
        ,round(sum(listOfTrafficIn + listOfTrafficOut) / 1024 / 1024) as DATA
from    mediation.data_ericsson
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
    and (listOfTrafficIn <> 0 or listOfTrafficOut <> 0)
    and accessPointNameOI <> 'mnc001.mcc618.gprs'
group by Date

----------------------- Print ------------

insert into mediation.Daily_Traffic_d

select  'MTN' Operator,Date,sum(On_Net) On_Net,sum(International_Incoming)International_Incoming
        ,sum(International_Outgoing) International_Outgoing,sum(Orange_To_MTN) Orange_To_MTN
        ,sum(MTN_To_Orange) MTN_To_Orange,sum(DATA) DATA
from    MTN_Daily
group by Date
order by Date

--Daily_Traffic

select  Operator,Date,sum(On_Net) On_Net,sum(International_Incoming) International_Incoming
        ,sum(International_Outgoing) International_Outgoing,sum(Orange_To_MTN) Orange_To_MTN
        ,sum(MTN_To_Orange) MTN_To_Orange,sum(DATA) DATA
from    Daily_Traffic_d
where   toYear(Date) = (:year)
    and toMonth(Date) = (:month)
--         and Operator = (:op)
group by Operator,Date
order by Operator,Date
;

-- select  Operator,round((:onnet)/sum(On_Net),2) On_Net,round((:In)/sum(International_Incoming),2) International_Incoming
--         ,round((:out)/sum(International_Outgoing),2) International_Outgoing,round((:otm)/sum(Orange_To_MTN),2) Orange_To_MTN
--         ,round((:mto)/sum(MTN_To_Orange),2)MTN_To_Orange,round((:data)/sum(DATA),2) DATA
-- 742,864



-----------------------------------------------------------------
/*

select * from Daily_Traffic_ch

insert into Daily_Traffic_ch

select  Operator,Date,(:onnet) On_Net,(:In) International_Incoming
        ,(:out) International_Outgoing,(:otm) Orange_To_MTN,(:mto) MTN_To_Orange,(:data) DATA
from    Daily_Traffic_d
where   toYear(Date) = (:year)
    and toMonth(Date) = (:month)
    and toDayOfMonth(Date) = 1
    and Operator = (:op)

insert into Daily_Traffic

select  Operator,Date,On_Net*(:onnet) On_Net,International_Incoming*(:In) International_Incoming
        ,International_Outgoing*(:out) International_Outgoing,Orange_To_MTN*(:otm) Orange_To_MTN
        ,MTN_To_Orange*(:mto) MTN_To_Orange,DATA*(:data) DATA
from    Daily_Traffic_d
where   toYear(Date) = (:year)
    and toMonth(Date) = (:month)
    and Operator = (:op)

select *
from    Daily_Traffic
where   toYear(Date) = (:year)
    and toMonth(Date) = (:month)
--     and toDayOfMonth(Date) = 1
order by Operator,Date

*/
-- create table Daily_Traffic_ch
--     (Operator String,Date DateTime,On_Net Decimal(3,2),International_Incoming Decimal(3,2),International_Outgoing Decimal(3,2),Orange_To_MTN Decimal(3,2),MTN_To_Orange Decimal(3,2),DATA Decimal(3,2))
-- ENGINE = Memory;
-- insert into table mediation.Daily_Traffic_ch (Operator,Date,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange,DATA)
--             VALUES ('g','2022-05-01T00:00:00',1.04,0,0,0,0,0)
-- select * from Daily_Traffic_ch

-- select  Operator,sum(International_Incoming),sum(International_Outgoing)
-- from    Daily_Traffic_d
-- where   toYear(Date) = (:year)
--         and toMonth(Date) = (:month)
-- group by Operator

-- select * from Orange_Pre where toYear(Date) = (:year) and toMonth(Date) = (:month)
--
-- alter table mediation.Orange_Pre ON CLUSTER cluster delete  where toYear(Date) = 2022 and toMonth(Date) = 5

-- alter table mediation.Daily_Traffic_d ON CLUSTER cluster delete  where toYear(Date) = 2022 and toMonth(Date) = 5 and Operator = 'MTN'