-- create table report (Destination String,Orange DateTime, Minutes int) ENGINE = Memory;
-- drop table report


insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2'/*,'IVR1_SERV1','IVR_OBD_SERV2'*/)
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 1
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;

insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 2
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 3
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 4
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 5
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 6
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 7
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 8
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 9
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 10
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 11
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 12
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 13
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 14
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 15
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 16
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 17
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 18
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 19
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 20
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 21
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 22
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 23
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 24
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 25
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 26
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 27
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 28
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 29
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 30
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;
insert into report
select Destination,Orange,round(sum(callDuration) / 60) Minutes
from (
      select answerTime,
             callReference,
             callDuration,
             toDate(eventTimeStamp) Orange,
             case   when incomingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY','CALL_CENTER','SBC_siptrunk','Religious_Service')
                           and outgoingTKGPName not in ('Comium', 'LoneStar','BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193'
                                                        ,'Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR','RBT_SERV1','RBT_SERV2')
                        then 'On Net'
                    when incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Incoming'
                    when outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482','BARAK SIP 2', 'OLIB_SBC_OFR')
                        then 'International_Outgoing'
                    when incomingTKGPName in ('Comium', 'LoneStar')
                        then 'MTN_To_Orange'
                    when outgoingTKGPName in ('Comium', 'LoneStar')
                        then 'Orange_To_MTN'
                        else 'Other'
                            end as Destination
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 31
        and callDuration > 0
      group by answerTime, callReference, callDuration, Orange, incomingTKGPName,outgoingTKGPName
         )group by Orange,Destination
             ;