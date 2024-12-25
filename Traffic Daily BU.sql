----------------Test ORANGE Trunk----------------
/*
select * from Orange_Pre where toYear(Date) = (:year) and toMonth(Date) = (:month)
and Call_Type not in ('DATA','Ex','On_Net','International_Incoming','International_Outgoing','MTN_To_Orange','Orange_To_MTN')
*/
-- create table mediation.Orange_Daily (Date DateTime,Call_Type String,callDuration int)
-- ENGINE = Memory;
---------------ORANGE-------------------------------


truncate table Orange_Daily
truncate table MTN_Daily
truncate table Daily_Traffic_d

insert into mediation.Orange_Daily

select  Date,Call_Type,sum(callDuration) callDuration
from (
select  Date, Call_Type, callDuration
from (
select  callReference,
        toDate(eventTimeStamp) Date,
        callDuration,
        case    when (incomingTKGPName in
                 ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat',
                  'SBC_siptrunk', 'VOIPE_PBX_SIP', 'OCS-SIP-A', 'OCS-SIP-B', 'OCS-SIP-C', 'OCS-SIP-D')
                and outgoingTKGPName in
                   ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat',
                    'SBC_siptrunk', 'VOIPE_PBX_SIP', 'OCS-SIP-A', 'OCS-SIP-B', 'OCS-SIP-C', 'OCS-SIP-D'))
                then 'On_Net'
        else (
        case    when incomingTKGPName in
                  ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482',
                   'BARAK SIP 2',
                   'OLIB_SBC_OFR')
                then 'International_Incoming'
        else (
        case    when outgoingTKGPName in
                 ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                  'Orange-12482', 'BARAK SIP 2',
                  'OLIB_SBC_OFR')
                then 'International_Outgoing'
        else (
        case    when incomingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
                then 'MTN_To_Orange'
        else (
        case    when outgoingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
                then 'Orange_To_MTN'
        else (
        case    when (outgoingTKGPName in
                ('IVR_OBD_SERV2', 'IVR1_SERV1', 'RBT_SERV1','RBT_SERV2', 'Religious_Service','SBC_VoiceMail',
                'VoiceMail_1', 'VoiceMail_2', 'OCS-SIP-LAB')
                or incomingTKGPName in
                ('IVR_OBD_SERV2', 'IVR1_SERV1', 'RBT_SERV1','RBT_SERV2', 'Religious_Service','SBC_VoiceMail',
                    'VoiceMail_1', 'VoiceMail_2','OCS-SIP-LAB'))
                and length(calledNumber) > 6
                then 'Ex'
        else (incomingTKGPName || ',' || outgoingTKGPName)
        end) end) end) end) end) end as Call_Type
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and type in
        ('MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'MO_CALL_RECORD', 'OUT_GATEWAY_RECORD', 'ROAM_RECORD',
         'MCF_CALL_RECORD')
    and callDuration > 0
         )  group by Date, callReference, Call_Type, callDuration
         )  group by Date, Call_Type;

------------------------------------------------------------------------------------------

insert into mediation.Orange_Daily

select  toDate(recordOpeningTime)  Date
        , 'DATA' as Call_Type
        , round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as callDuration
from    mediation.data_zte
where   toYear(recordOpeningTime) = (:year)
    and toMonth(recordOpeningTime) = (:month)
    and ((filePath like '%GGSN%' and accessPointNameNI in ('web.cellcomnet.net', 'orangelbr', 'cellcom4g','cellcom'))
            or (filePath like '%SGSN%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%')
                and accessPointNameOI <> 'mnc007.mcc618.gprs')))
group by Date,Call_Type;

--------------------------------------------------------------------------

insert into mediation.Daily_Traffic_d

select  'ORANGE' Operator,Date,round(sum(On_Net)/60) On_Net,round(sum(International_Incoming)/60) International_Incoming
        ,round(sum(International_Outgoing)/60) International_Outgoing,round(sum(Orange_To_MTN)/60) Orange_To_MTN
        ,round(sum(MTN_To_Orange)/60) MTN_To_Orange,sum(DATA) DATA--,round(sum(New_Trunk)/60) New_Trunk
from (
      select toDate(Date) Date
           , case when Call_Type = 'On_Net' then callDuration else 0 end                 as On_Net
           , case when Call_Type = 'International_Incoming' then callDuration else 0 end as International_Incoming
           , case when Call_Type = 'International_Outgoing' then callDuration else 0 end as International_Outgoing
           , case when Call_Type = 'MTN_To_Orange' then callDuration else 0 end          as MTN_To_Orange
           , case when Call_Type = 'Orange_To_MTN' then callDuration else 0 end          as Orange_To_MTN
           , case when Call_Type = 'DATA' then callDuration else 0 end                   as DATA
           , callDuration
      from mediation.Orange_Daily
      where Call_Type not in ('Ex')
            and toYear(Date) = (:year)
            and toMonth(Date) = (:month)
         )
group by Date--,On_Net,International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN,New_Trunk
order by Date;

----------------------MTN--------------------------------------------------


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

insert into MTN_Daily (Date,International_Outgoing)

select  toDate(EventDate) Date,sum(toUnixTimestamp(chargeableDuration)/60) International_Outgoing
from (
select  EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
group by EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
        )group by Date

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

insert into MTN_Daily (Date,International_Incoming)

select  toDate(EventDate) Date,sum(toUnixTimestamp(callDuration))/60 International_Incoming
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
        and type in ('M_S_ORIGINATING','ROAMING_CALL_FORWARDING','TRANSIT','CALL_FORWARDING')
        and filepath not like ('/ex')
group by EventDate,callingPartyNumber,calledPartyNumber,incomingRoute
     ) group by Date

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

---------------------REPORT-------------------------

-- select  Operator,round((:onnet)/sum(On_Net),2) On_Net,round((:In)/sum(International_Incoming),2) International_Incoming
--         ,round((:out)/sum(International_Outgoing),2) International_Outgoing,round((:otm)/sum(Orange_To_MTN),2) Orange_To_MTN
--         ,round((:mto)/sum(MTN_To_Orange),2)MTN_To_Orange,round((:data)/sum(DATA),2) DATA
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