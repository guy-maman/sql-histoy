

select top 500 originatingAddress,sourceAccountId,numberOfAttempts,totalParts,currentPart,errorCode,timeSent,timeDelivered
from mediation.mtn_sms
where sourceAccountId <> '0';

select currentPart,totalParts--,errorCode,timeSent,timeDelivered
from mediation.mtn_sms
where sourceAccountId <> '0'
group by totalParts, currentPart
order by totalParts, currentPart

select finalDeliveryStatus
from mediation.mtn_sms
where sourceAccountId <> '0'
group by finalDeliveryStatus
order by finalDeliveryStatus
;

select top 1000* from mediation.mtn_ussd_cdr;

select distinct type from mediation.ericsson
where toYYYYMM(EventDate) = 202411;

select top 500*
from mediation.ericsson
where toYYYYMM(EventDate) = 202411
    and type = 'M_S_ORIGINATING_SMS_IN_MSC';

M_S_ORIGINATING_SMS_IN_MSC
M_S_TERMINATING_SMS_IN_MSC