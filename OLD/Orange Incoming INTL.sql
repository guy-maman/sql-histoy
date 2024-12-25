

select  3 ord,'International Incoming',round(sum(Minutes) / 60) Minutes,count() count
from (
      select callReference,
             CallType,
             answerTime,
             Minutes,
             servedMSISDN,
             callingNumber,
             calledNumber,
             incomingTKGP_Name,
             outgoingTKGP_Name
      from (
            select answerTime
                 , callReference
                 , callDuration as       Minutes
                 , topK(type)            CallType
                 , max(servedMSISDN)     servedMSISDN
                 , min(callingNumber)   callingNumber
                 , max(calledNumber)    calledNumber
                 , max(incomingTKGPName) incomingTKGP_Name
                 , max(outgoingTKGPName) outgoingTKGP_Name
            from zte
            where type in ('INC_GATEWAY_RECORD', 'MT_CALL_RECORD')
                  and incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
                  and eventTimeStamp >= toDateTime(:from_v)
                  and eventTimeStamp < toDateTime(:to_v)
                  and callDuration > 0
            group by answerTime, callReference, callDuration
               )
      order by answerTime, callReference
         );

-----------Get CDRs

      select substring(callingNumber,3) calling_Number,
             substring(servedMSISDN,3) called_Number,
             answerTime,
             callDuration,
             incomingTKGP_Name
      from (
            select answerTime
                 , callReference
                 , callDuration
                 , topK(type)            CallType
                 , max(servedMSISDN)     servedMSISDN
                 , max(callingNumber)   callingNumber
                 , max(calledNumber)    calledNumber
                 , max(incomingTKGPName) incomingTKGP_Name
                 , max(outgoingTKGPName) outgoingTKGP_Name
            from zte
            where type in ('INC_GATEWAY_RECORD', 'MT_CALL_RECORD')
                  and incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
                  and eventTimeStamp >= toDateTime(:from_v)
                  and eventTimeStamp < toDateTime(:to_v)
                  and callDuration > 0
            group by answerTime, callReference, callDuration
               )
      order by answerTime, callReference
;







select  3 ord,'International Incoming',round(sum(callDuration)/60)
from    zte
where   type = 'MT_CALL_RECORD'
        and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)







-- select 3 ord,'International Incoming' Orange,round(sum(Minutes) / 60) Minutes
--
-- from (
      select sum(Minutes)/60 Minutes
      from (
                select answerTime date, callReference, callDuration as Minutes
--             select answerTime
--                  , substring(callingNumber, length(callingNumber) - 8) callingNumber
--                  , substring((case when servedMSISDN = '' then calledNumber else servedMSISDN end),
--                              length(case when servedMSISDN = '' then calledNumber else servedMSISDN end) -
--                              8) as                                     calledNumber
--                  ,sum(callDuration) / count() Minutes
            from zte
            where incomingTKGPName in
                  ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482',
                   'Orange-12490')
              and type in ('MT_CALL_RECORD', 'INC_GATEWAY_RECORD')
              and eventTimeStamp >= toDateTime(:from_v)
              and eventTimeStamp < toDateTime(:to_v)
            group by answerTime, callReference, callDuration
               )
--       union all
--       select round(sum(callDuration) / 60) Minutes
--       from zte
--       where type not in ('MT_CALL_RECORD')
--         and incomingTKGPName in
--             ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482',
--              'Orange-12490')
--         and eventTimeStamp >= toDateTime(:from_v)
--         and eventTimeStamp < toDateTime(:to_v)
--          )
;