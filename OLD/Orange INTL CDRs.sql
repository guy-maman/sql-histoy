---------- Get CDRs INTL

----------Outgoing INTL

select  callReference,type,answerTime,callDuration,servedMSISDN,callingNumber,calledNumber,roamingNumber,incomingTKGPName,outgoingTKGPName
from    zte
where   /*type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD')
        and */outgoingTKGPName in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
order by answerTime,callReference
;
select  callReference,type,answerTime,callDuration,servedMSISDN,callingNumber,calledNumber,roamingNumber,incomingTKGPName,outgoingTKGPName
    from (
          select callReference,
                 type,
                 answerTime,
                 callDuration,
                 servedMSISDN,
                 callingNumber,
                 calledNumber,
                 roamingNumber,
                 incomingTKGPName,
                 outgoingTKGPName
          from zte
          where type in ('MO_CALL_RECORD')
            and outgoingTKGPName in
                ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
            and eventTimeStamp >= toDateTime(:from_v)
            and eventTimeStamp < toDateTime(:to_v)
            and callDuration > 0
--           order by answerTime, callReference
          union all
          select callReference,
                 type,
                 answerTime,
                 callDuration,
                 servedMSISDN,
                 callingNumber,
                 calledNumber,
                 roamingNumber,
                 incomingTKGPName,
                 outgoingTKGPName
-- select sum(callDuration)/60 Minutes, count() count
          from zte
          where type in ('OUT_GATEWAY_RECORD')
            and outgoingTKGPName in
                ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
            and eventTimeStamp >= toDateTime(:from_v)
            and eventTimeStamp < toDateTime(:to_v)
            and callDuration > 0
--           order by answerTime, callReference
          union all
          select callReference,
                 type,
                 answerTime,
                 callDuration,
                 servedMSISDN,
                 callingNumber,
                 calledNumber,
                 roamingNumber,
                 incomingTKGPName,
                 outgoingTKGPName
          from zte
          where type in ('ROAM_RECORD')
            and outgoingTKGPName in
                ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
            and eventTimeStamp >= toDateTime(:from_v)
            and eventTimeStamp < toDateTime(:to_v)
            and callDuration > 0
          order by answerTime, callReference
          union all
          select callReference,
                 type,
                 answerTime,
                 callDuration,
                 servedMSISDN,
                 callingNumber,
                 calledNumber,
                 roamingNumber,
                 incomingTKGPName,
                 outgoingTKGPName
          from zte
          where type in ('INC_GATEWAY_RECORD')
            and outgoingTKGPName in
                ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
            and eventTimeStamp >= toDateTime(:from_v)
            and eventTimeStamp < toDateTime(:to_v)
            and callDuration > 0
--           order by answerTime, callReference
             )
order by answerTime, callReference
limit 500;

----------Incoming INTL

select  callReference,type,answerTime,callDuration,servedMSISDN,callingNumber,calledNumber,roamingNumber,incomingTKGPName,outgoingTKGPName
from    zte
where   type in ('MT_CALL_RECORD')
        and incomingTKGPName in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
;

select  callReference,type,answerTime,callDuration,servedMSISDN,callingNumber,calledNumber,roamingNumber,incomingTKGPName,outgoingTKGPName
from    zte
where   type in ('INC_GATEWAY_RECORD')
        and incomingTKGPName in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
;

select  callReference
from    zte
where   /*type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD')
        and */outgoingTKGPName in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
group by  answerTime,callReference
;

select  callReference,type,answerTime,callDuration,servedMSISDN,callingNumber,calledNumber,roamingNumber,incomingTKGPName,outgoingTKGPName
from    zte
where   /*type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD')
        and */outgoingTKGPName in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
        and callReference in (select  callReference
                                from    zte
                                where   /*type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD')
                                        and */outgoingTKGPName in
                                            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
                                        and eventTimeStamp >= toDateTime(:from_v)
                                        and eventTimeStamp < toDateTime(:to_v)
                                        and callDuration > 0
                                group by  answerTime,callReference
                                ) AS A
order by answerTime,callReference
;

SELECT  callReference,type,answerTime,callDuration,servedMSISDN,callingNumber,calledNumber,roamingNumber,incomingTKGPName,outgoingTKGPName
FROM
(
select  callReference,type,answerTime,callDuration,servedMSISDN,callingNumber,calledNumber,roamingNumber,incomingTKGPName,outgoingTKGPName
from    zte
where   type in ('OUT_GATEWAY_RECORD')
        and outgoingTKGPName in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
) ANY inner JOIN
(
select  callReference,type,answerTime,callDuration,servedMSISDN,callingNumber,calledNumber,roamingNumber,incomingTKGPName,outgoingTKGPName
from    zte
where   type in ('MO_CALL_RECORD')
        and outgoingTKGPName in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
) USING answerTime,callReference,callDuration
ORDER BY answerTime,callReference
-- LIMIT 100