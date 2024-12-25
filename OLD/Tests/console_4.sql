select type,callingPartyNumber,outgoingRoute,incomingRoute,internalCauseAndLoc,faultCode,inMarkingOfMS,subscriptionType
        ,mscAddress,originatingAddress,destinationAddress,translatedNumber,originalCalledNumber
from s_ericsson where type = 'M_S_ORIGINATING_SMS_IN_MSC' limit 100;

select * from s_ericsson where type in ('M_S_TERMINATING_SMS_IN_MSC','M_S_ORIGINATING_SMS_IN_MSC') limit 1000;


M_S_TERMINATING_SMS_IN_MSC
M_S_ORIGINATING_SMS_IN_MSC
