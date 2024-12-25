
/***** All Traffic *****/

select des, minuts from (
select 1 ord,'On Net' des,round(sum(callDuration)/60) minuts from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
union all
select 2 ord,'International Outgoing' des,round(sum(callDuration)/60) as minuts from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
union all
select 3 ord,'International Incoming',round(sum(callDuration)/60) from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
union all
select 4 ord,'Incoming from MTN',round(sum(callDuration)/60) from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
union all
select 5 ord,'Outgoing to MTN',round(sum(callDuration)/60) from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
) order by ord
;

/******* Incoming INTL ********/

select  toYYYYMMDD(eventTimeStamp) date
        ,case when callingNumber = '' then callingNumber else substring(callingNumber,5) end as CallingNumber
        ,substring(servedMSISDN,3) CalledNumber
        ,answerTime,releaseTime,callDuration,incomingTKGPName Trunk
        ,case when servedMSISDN not like '1923177%' then 'Inbound Roaming' else 'Local' end as Comment
from zte
where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    and eventTimeStamp >= toDateTime('2019-04-01 00:00:00')
    and eventTimeStamp < toDateTime('2019-05-01 00:00:00')
    and callDuration>0
order by answerTime;

/******* Outgoing INTL ********/

select  toYYYYMMDD(eventTimeStamp) date
        ,substring(servedMSISDN,3) CallingNumber
        ,substring(calledNumber,3) CalledNumber
--         ,case when callingNumber = '' then callingNumber else substring(callingNumber,2) end as CalledNumber
        ,answerTime,releaseTime,callDuration,outgoingTKGPName Trunk
        ,case when servedMSISDN not like '1923177%' then 'Inbound Roaming' else 'Local' end as Comment
from zte
where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    and eventTimeStamp >= toDateTime('2019-04-01 00:00:00')
    and eventTimeStamp < toDateTime('2019-05-01 00:00:00')
    and callDuration>0
order by answerTime;



/*
select servedMSISDN,calledNumber
--        left(calledNumber,3),count()
from zte
where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    and eventTimeStamp >= toDateTime('2019-04-01 00:00:00')
    and eventTimeStamp < toDateTime('2019-05-01 00:00:00')
    and callDuration>0
    and left(calledNumber,2) = '18'
--     and left(calledNumber,4) not like '1900'
-- group by left(calledNumber,3)
limit 100;*/