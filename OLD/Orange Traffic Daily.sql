
/***** All Traffic *****/

select Day,Orange, Minutes from (
select 1 ord,toYYYYMMDD(eventTimeStamp) Day,'On Net' Orange,round(sum(callDuration)/60) Minutes
from zte
where type in ('MO_CALL_RECORD','OUT_GATEWAY_RECORD','ROAM_RECORD','INC_GATEWAY_RECORD','MCF_CALL_RECORD','TERM_CAMEL_INT_RECORD')--type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
group by Day,Orange
union all
select  2 ord,Day,'International Outgoing' Orange,round(sum(Minutes) / 60) Minutes
from (
      select callReference,
             CallType,
             answerTime,
             Minutes,
             servedMSISDN,
             callingNumber,
             calledNumber,
             incomingTKGPName,
             outgoingTKGP_Name,
             Day
      from (
            select answerTime
                 , callReference
                 , callDuration as       Minutes
                 , topK(type)            CallType
                 , max(servedMSISDN)     servedMSISDN
                 , topK(callingNumber)   callingNumber
                 , topK(calledNumber)    calledNumber
                 , max(incomingTKGPName) incomingTKGPName
                 , max(outgoingTKGPName) outgoingTKGP_Name
                 , toYYYYMMDD(eventTimeStamp) Day
            from zte
            where type in ('OUT_GATEWAY_RECORD', 'MO_CALL_RECORD')
                  and outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
                  and eventTimeStamp >= toDateTime(:from_v)
                  and eventTimeStamp < toDateTime(:to_v)
                  and callDuration > 0
            group by answerTime, callReference, callDuration,Day
            union all
            select answerTime
                 , callReference
                 , callDuration as     Minutes
                 , topK(type)          CallType
                 , max(servedMSISDN)   servedMSISDN
                 , topK(callingNumber) callingNumber
                 , topK(calledNumber)  calledNumber
                 , max(incomingTKGPName) incomingTKGPName
                 , max(outgoingTKGPName) outgoingTKGP_Name
                 , toYYYYMMDD(eventTimeStamp) Day
            from zte
            where type in ('ROAM_RECORD')
                  and outgoingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
                  and eventTimeStamp >= toDateTime(:from_v)
                  and eventTimeStamp < toDateTime(:to_v)
                  and callDuration > 0
            group by answerTime, callReference, callDuration,Day
               )
      order by answerTime, callReference
         )group by Day,Orange
union all
select  3 ord,Day,'International Incoming' Orange,round(sum(Minutes) / 60) Minutes
from (
      select callReference,
             CallType,
             answerTime,
             Minutes,
             servedMSISDN,
             callingNumber,
             calledNumber,
             incomingTKGP_Name,
             outgoingTKGP_Name,
             Day
      from (
            select answerTime
                 , callReference
                 , callDuration as       Minutes
                 , topK(type)            CallType
                 , max(servedMSISDN)     servedMSISDN
                 , topK(callingNumber)   callingNumber
                 , topK(calledNumber)    calledNumber
                 , max(incomingTKGPName) incomingTKGP_Name
                 , max(outgoingTKGPName) outgoingTKGP_Name
                 , toYYYYMMDD(eventTimeStamp) Day
            from zte
            where type in ('INC_GATEWAY_RECORD', 'MT_CALL_RECORD')
                  and incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
                  and eventTimeStamp >= toDateTime(:from_v)
                  and eventTimeStamp < toDateTime(:to_v)
                  and callDuration > 0
            group by answerTime, callReference, callDuration,Day
               )
      order by answerTime, callReference
         )group by Day,Orange
union all
select 4 ord,toYYYYMMDD(eventTimeStamp) Day,'MTN To Orange' Orange,round(sum(callDuration) / 60) Minutes
from zte
where type not in ('MT_CALL_RECORD')
    and incomingTKGPName in ('Comium','LoneStar')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
group by Day,Orange
union all
select 5 ord,toYYYYMMDD(eventTimeStamp) Day,'Orange to MTN' Orange,round(sum(callDuration)/60) Minutes
from zte
where type not in ('MO_CALL_RECORD')
    and outgoingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
group by Day,Orange
)
group by ord,Day,Orange, Minutes
order by ord,Day
;