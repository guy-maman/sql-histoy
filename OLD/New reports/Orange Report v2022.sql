
-------------Orange Report

select Orange,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange
from (
      select Orange
           , sum(On_Net) / 60                 On_Net
           , sum(International_Incoming) / 60 International_Incoming
           , sum(International_Outgoing) / 60 International_Outgoing
           , sum(MTN_To_Orange) / 60          MTN_To_Orange
           , sum(Orange_To_MTN) / 60          Orange_To_MTN
      from (
            select Orange,
                   callReference,
                   On_Net,
                   International_Incoming,
                   International_Outgoing,
                   MTN_To_Orange,
                   Orange_To_MTN
            from (
                  select callReference,
                         toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
                         case
                             when (incomingTKGPName in
                                   ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','MSC_SBC_ACS','SBC_FriendnChat','SBC_siptrunk','VOIPE_PBX_SIP',
                                    'OCS-SIP-A', 'OCS-SIP-B', 'OCS-SIP-C','OCS-SIP-D')
                                 and outgoingTKGPName in
                                   ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','MSC_SBC_ACS','SBC_FriendnChat','SBC_siptrunk','VOIPE_PBX_SIP',
                                    'OCS-SIP-A', 'OCS-SIP-B', 'OCS-SIP-C','OCS-SIP-D')
                                 and length(calledNumber) > 6)
                                 then callDuration
                             else 0 end as      On_Net,
                         case
                             when incomingTKGPName in
                                  ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482',
                                   'BARAK SIP 2',
                                   'OLIB_SBC_OFR')
                                 then callDuration
                             else 0 end as      International_Incoming,
                         case
                             when outgoingTKGPName in
                                  ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482',
                                   'BARAK SIP 2',
                                   'OLIB_SBC_OFR')
                                 then callDuration
                             else 0 end as      International_Outgoing,
                         case
                             when incomingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
                                 then callDuration
                             else 0 end as      MTN_To_Orange,
                         case
                             when outgoingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
                                 then callDuration
                             else 0 end as      Orange_To_MTN
                  from mediation.zte
                  where toYear(eventTimeStamp) = (:year)
                    and toMonth(eventTimeStamp) = (:month)
--         and toDayOfMonth(eventTimeStamp) = 1
                    and type in
                        ('MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'MO_CALL_RECORD', 'OUT_GATEWAY_RECORD', 'ROAM_RECORD',
                         'MCF_CALL_RECORD')
                    and callDuration > 0
                     )
            group by Orange, callReference, On_Net,International_Incoming, International_Outgoing, MTN_To_Orange,
                     Orange_To_MTN
               )
      group by Orange
         ) group by Orange,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange
            order by Orange
;