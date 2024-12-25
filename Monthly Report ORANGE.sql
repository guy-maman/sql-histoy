-- create table mediation.Orange_Daily (Orange DateTime, On_Net int,International_Incoming int,International_Outgoing int,MTN_To_Orange int,Orange_To_MTN int) ENGINE = Memory;
-- drop table mediation.Orange_Daily

/*

select Orange,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange,DATA
from(
select toDate(Orange) Orange,On_Net,International_Incoming,International_Outgoing,Orange_To_MTN,MTN_To_Orange
from mediation.Orange_Daily
where toYear(Orange) = (:year)
        and toMonth(Orange) = (:month)
    )any left join
    (
        select toDate(recordOpeningTime)                                                          Orange
             , round((sum(listOfTrafficIn) / 1024 / 1024) + (sum(listOfTrafficOut) / 1024 / 1024)) as DATA
        from mediation.data_zte
        where toYear(recordOpeningTime) = (:year)
        and toMonth(recordOpeningTime) = (:month)
          and ((filePath like '%GGSN%' and accessPointNameNI in
                                           ('web.cellcomnet.net', /*'roducate2', 'orangetdd',*/ 'orangelbr', 'cellcom4g',
                                            'cellcom'))
            or (filePath like '%SGSN%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                                            accessPointNameOI <> 'mnc007.mcc618.gprs')))
        group by Orange
        )using Orange
order by Orange;

*/

insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
--         and toDayOfMonth(eventTimeStamp) = 1
        and type in ('MT_CALL_RECORD','INC_GATEWAY_RECORD','MO_CALL_RECORD','OUT_GATEWAY_RECORD','ROAM_RECORD','MCF_CALL_RECORD')
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;

insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 2
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 3
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 4
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 5
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 6
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 7
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 8
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 9
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 10
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 11
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 12
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 13
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 14
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 15
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 16
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 17
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 18
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 19
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 20
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 21
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 22
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 23
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 24
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 25
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 26
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 27
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 28
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 29
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;
insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 30
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;

insert into mediation.Orange_Daily

select Orange,sum(On_Net)/60 On_Net,sum(International_Incoming)/60 International_Incoming,sum(International_Outgoing)/60 International_Outgoing
        ,sum(MTN_To_Orange)/60 MTN_To_Orange,sum(Orange_To_MTN)/60 Orange_To_MTN
from (
select Orange,callReference,On_Net,max(International_Incoming) International_Incoming,International_Outgoing,MTN_To_Orange,Orange_To_MTN
from (
      select callReference,
             toDate(eventTimeStamp) Orange,--outgoingTKGPName,incomingTKGPName
             case
                 when (incomingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and outgoingTKGPName in ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY','OCS-SIP-A','OCS-SIP-B','OCS-SIP-C','OCS-SIP-D')
                     and length(calledNumber) > 6)
                     then callDuration
                 else 0 end as      On_Net,
             case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Incoming,
             case
                 when outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end as      International_Outgoing,
             case
                 when incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      MTN_To_Orange,
             case
                 when outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
                     then callDuration
                 else 0 end as      Orange_To_MTN
      from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 31
        and callDuration > 0
         )group by Orange,callReference,On_Net/*,International_Incoming*/,International_Outgoing,MTN_To_Orange,Orange_To_MTN
         )group by Orange
             ;