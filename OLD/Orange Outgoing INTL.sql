

select  'International Outgoing' Orange,round(sum(Minutes) / 60) Minutes,count() count
from (
      select callReference,
             CallType,
             answerTime,
             Minutes,
             servedMSISDN,
             callingNumber,
             calledNumber,
             incomingTKGPName,
             outgoingTKGP_Name
      from (
            select answerTime
                 , callReference
                 , callDuration as       Minutes
                 , topK(type)            CallType
                 , max(servedMSISDN)     servedMSISDN
                 , max(callingNumber)   callingNumber
                 , max(calledNumber)    calledNumber
                 , max(incomingTKGPName) incomingTKGPName
                 , max(outgoingTKGPName) outgoingTKGP_Name
            from zte
            where type in ('OUT_GATEWAY_RECORD', 'MO_CALL_RECORD')
                  and outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
                  and eventTimeStamp >= toDateTime(:from_v)
                  and eventTimeStamp < toDateTime(:to_v)
                  and callDuration > 0
            group by answerTime, callReference, callDuration
            union all
            select answerTime
                 , callReference
                 , callDuration as     Minutes
                 , topK(type)          CallType
                 , max(servedMSISDN)   servedMSISDN
                 , max(callingNumber) callingNumber
                 , max(calledNumber)  calledNumber
                 , max(incomingTKGPName) incomingTKGPName
                 , max(outgoingTKGPName) outgoingTKGP_Name
            from zte
            where type in ('ROAM_RECORD')
                  and outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
                  and eventTimeStamp >= toDateTime(:from_v)
                  and eventTimeStamp < toDateTime(:to_v)
                  and callDuration > 0
            group by answerTime, callReference, callDuration
               )
      order by answerTime, callReference
         );


------------Get CDRs

      select substring(servedMSISDN,3) calling_Number,
             substring(calledNumber,3) called_Number,
             answerTime,
             callDuration,
             outgoingTKGP_Name
      from (
            select answerTime
                 , callReference
                 , callDuration
                 , topK(type)            CallType
                 , max(servedMSISDN)     servedMSISDN
                 , max(callingNumber)   callingNumber
                 , max(calledNumber)    calledNumber
                 , max(incomingTKGPName) incomingTKGPName
                 , max(outgoingTKGPName) outgoingTKGP_Name
            from zte
            where type in ('OUT_GATEWAY_RECORD', 'MO_CALL_RECORD')
                  and outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
                  and eventTimeStamp >= toDateTime(:from_v)
                  and eventTimeStamp < toDateTime(:to_v)
                  and callDuration > 0
            group by answerTime, callReference, callDuration
            union all
            select answerTime
                 , callReference
                 , callDuration
                 , topK(type)          CallType
                 , max(servedMSISDN)   servedMSISDN
                 , max(callingNumber) callingNumber
                 , max(calledNumber)  calledNumber
                 , max(incomingTKGPName) incomingTKGPName
                 , max(outgoingTKGPName) outgoingTKGP_Name
            from zte
            where type in ('ROAM_RECORD')
                  and outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
                  and eventTimeStamp >= toDateTime(:from_v)
                  and eventTimeStamp < toDateTime(:to_v)
                  and callDuration > 0
            group by answerTime, callReference, callDuration
               )
      order by answerTime, callReference
;









select 'International Outgoing' Orange,round(sum(Minutes) / 60) Minutes--,count() count
from (
      select  sum(Minutes)*1 as Minutes--,count() count
      from (
            select answerTime date, callReference, callDuration as Minutes
            from zte
            where /*type in ('OUT_GATEWAY_RECORD', 'MO_CALL_RECORD')
              and */outgoingTKGPName in
                  ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
              and eventTimeStamp >= toDateTime(:from_v)
              and eventTimeStamp < toDateTime(:to_v)
              and callDuration > 0
            group by date, callReference,callDuration
               )
      union all
      select  sum(callDuration)*1 as Minutes
      from zte
      where type in ('ROAM_RECORD')
        and outgoingTKGPName in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
         )
;

select 'International Outgoing' Orange,round(sum(Minutes) / 60) Minutes
from (
      select sum(callDuration) as Minutes
      from zte
      where type in ('OUT_GATEWAY_RECORD')
        and outgoingTKGPName in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
      union all
      select sum(callDuration)/60 as Minutes
      from zte
      where type in ('ROAM_RECORD')
--         and outgoingTKGPName in
--             ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
      );


--       union all
--       select sum(callDuration) as Minutes
--       from zte
--       where type in ('OUT_GATEWAY_RECORD')
--         and outgoingTKGPName in
--             ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
--         and eventTimeStamp >= toDateTime(:from_v)
--         and eventTimeStamp < toDateTime(:to_v)
--         and incomingTKGPName <> ''
--         and callDuration > 0
--          );






