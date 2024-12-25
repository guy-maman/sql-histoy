

select Orange,sum(call_Duration)/60
from (
      select toDate(eventTimeStamp) Orange,
             topK(answerTime)       answerTime,
             topK(type)             type,
             callReference,
             max(case
                 when incomingTKGPName in
                      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
                       'OLIB_SBC_OFR')
                     then callDuration
                 else 0 end) as      call_Duration,
--              max(callDuration)      call_Duration,
             topK(servedMSISDN)     servedMSISDN,
             topK(callingNumber)    callingNumber,
             topK(calledNumber)     calledNumber,
             topK(roamingNumber)    roamingNumber,
             topK(outgoingTKGPName) outgoingTKGPName,
             topK(incomingTKGPName) incomingTKGP_Name
      from zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and toDayOfMonth(eventTimeStamp) = 1
        and callDuration > 0
--         and incomingTKGPName in
--             ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2',
--              'OLIB_SBC_OFR')
        and callDuration > 0
      group by Orange, callReference
         )
where call_Duration > 0
group by Orange
