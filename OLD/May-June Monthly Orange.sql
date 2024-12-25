/*select  toYYYYMMDD(recordOpeningTime) Orange
     , round((sum(listOfTrafficIn) / 1024 / 1024 ) + (sum(listOfTrafficOut) / 1024 / 1024)) as DATA
from data_zte
where recordOpeningTime >= toDateTime(:from_v)
  and recordOpeningTime < toDateTime(:to_v)
  and ((filePath like '%GGSN%' and accessPointNameNI in ('web.cellcomnet.net','roducate2','orangetdd','orangelbr','cellcom4g','cellcom'))
          or (filePath like '%SGSN%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and accessPointNameOI <> 'mnc007.mcc618.gprs')))
group by Orange

*/


/***** All Traffic *****/

-------------------------- May -----------------------------------------------------------------------------------

    select Orange, On_Net, International_Incoming, International_Outgoing, MTN_To_Orange, Orange_To_MTN
    from (
             select Orange, On_Net, International_Incoming, International_Outgoing
             from (
                      select Orange,
                             round(sum(On_Net) / 60) On_Net--,sum(cnt) count
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
                                                toYYYYMMDD(answerTime) Orange,
                                                count()                cnt--,incomingTKGPName
                                         from zte
                                         where type in
                                               ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD',
                                                'OUT_GATEWAY_RECORD',
                                                'ROAM_RECORD')
                                           and outgoingTKGPName in
                                               ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                                                'Orange-12482',
                                                'BARAK SIP 2', 'OLIB_SBC_OFR')
                                           and eventTimeStamp >= toDateTime(:from_v)
                                           and eventTimeStamp < toDateTime(:to_v)
                                           and callDuration > 0
                                         group by callReference, answerTime, callDuration, Orange
                                         union all
                                         select answerTime,
                                                callReference,
                                                callDuration,
                                                toYYYYMMDD(answerTime) Orange,
                                                count()                cnt
                                         from zte
                                         where type in ('MCF_CALL_RECORD')
                                           and outgoingTKGPName in
                                               ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                                                'Orange-12482',
                                                'BARAK SIP 2', 'OLIB_SBC_OFR')
                                           and eventTimeStamp >= toDateTime(:from_v)
                                           and eventTimeStamp < toDateTime(:to_v)
                                           and callDuration > 0
                                         group by callReference, answerTime, callDuration, Orange
                                            )
                                   group by Orange
                                   ) any
                                   left join
                               (
                                   select Orange,
                                          round(sum(callDuration) / 60) International_Incoming--,count() Count
                                   from (
                                         select answerTime,
                                                callReference,
                                                callDuration,
                                                toYYYYMMDD(answerTime) Orange,
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
                                         group by callReference, answerTime, callDuration, Orange
                                         union all
                                         select answerTime,
                                                callReference,
                                                callDuration,
                                                toYYYYMMDD(answerTime) Orange,
                                                count()                cnt
                                         from zte
                                         where type in ('MCF_CALL_RECORD')
                                           and eventTimeStamp >= toDateTime(:from_v)
                                           and eventTimeStamp < toDateTime(:to_v)
                                           and callDuration > 0
                                         group by callReference, answerTime, callDuration, Orange
                                         union all
                                         select answerTime,
                                                callReference,
                                                callDuration,
                                                toYYYYMMDD(answerTime) Orange,
                                                count()                cnt
                                         from zte
                                         where type in ('ROAM_RECORD')
                                           and eventTimeStamp >= toDateTime(:from_v)
                                           and eventTimeStamp < toDateTime(:to_v)
                                           and callDuration > 0
                                         group by callReference, answerTime, callDuration, Orange
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
                                       toYYYYMMDD(answerTime) Orange,
                                       count()                cnt--,incomingTKGPName
                                from zte
                                where type in
                                      ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'OUT_GATEWAY_RECORD',
                                       'ROAM_RECORD')
                                  and outgoingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp >= toDateTime(:from_v)
                                  and eventTimeStamp < toDateTime(:to_v)
                                  and callDuration > 0
                                group by callReference, answerTime, callDuration, Orange
                                union all
                                select answerTime,
                                       callReference,
                                       callDuration,
                                       toYYYYMMDD(answerTime) Orange,
                                       count()                cnt
                                from zte
                                where type in ('MCF_CALL_RECORD')
                                  and outgoingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp >= toDateTime(:from_v)
                                  and eventTimeStamp < toDateTime(:to_v)
                                  and callDuration > 0
                                group by callReference, answerTime, callDuration, Orange
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
                                       toYYYYMMDD(answerTime) Orange,
                                       count()                cnt--,incomingTKGPName
                                from zte
                                where type in
                                      ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'OUT_GATEWAY_RECORD',
                                       'ROAM_RECORD')
                                  and incomingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp >= toDateTime(:from_v)
                                  and eventTimeStamp < toDateTime(:to_v)
                                  and callDuration > 0
                                group by callReference, answerTime, callDuration, Orange
                                union all
                                select answerTime,
                                       callReference,
                                       callDuration,
                                       toYYYYMMDD(answerTime) Orange,
                                       count()                cnt
                                from zte
                                where type in ('MCF_CALL_RECORD')
                                  and incomingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp >= toDateTime(:from_v)
                                  and eventTimeStamp < toDateTime(:to_v)
                                  and callDuration > 0
                                group by callReference, answerTime, callDuration, Orange
                                   )
                          group by Orange
                          ) using Orange
                 ) using Orange
order by Orange
;


-------------------------- June -----------------------------------------------------------------------------------

    select Orange, On_Net, International_Incoming, International_Outgoing, MTN_To_Orange, Orange_To_MTN
    from (
             select Orange, On_Net, International_Incoming, International_Outgoing
             from (
                      select Orange,
                             round(sum(On_Net) / 60) On_Net--,sum(cnt) count
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
                  ---------------------International_Incoming, International_Outgoing------------------------------------------------------------------------
                      (
                          select Orange, International_Incoming, International_Outgoing
                          from (
                                   select Orange,
                                          round(sum(callDuration) / 60) International_Outgoing--,count() Count
                                   from (
                                         select /*answerTime,*/
                                                callReference,
                                                callDuration,
                                                toYYYYMMDD(answerTime) Orange,
                                                count()                cnt--,incomingTKGPName
                                         from zte
                                         where type in
                                               ('MO_CALL_RECORD', 'MT_CALL_RECORD'/*, 'INC_GATEWAY_RECORD',
                                                'OUT_GATEWAY_RECORD',
                                                'ROAM_RECORD'*/)
                                           and outgoingTKGPName in
                                               ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                                                'Orange-12482',
                                                'BARAK SIP 2'/*, 'OLIB_SBC_OFR'*/)
                                           and eventTimeStamp >= toDateTime(:from_v)
                                           and eventTimeStamp < toDateTime(:to_v)
                                           and callDuration > 0
                                         group by callReference, /*answerTime,*/ callDuration, Orange
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
                                                toYYYYMMDD(answerTime) Orange,
                                                count()                cnt--,incomingTKGPName
                                         from zte
                                         where type in
                                               ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD',
                                                'OUT_GATEWAY_RECORD'/*,'MCF_CALL_RECORD',
                                                'ROAM_RECORD'*/)
                                           and incomingTKGPName in
                                               ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                                                'Orange-12482',
                                                'BARAK SIP 2'/*, 'OLIB_SBC_OFR'*/)
                                           and eventTimeStamp >= toDateTime(:from_v)
                                           and eventTimeStamp < toDateTime(:to_v)
                                           and callDuration > 0
                                         group by callReference, Orange, /*answerTime,*/ callDuration
                                            )
                                   group by Orange
                                   ) using Orange
                          ) using Orange
             ) any
             left join
         -----------------------------MTN_To_Orange, Orange_To_MTN----------------------------------------------------------------------
             (
                 select Orange, MTN_To_Orange, Orange_To_MTN
                 from (
                          select Orange,
                                 round(sum(callDuration) / 60) Orange_To_MTN--,count() Count
                          from (
                                select answerTime,
                                       callReference,
                                       callDuration,
                                       toYYYYMMDD(answerTime) Orange,
                                       count()                cnt--,incomingTKGPName
                                from zte
                                where type in
                                      ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'OUT_GATEWAY_RECORD',
                                       'ROAM_RECORD')
                                  and outgoingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp >= toDateTime(:from_v)
                                  and eventTimeStamp < toDateTime(:to_v)
                                  and callDuration > 0
                                group by callReference, answerTime, callDuration, Orange
                                union all
                                select answerTime,
                                       callReference,
                                       callDuration,
                                       toYYYYMMDD(answerTime) Orange,
                                       count()                cnt
                                from zte
                                where type in ('MCF_CALL_RECORD')
                                  and outgoingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp >= toDateTime(:from_v)
                                  and eventTimeStamp < toDateTime(:to_v)
                                  and callDuration > 0
                                group by callReference, answerTime, callDuration, Orange
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
                                       toYYYYMMDD(answerTime) Orange,
                                       count()                cnt--,incomingTKGPName
                                from zte
                                where type in
                                      ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'OUT_GATEWAY_RECORD',
                                       'ROAM_RECORD')
                                  and incomingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp >= toDateTime(:from_v)
                                  and eventTimeStamp < toDateTime(:to_v)
                                  and callDuration > 0
                                group by callReference, answerTime, callDuration, Orange
                                union all
                                select answerTime,
                                       callReference,
                                       callDuration,
                                       toYYYYMMDD(answerTime) Orange,
                                       count()                cnt
                                from zte
                                where type in ('MCF_CALL_RECORD')
                                  and incomingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp >= toDateTime(:from_v)
                                  and eventTimeStamp < toDateTime(:to_v)
                                  and callDuration > 0
                                group by callReference, answerTime, callDuration, Orange
                                   )
                          group by Orange
                          ) using Orange
                 ) using Orange
order by Orange
;
-------------------------END---------------------------------------------------------------------------------------------------
/*
        select toYYYYMMDD(recordOpeningTime)                                                          Orange
             , round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as DATA
        from data_ericsson
        where recordOpeningTime >= toDateTime(:from_v)
          and recordOpeningTime < toDateTime(:to_v)
          and ((filePath like '%GGSN%' and accessPointNameNI in
                                           ('web.cellcomnet.net', 'roducate2', 'orangetdd', 'orangelbr', 'cellcom4g',
                                            'cellcom'))
            or (filePath like '%SGSN%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                                            accessPointNameOI <> 'mnc007.mcc618.gprs')))
        group by Orange
*/




--                                    select Orange,
--                                           round(sum(callDuration) / 60) International_Incoming--,count() Count
--                                    from (
--                                          select answerTime,
--                                                 case when callReference = '' then calledNumber else callReference end as callReference,
--                                                 callDuration,
--                                                 toYYYYMMDD(answerTime) Orange,
--                                                 count()                cnt--,incomingTKGPName
--                                          from zte
--                                          where type in
--                                                ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD',
--                                                 'OUT_GATEWAY_RECORD','MCF_CALL_RECORD',
--                                                 'ROAM_RECORD')
--                                            and incomingTKGPName in
--                                                ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
--                                                 'Orange-12482',
--                                                 'BARAK SIP 2', 'OLIB_SBC_OFR')
--                                            and eventTimeStamp >= toDateTime(:from_v)
--                                            and eventTimeStamp < toDateTime(:to_v)
--                                            and callDuration > 0
--                                          group by callReference, answerTime, callDuration, Orange
--                                             )
--                                    group by Orange