
----------------- Oramge Roaming

create table CountryCode (Direction String,CountryCode String) ENGINE = Memory;

insert into CountryCode
values ('Incoming','221'),('Incoming','224'),('Incoming','225'),('Incoming','228'),('Incoming','229'),('Incoming','232')
        ,('Outgoing','221'),('Outgoing','224'),('Outgoing','225'),('Outgoing','228'),('Outgoing','229'),('Outgoing','232')
        ,('Incoming','Other'),('Incoming','Unknown All'),('Outgoing','Other'),('Outgoing','Unknown All')
;
------ Inbound

-- select  type,servedMSISDN,substring(callingNumber,5) callingNumber,calledNumber,incomingTKGPName,outgoingTKGPName,mscAddress
      select case when CountryCode in ('221', '224', '225', '228', '229', '232')
                    then CountryCode
                    else 'Other'
                        end CountryCode
           , round(sum(callDuration)/60) Inbound
from (
      select case
                 when substring(substring(callingNumber, 5), 1, 2) = '00'
                     then substring(callingNumber, 7)
                 else substring(callingNumber, 5)
          end                               callingNumber
           , substring(servedMSISDN, 3)     calledNumber
           , substring(callingNumber, 1, 3) CountryCode
           , callDuration
      from zte
      where type in ('MT_CALL_RECORD')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and incomingTKGPName not in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2', 'LoneStar',
             'OLIB_SBC_OFR', 'CALL_CENTER')
        and callingNumber not like '77%'
        and callingNumber not like '23177%'
        and callingNumber not like '077%'
        and callingNumber not like '0023177%'
         )group by CountryCode
;

-- select  type,servedMSISDN,substring(calledNumber,1,5) called_Number,callingNumber,incomingTKGPName,outgoingTKGPName,mscAddress
select substring(servedMSISDN, 3)                   callingNumber
--      , case when substring(substring(calledNumber, 3),1,2) = '00'
--             then substring(calledNumber, 5)
--             else substring(calledNumber, 3)
--                 end                                 calledNumber
     , substring(dialledNumber, 3) calledNumber
     , dialledNumber
     , substring(calledNumber, 1,3)                CountryCode
     , callDuration,incomingTKGPName,outgoingTKGPName,roamingNumber
from    zte
where type in ('MO_CALL_RECORD')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration >0
        and length(calledNumber) >5
        and outgoingTKGPName in ''
        and calledNumber not like '77%' and calledNumber not like '23177%' and calledNumber not like '077%' and calledNumber not like '0023177%'

select  distinct substring(calledNumber,1, 2)
from    zte
where type in ('MO_CALL_RECORD')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and outgoingTKGPName not in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','LoneStar','OLIB_SBC_OFR'
            ,'CALL_CENTER')


----------- Outbound


      select case when substring(substring(roamingNumber, 5), 1,3) in ('221', '224', '225', '228', '229', '232')
                    then substring(substring(roamingNumber, 5), 1,3)
                    else 'Other'
                        end CountryCode
           , round(sum(callDuration)/60) Outbound
      from zte
      where type in ('ROAM_RECORD')
--       and callingNumber like '%777777077'
--         and outgoingTKGPName in
--              ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        --and CountryCode in ('221','224','225','228','229','232')
group by CountryCode
order by CountryCode;


--------------- Test


            select answerTime
                 , callReference
                 , callDuration
                 , type,servedMSISDN,callingNumber,calledNumber,roamingNumber,incomingTKGPName,outgoingTKGPName
                 , mscAddress,routingNumber,numberOfForwarding,dialledNumber,calledLocation,callingLocation
                 , transRoamingNumber
--                  , topK(type)            CallType
--                  , max(servedMSISDN)     servedMSISDN
--                  , max(callingNumber)   callingNumber
--                  , max(calledNumber)    calledNumber
--                  , max(incomingTKGPName) incomingTKGPName
--                  , max(outgoingTKGPName) outgoingTKGP_Name
            from zte
            where /*type in ('ROAM_RECORD')
--                   ('OUT_GATEWAY_RECORD', 'MO_CALL_RECORD','ROAM_RECORD','MT_CALL_RECORD','INC_GATEWAY_RECORD')
                  and*/ outgoingTKGPName  in ('OCS-SIP-LAB')
--                       ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
                  and eventTimeStamp >= toDateTime(:from_v)
                  and eventTimeStamp < toDateTime(:to_v)
--                   and transRoamingNumber not like '192317%' and transRoamingNumber not like ''
                  and callDuration > 0
--             group by answerTime, callReference, callDuration
            order by answerTime, callReference
            limit 500;


----------------- Tests

select  type,servedMSISDN,substring(callingNumber,5) callingNumber,calledNumber,incomingTKGPName,outgoingTKGPName,mscAddress
from    zte
where type in ('MT_CALL_RECORD')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and incomingTKGPName not in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','LoneStar','OLIB_SBC_OFR')
        and callingNumber not like '77%' and callingNumber not like '23177%' and callingNumber not like '077%' and callingNumber not like '0023177%'
-- group by type,prefix
-- order by type,prefix

select  distinct outgoingTKGPName--,outgoingTKGPName,mscAddress
from    zte
where   eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)


;
type
COMMON_EQUIP_RECORD
HLR_INT_RECORD
INC_GATEWAY_RECORD
MCF_CALL_RECORD
MO_CALL_RECORD
MO_LCS_RECORD
MO_SMS_RECORD
MT_CALL_RECORD
MT_SMS_RECORD
OUT_GATEWAY_RECORD
SS_ACTION_RECORD
USSD_RECORD
TERM_CAMEL_INT_RECORD
ROAM_RECORD

incomingTKGPName
""
/*LoneStar
OCI_ASSB
OCI_KM4
BICS-4194
Orange-12490
BICS-4193
Orange-12482
OLIB_SBC_OFR
US AMBASY
VOIPE_PBX_SIP
CALL_CENTER
ISUP-IVR-B
ISUP-IVR-C
ISUP-IVR-A
ISUP-IVR-D
OCS-SIP-LAB
LEC_PBX*/

outgoingTKGPName
""
VOIPE_PBX_SIP
OCI_KM4
OCI_ASSB
BICS-4193
IVR_OBD_SERV2
IVR1_SERV1
Religious_Service
LoneStar
CALL_CENTER
ISUP-IVR-A
ISUP-IVR-D
ISUP-IVR-B
ISUP-IVR-C
BICS-4194
Orange-12490
Orange-12482
LEC_PBX
US AMBASY
RBT_SERV2
RBT_SERV1
OCS-SIP-LAB
OCS-SIP-A
OCS-SIP-C
OCS-SIP-B
OLIB_SBC_OFR

select case when servedIMEI = '' then 0 else 1 end as servedIMEI
        ,accessPointNameNI, count(distinct servedMSISDN)
-- select filePath,servedIMEI,servedMSISDN
from data_zte
where  recordOpeningTime>= toDateTime(:from_v)
        and recordOpeningTime < toDateTime(:to_v)
        and filePath like '%SGSN%'
group by servedIMEI,accessPointNameNI