
/***** All Traffic *****/

select  Orange,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange,DATA
from (
    select Orange, On_Net, International_Incoming, International_Outgoing, MTN_To_Orange, Orange_To_MTN
    from (
             select Orange, On_Net, International_Incoming, International_Outgoing
             from (
                      select Orange,
                             round(sum(On_Net) / 60) On_Net--,sum(cnt) count
                      from (
                            select toDate(answerTime) Orange, sum(callDuration)*1.03 On_Net, count() cnt
                            from zte
                            where type in ('MO_CALL_RECORD','MCF_CALL_RECORD', 'OUT_GATEWAY_RECORD', 'ROAM_RECORD', 'INC_GATEWAY_RECORD')
                              and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER')
                              and incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER')
                              and eventTimeStamp >= toDateTime(:from_v)
                              and eventTimeStamp < toDateTime(:to_v)
--                               and servedMSISDN like '2317%'
                              and callDuration > 0
                            group by Orange
/*                            union all
                            select toDate(answerTime) Orange, sum(callDuration) On_Net, count() cnt
                            from zte
                            where type in ('MCF_CALL_RECORD')
                              and outgoingTKGPName in
                                  ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY', 'CALL_CENTER', 'Religious_Service')
                              and eventTimeStamp >= toDateTime(:from_v)
                              and eventTimeStamp < toDateTime(:to_v)
                              and callDuration > 0
                            group by Orange*/
                               )
                      group by Orange
                      ) any
                      left join
                  -------------------------------------------------------------------------------------------------------------------------------------------------
                      (
                          select Orange, International_Incoming, International_Outgoing
                          from (
                                   select Orange,
                                          round(sum(callDuration) / 60) International_Outgoing--,count() Count
                                   from (
                                         select answerTime,
                                                callReference,
                                                callDuration,
                                                toDate(answerTime) Orange,
                                                count()                cnt--,incomingTKGPName
                                         from zte
                                         where type in
                                               ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD',
                                                'OUT_GATEWAY_RECORD','MCF_CALL_RECORD',
                                                'ROAM_RECORD')
                                           and outgoingTKGPName in
                                               ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                                                'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                                           and eventTimeStamp >= toDateTime(:from_v)
                                           and eventTimeStamp < toDateTime(:to_v)
                                           and callDuration > 0
                                         group by answerTime,callReference,  callDuration, Orange
                                         union all
                                         select answerTime,
                                                callReference,
                                                callDuration,
                                                toDate(answerTime) Orange,
                                                count()                cnt
                                         from zte
                                         where type in ('MCF_CALL_RECORD')
                                           and outgoingTKGPName in
                                               ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                                                'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                                           and eventTimeStamp >= toDateTime(:from_v)
                                           and eventTimeStamp < toDateTime(:to_v)
                                           and callDuration > 0
                                         group by answerTime,callReference,  callDuration, Orange
                                            )
                                   group by Orange
                                   ) any
                                   left join
                               (
                                   select Orange,
                                          round(sum(callDuration) / 60) International_Incoming--,count() Count
                                   from (
                                         select /*answerTime,*/
                                                callReference,
                                                callDuration,
                                                toDate(answerTime) Orange,
                                                count()                cnt--,incomingTKGPName
                                         from zte
                                         where type in
                                               ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD',
                                                'OUT_GATEWAY_RECORD',
                                                'ROAM_RECORD')
                                           and incomingTKGPName in
                                               ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                                                'Orange-12482',
                                                'BARAK SIP 2', 'OLIB_SBC_OFR')
                                           and eventTimeStamp >= toDateTime(:from_v)
                                           and eventTimeStamp < toDateTime(:to_v)
                                           and callDuration > 0
                                         group by callReference, /*answerTime, */callDuration, Orange
--                                          union all
--                                          select answerTime,
--                                                 callReference,
--                                                 callDuration,
--                                                 toDate(answerTime) Orange,
--                                                 count()                cnt
--                                          from zte
--                                          where type in ('MCF_CALL_RECORD')
--                                            and incomingTKGPName in
--                                                ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
--                                                 'Orange-12482',
--                                                 'BARAK SIP 2', 'OLIB_SBC_OFR')
--                                            and eventTimeStamp >= toDateTime(:from_v)
--                                            and eventTimeStamp < toDateTime(:to_v)
--                                            and callDuration > 0
--                                          group by callReference, answerTime, callDuration, Orange
--                                          union all
--                                          select answerTime,
--                                                 callReference,
--                                                 callDuration,
--                                                 toDate(answerTime) Orange,
--                                                 count()                cnt
--                                          from zte
--                                          where type in ('ROAM_RECORD')
--                                            and incomingTKGPName in
--                                                ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
--                                                 'Orange-12482',
--                                                 'BARAK SIP 2', 'OLIB_SBC_OFR')
--                                            and eventTimeStamp >= toDateTime(:from_v)
--                                            and eventTimeStamp < toDateTime(:to_v)
--                                            and callDuration > 0
--                                          group by callReference, answerTime, callDuration, Orange
                                            )
                                   group by Orange
                                   ) using Orange
                          ) using Orange
             ) any
             left join
         ----------------------------------------------------------------------------------------------------------------------------------------------
             (
                 select Orange, MTN_To_Orange, Orange_To_MTN
                 from (
                          select Orange,
                                 round(sum(callDuration) / 60) Orange_To_MTN--,count() Count
                          from (
                                select answerTime,
                                       callReference,
                                       callDuration,
                                       toDate(answerTime) Orange
                                from zte
                                where type in
                                      ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'OUT_GATEWAY_RECORD',
                                       'ROAM_RECORD')
                                  and outgoingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp >= toDateTime(:from_v)
                                  and eventTimeStamp < toDateTime(:to_v)
                                  and callDuration > 0
                                group by  answerTime,callReference, callDuration, Orange
                                union all
                                select answerTime,
                                       callReference,
                                       callDuration,
                                       toDate(answerTime) Orange
                                from zte
                                where type in ('MCF_CALL_RECORD')
                                  and outgoingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp >= toDateTime(:from_v)
                                  and eventTimeStamp < toDateTime(:to_v)
                                  and callDuration > 0
                                group by answerTime,callReference,  callDuration, Orange
                                   )
                          group by Orange
                          ) any
                          left join
                      (
                          select Orange,
                                 round(sum(callDuration) / 60) MTN_To_Orange--,count() Count
                          from (
                                select answerTime,
                                       callReference,
                                       callDuration,
                                       toDate(answerTime) Orange
                                from zte
                                where type in
                                      ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'OUT_GATEWAY_RECORD',
                                       'ROAM_RECORD')
                                  and incomingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp >= toDateTime(:from_v)
                                  and eventTimeStamp < toDateTime(:to_v)
                                  and callDuration > 0
                                group by answerTime,callReference,  callDuration, Orange
                                union all
                                select answerTime,
                                       callReference,
                                       callDuration,
                                       toDate(answerTime) Orange
                                from zte
                                where type in ('MCF_CALL_RECORD')
                                  and incomingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp >= toDateTime(:from_v)
                                  and eventTimeStamp < toDateTime(:to_v)
                                  and callDuration > 0
                                group by answerTime, callReference, callDuration, Orange
                                   )
                          group by Orange
                          ) using Orange
                 ) using Orange
    )any left join
----------------------------------------------------------------------------------------------------------------------------------------------------------------
    (
        select toDate(recordOpeningTime)                                                          Orange
             , round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as DATA
        from data_zte
        where recordOpeningTime >= toDateTime(:from_v)
          and recordOpeningTime < toDateTime(:to_v)
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

select servedMSISDN,callingNumber,calledNumber,type
from zte
                                         where type in
                                               ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD',
                                                'OUT_GATEWAY_RECORD',
                                                'ROAM_RECORD')
                                           and incomingTKGPName in
                                               ( 'OLIB_SBC_OFR')
                                           and eventTimeStamp >= toDateTime(:from_v)
                                           and eventTimeStamp < toDateTime(:to_v)



/*

select round(sum(callDuration) / 60) On_Net, count() cnt
-- select servedMSISDN,callingNumber,calledNumber,translatedNumber,answerTime
from zte
where type in ('MO_CALL_RECORD', 'OUT_GATEWAY_RECORD', 'ROAM_RECORD', 'MCF_CALL_RECORD','INC_GATEWAY_RECORD')
  and outgoingTKGPName in (''/*, 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER'*/)
--   and incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER')
--   and outgoingTKGPName not in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
--                                 'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','Comium', 'LoneStar')
  and eventTimeStamp >= toDateTime(:from_v)
  and eventTimeStamp < toDateTime(:to_v)
  and callDuration > 0
union all
select round(sum(callDuration) / 60) On_Net, count() cnt
-- select servedMSISDN,callingNumber,calledNumber,translatedNumber,answerTime
from zte
where type in ('MCF_CALL_RECORD','ROAM_RECORD')
  and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER')
  and incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER')
--   and outgoingTKGPName not in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
--                                 'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','Comium', 'LoneStar')
  and eventTimeStamp >= toDateTime(:from_v)
  and eventTimeStamp < toDateTime(:to_v)
  and callDuration > 0


select servedMSISDN,callingNumber,calledNumber,translatedNumber,answerTime
from zte
where type in ('MO_CALL_RECORD', 'OUT_GATEWAY_RECORD', 'ROAM_RECORD', 'MCF_CALL_RECORD','INC_GATEWAY_RECORD')
  and outgoingTKGPName in 'OLIB_SBC_OFR'--('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER')
  and eventTimeStamp >= toDateTime(:from_v)
  and eventTimeStamp < toDateTime(:to_v)

outgoingTKGPName
""
US AMBASY
SBC_siptrunk
VOIPE_PBX_SIP
OLIB_SBC_OFR
BICS-4194
BICS-4193
OCS-SIP-B
OCS-SIP-A
IVR1_SERV1
OCS-SIP-LAB
Religious_Service
OCS-SIP-D
SBC_FriendnChat
CALL_CENTER
ISUP-IVR-C
OCI_KM4
OCI_ASSB
IVR_OBD_SERV2
ISUP-IVR-A
ISUP-IVR-B
RBT_SERV2
OCS-SIP-C
ISUP-IVR-D
RBT_SERV1
Orange-12490
LEC_PBX
LoneStar







select outgoingTKGPName,sum(callDuration)
from zte
where eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
group by outgoingTKGPName

select filepath
from zte
where eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
--     and filepath like '%MSC2019120293620%'
group by filepath
order by filepath


select filePath
from data_zte
where recordOpeningTime >= toDateTime(:from_v)
    and recordOpeningTime < toDateTime(:to_v)
    and filePath like '%GGSN_2019121898834.dat%'
group by filePath
order by filePath

/*
select Orange,On_Net,International_Incoming,International_Outgoing
from (
      select Orange, On_Net, International_Incoming
      from (
               select Orange,round(sum(On_Net) / 60) On_Net--,sum(cnt) count
               from (
                     select toYYYYMMDD(answerTime) Orange, sum(callDuration) On_Net, count() cnt
                     from zte
                     where type in ('MO_CALL_RECORD', 'OUT_GATEWAY_RECORD', 'ROAM_RECORD', 'INC_GATEWAY_RECORD')
                       and outgoingTKGPName in
                           ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY', 'CALL_CENTER', 'Religious_Service')
                       and eventTimeStamp >= toDateTime(:from_v)
                       and eventTimeStamp < toDateTime(:to_v)
                       and callDuration > 0
                     group by Orange
                     union all
                     select toYYYYMMDD(answerTime) Orange, sum(callDuration) On_Net, count() cnt
                     from zte
                     where type in ('MCF_CALL_RECORD')
                       and outgoingTKGPName in
                           ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY', 'CALL_CENTER', 'Religious_Service')
                       and eventTimeStamp >= toDateTime(:from_v)
                       and eventTimeStamp < toDateTime(:to_v)
                       and callDuration > 0
                     group by Orange
                        )
               group by Orange
               ) any
               left join
           (
               select Orange,round(sum(callDuration) / 60) International_Incoming--,count() Count
               from (
                     select answerTime,callReference,callDuration,toYYYYMMDD(answerTime) Orange,count() cnt--,incomingTKGPName
                     from zte
                     where type in ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'OUT_GATEWAY_RECORD','ROAM_RECORD')
                       and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482',
                            'BARAK SIP 2','OLIB_SBC_OFR')
                       and eventTimeStamp >= toDateTime(:from_v)
                       and eventTimeStamp < toDateTime(:to_v)
                       and callDuration > 0
                     group by callReference, answerTime, callDuration, Orange
                     union all
                     select answerTime, callReference, callDuration, toYYYYMMDD(answerTime) Orange, count() cnt
                     from zte
                     where type in ('MCF_CALL_RECORD')
                       and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482',
                            'BARAK SIP 2','OLIB_SBC_OFR')
                       and eventTimeStamp >= toDateTime(:from_v)
                       and eventTimeStamp < toDateTime(:to_v)
                       and callDuration > 0
                     group by callReference, answerTime, callDuration, Orange
                        )
               group by Orange
               ) using Orange
         )any left join
    (
    select Orange, round(sum(callDuration) / 60) International_Outgoing--,count() Count
    from (
    select answerTime, callReference, callDuration, toYYYYMMDD(answerTime) Orange, count() cnt--,incomingTKGPName
    from zte
    where type in ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'OUT_GATEWAY_RECORD','ROAM_RECORD')
        and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482',
                                'BARAK SIP 2','OLIB_SBC_OFR')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
    group by callReference, answerTime, callDuration, Orange
    union all
    select answerTime, callReference, callDuration, toYYYYMMDD(answerTime) Orange, count() cnt
    from zte
    where type in ('MCF_CALL_RECORD')
        and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482',
                                'BARAK SIP 2','OLIB_SBC_OFR')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
    group by callReference, answerTime, callDuration, Orange
    ) group by Orange
    )using Orange



*/



















select toYYYYMMDD(answerTime) Orange,round(sum(callDuration) / 60) MTN_To_Orange
from zte
where type not in ('MT_CALL_RECORD')
    and incomingTKGPName in ('Comium','LoneStar')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
group by Orange

select toYYYYMMDD(answerTime) Orange,round(sum(callDuration)/60) Orange_To_MTN
from zte
where type not in ('MO_CALL_RECORD')
    and outgoingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
) order by ord
;*/