select /*incomingTKGP_Name,*/sum(call_Duration)/60 callDuration
from (
      select min(answerTime) answerTime
           , callReference--,type
           , max(callDuration) call_Duration
           , topK(filepath) file_path
           , topK(type)             CallType
           , topK(servedMSISDN)     served_MSISDN
           , topK(callingNumber)    calling_Number
           , topK(calledNumber)     called_Number
--      , translatedNumber
     , max(connectedNumber)
     , max(roamingNumber)
           , max(incomingTKGPName) incomingTKGP_Name
           , max(outgoingTKGPName) outgoingTKGP_Name
--             ,servedMSISDN
--             ,callingNumber
--             ,calledNumber
--             ,connectedNumber
--             ,roamingNumber
--             ,incomingTKGPName
--             ,outgoingTKGPName
      from zte
      where type in
                    ('MO_CALL_RECORD',
                        'MT_CALL_RECORD',
                        'INC_GATEWAY_RECORD',
                        'OUT_GATEWAY_RECORD',
                        'MCF_CALL_RECORD',
                        'ROAM_RECORD')
        and outgoingTKGPName in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
        and (servedMSISDN like (:phoneNumber) or callingNumber like (:phoneNumber)
                 or calledNumber like (:phoneNumber) or translatedNumber like (:phoneNumber) or routingNumber like (:phoneNumber))
      group by filepath, callReference--, callDuration
order by filepath,answerTime,callReference --,answerTime,callDuration,type
         )--group by incomingTKGP_Name
limit 500;

select /*incomingTKGP_Name,*/sum(call_Duration)/60 callDuration,count()
from (
      select callReference,answerTime
--            , topK(answerTime)    answer_Time
           , topK(type)          CallType
           , topK(filepath)      file_path
           , max(callDuration)   call_Duration
--            , topK(servedMSISDN)     served_MSISDN
           , topK(callingNumber) calling_Number
           , topK(calledNumber)  called_Number
--            , topK(connectedNumber)  connected_Number
--            , topK(roamingNumber)    roaming_Number
           , count()             count
      from zte
      where type in
            ('MO_CALL_RECORD',
             'MT_CALL_RECORD',
             'INC_GATEWAY_RECORD',
             'OUT_GATEWAY_RECORD',
             'MCF_CALL_RECORD',
             'ROAM_RECORD')
        and incomingTKGPName in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
             'OLIB_SBC_OFR')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
--         and  like '%,%'
      group by answerTime, callReference
      order by count desc, callReference
         )
;


select toYYYYMM(eventTimeStamp) Month,incomingTKGPName
from zte
where eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
group by Month,incomingTKGPName
order by Month