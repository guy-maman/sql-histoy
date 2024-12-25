
/*
create table mediation.Orange_2021 (Orange DateTime,callDuration int,Call_Type String)
ENGINE = Memory;
*/
-- truncate table mediation.Orange_2022
/*
select  Date,round(sum(On_Net)/60) On_Net,round(sum(International_Incoming)/60) International_Incoming
        ,round(sum(International_Outgoing)/60) International_Outgoing,round(sum(MTN_To_Orange)/60) MTN_To_Orange
        ,round(sum(Orange_To_MTN)/60) Orange_To_MTN,sum(DATA) DATA,round(sum(New_Trunk)/60) New_Trunk
from (
      select Date as Orange
           , case when Call_Type = 'On_Net' then callDuration else 0 end                 as On_Net
           , case when Call_Type = 'International_Incoming' then callDuration else 0 end as International_Incoming
           , case when Call_Type = 'International_Outgoing' then callDuration else 0 end as International_Outgoing
           , case when Call_Type = 'MTN_To_Orange' then callDuration else 0 end          as MTN_To_Orange
           , case when Call_Type = 'Orange_To_MTN' then callDuration else 0 end          as Orange_To_MTN
           , case when Call_Type = 'DATA' then callDuration else 0 end                   as DATA
           , case when Call_Type not in
                      ('On_Net', 'International_Incoming', 'International_Outgoing', 'MTN_To_Orange', 'Orange_To_MTN','DATA')
                     then callDuration
                 else 0 end                                                              as New_Trunk
        ,callDuration
      from mediation.Orange
      where Call_Type not in ('Ex')
            and toYear(Date) = (:year)
            and toMonth(Date) = (:month)
         )
group by Date,On_Net,International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN,New_Trunk
order by Date
*/
/*
insert into mediation.Orange_2021
-- truncate table mediation.Orange_2022
select count()--Orange,Call_Type,callDuration
from Orange_2020
-- where Call_Type not in ('Ex','On_Net','International_Incoming','International_Outgoing','MTN_To_Orange','Orange_To_MTN')
-- group by Call_Type
*/


insert into mediation.Orange_2022

select Orange,Call_Type,sum(callDuration) callDuration
from (
      select Orange, Call_Type, callDuration
      from (
            select callReference,
                   toDate(eventTimeStamp)                                                                                                              Orange,
                   callDuration,--outgoingTKGPName,incomingTKGPName
                   case
                       when (incomingTKGPName in
                             ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat',
                              'SBC_siptrunk', 'VOIPE_PBX_SIP', 'OCS-SIP-A', 'OCS-SIP-B', 'OCS-SIP-C', 'OCS-SIP-D')
                           and outgoingTKGPName in
                               ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat',
                                'SBC_siptrunk', 'VOIPE_PBX_SIP', 'OCS-SIP-A', 'OCS-SIP-B', 'OCS-SIP-C', 'OCS-SIP-D'))
                           then 'On_Net'
                       else
                           (case
                                when incomingTKGPName in
                                     ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482',
                                      'BARAK SIP 2',
                                      'OLIB_SBC_OFR')
                                    then 'International_Incoming'
                                else
                                    (case
                                         when outgoingTKGPName in
                                              ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                                               'Orange-12482', 'BARAK SIP 2',
                                               'OLIB_SBC_OFR')
                                             then 'International_Outgoing'
                                         else
                                             (case
                                                  when incomingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
                                                      then 'MTN_To_Orange'
                                                  else
                                                      (case
                                                           when outgoingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
                                                               then 'Orange_To_MTN'
                                                           else
                                                               (case
                                                                    when (outgoingTKGPName in
                                                                          ('IVR_OBD_SERV2', 'IVR1_SERV1', 'RBT_SERV1',
                                                                           'RBT_SERV2', 'Religious_Service',
                                                                           'SBC_VoiceMail',
                                                                           'VoiceMail_1', 'VoiceMail_2', 'OCS-SIP-LAB')
                                                                        or incomingTKGPName in
                                                                           ('IVR_OBD_SERV2', 'IVR1_SERV1', 'RBT_SERV1',
                                                                            'RBT_SERV2', 'Religious_Service',
                                                                            'SBC_VoiceMail',
                                                                            'VoiceMail_1', 'VoiceMail_2',
                                                                            'OCS-SIP-LAB'))
                                                                        then 'Ex'
                                                                    else (incomingTKGPName || ',' || outgoingTKGPName) end) end) end) end) end) end as Call_Type
            from mediation.zte
            where toYear(eventTimeStamp) = (:year)
              and toMonth(eventTimeStamp) = (:month)
              and length(calledNumber) > 6
--         and toDayOfMonth(eventTimeStamp) = 1
              and type in
                  ('MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'MO_CALL_RECORD', 'OUT_GATEWAY_RECORD', 'ROAM_RECORD',
                   'MCF_CALL_RECORD')
              and callDuration > 0
               )
      group by Orange, callReference, Call_Type, callDuration
         ) group by Orange, Call_Type;
-- order by Orange

insert into mediation.Orange_2022

select toDate(recordOpeningTime)                                                          Orange
        , 'DATA' as Call_Type
        , round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as callDuration
from mediation.data_zte
where   toYear(recordOpeningTime) = (:year)
        and toMonth(recordOpeningTime) = (:month)
        and ((filePath like '%GGSN%' and accessPointNameNI in
                                   ('web.cellcomnet.net', /*'roducate2', 'orangetdd',*/ 'orangelbr', 'cellcom4g',
                                    'cellcom'))
                        or (filePath like '%SGSN%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                                    accessPointNameOI <> 'mnc007.mcc618.gprs')))
group by Orange,Call_Type;



-- limit 500



/*
/*
create table mediation.Orange_MonthlyTest (callReference String,Orange DateTime,callDuration int,outgoing_TKGPName String,incoming_TKGPName String)
ENGINE = Memory;
*/
-- ,servedMSISDN String,callingNumber String,calledNumber String
-- drop table mediation.Orange_MonthlyTest

insert into mediation.Orange_MonthlyTest

select callReference,toDate(eventTimeStamp) Orange,callDuration,--servedMSISDN,callingNumber,calledNumber,
        case outgoingTKGPName
            when '' then 'On_Net'
            when 'OCS-SIP-A' then 'On_Net'
            when 'OCS-SIP-B' then 'On_Net'
            when 'OCS-SIP-C' then 'On_Net'
            when 'OCS-SIP-D' then 'On_Net'
            when 'Religious_Service' then 'Ex'
            when 'SBC_VoiceMail' then 'Ex'
            when 'VoiceMail_1' then 'Ex'
            when 'VoiceMail_2' then 'Ex'
            when 'RBT_SERV2' then 'Ex'
            when 'RBT_SERV1' then 'Ex'
            when 'IVR_OBD_SERV2' then 'Ex'
            when 'IVR1_SERV1' then 'Ex'
            when 'SBC_siptrunk' then 'On_Net'
            when 'MSC_SBC_ACS' then 'On_Net'
            when 'SBC_FriendnChat' then 'On_Net'
            when 'CALL_CENTER' then 'On_Net'
            when 'LEC_PBX' then 'On_Net'
            when 'VOIPE_PBX_SIP' then 'On_Net'
            when 'US AMBASY' then 'On_Net'
            when 'Orange-12490' then 'International_Outgoing'
            when 'BICS-4193' then 'International_Outgoing'
            when 'BICS-4194' then 'International_Outgoing'
            when 'OCI_KM4' then 'International_Outgoing'
            when 'OCI_ASSB' then 'International_Outgoing'
            when 'OLIB_SBC_OFR' then 'International_Outgoing'
            when 'OCS-SIP-LAB' then 'International_Outgoing'
            when 'LoneStar' then 'Orange_To_MTN'
            when 'MSC_SBC_MTN' then 'Orange_To_MTN'
            when 'Comium' then 'Orange_To_MTN'
            else outgoingTKGPName end as outgoing_TKGPName,
        case incomingTKGPName
            when '' then 'On_Net'
            when 'BICS-4193' then 'International_Incoming'
            when 'BICS-4194' then 'International_Incoming'
            when 'CALL_CENTER' then 'On_Net'
            when 'IVR_OBD_SERV2' then 'Ex'
            when 'IVR1_SERV1' then 'Ex'
            when 'LEC_PBX' then 'On_Net'
            when 'LoneStar' then 'MTN_To_Orange'
            when 'MSC_SBC_MTN' then 'MTN_To_Orange'
            when 'OCI_ASSB' then 'International_Incoming'
            when 'OCI_KM4' then 'International_Incoming'
            when 'OCS-SIP-A' then 'On_Net'
            when 'OCS-SIP-B' then 'On_Net'
            when 'OCS-SIP-C' then 'On_Net'
            when 'OCS-SIP-D' then 'On_Net'
            when 'OLIB_SBC_OFR' then 'International_Incoming'
            when 'Orange-12490' then 'International_Incoming'
            when 'Religious_Service' then 'Ex'
            when 'SBC_FriendnChat' then 'On_Net'
            when 'SBC_siptrunk' then 'On_Net'
            when 'US AMBASY' then 'On_Net'
            when 'VOIPE_PBX_SIP' then 'On_Net'
            when 'Comium' then 'Orange_To_MTN'
            else incomingTKGPName end as incoming_TKGPName
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
--      and toDayOfMonth(eventTimeStamp) = 1
    and type in ('MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'MO_CALL_RECORD', 'OUT_GATEWAY_RECORD', 'ROAM_RECORD',
                'MCF_CALL_RECORD')
    and callDuration > 0;
*/
