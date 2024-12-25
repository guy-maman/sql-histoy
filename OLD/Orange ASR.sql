
/***** All Traffic ASR*****/

select Orange, ASR from (
select 1 ord,'On Net' Orange
       ,sum(case when callDuration <> 0 then 1 else 0 end)/count() as ASR
from zte
where type in ('MO_CALL_RECORD','OUT_GATEWAY_RECORD','ROAM_RECORD','INC_GATEWAY_RECORD','MCF_CALL_RECORD','TERM_CAMEL_INT_RECORD')--type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
union all
select 2 ord,'International Outgoing' Orange,sum(case when callDuration <> 0 then 1 else 0 end)/count() as ASR
from zte
where type in ('OUT_GATEWAY_RECORD','ROAM_RECORD','INC_GATEWAY_RECORD','MCF_CALL_RECORD','TERM_CAMEL_INT_RECORD')
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
union all
select 3 ord,'International Incoming' Orange,sum(success)/sum(count)  ASR
from (
      select success ,count
      from (
            select answerTime
                 , substring(callingNumber, length(callingNumber) - 8) callingNumber
                 , substring((case when servedMSISDN = '' then calledNumber else servedMSISDN end),
                             length(case when servedMSISDN = '' then calledNumber else servedMSISDN end) -
                             8) as                                     calledNumber
                 ,sum(case when callDuration <> 0 then 1 else 0 end) success,count() count
            from zte
            where incomingTKGPName in
                  ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482',
                   'Orange-12490')
              and type in ('MT_CALL_RECORD', 'INC_GATEWAY_RECORD')
              and eventTimeStamp >= toDateTime(:from_v)
              and eventTimeStamp < toDateTime(:to_v)
            group by answerTime, callingNumber, calledNumber
               )
      union all
      select sum(case when callDuration <> 0 then 1 else 0 end) success,count() count
      from zte
      where type not in ('MT_CALL_RECORD', 'INC_GATEWAY_RECORD')
        and incomingTKGPName in
            ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482',
             'Orange-12490')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
         )
union all
select 4 ord,'Incoming from MTN' Orange,sum(case when callDuration <> 0 then 1 else 0 end)/count() as ASR
from zte
where type not in ('MT_CALL_RECORD')
    and incomingTKGPName in ('Comium','LoneStar')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
union all
select 5 ord,'Outgoing to MTN' Orange,sum(case when callDuration <> 0 then 1 else 0 end)/count() as ASR
from zte
where type not in ('MO_CALL_RECORD')
    and outgoingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >= toDateTime(:from_v)
    and eventTimeStamp < toDateTime(:to_v)
) order by ord
;