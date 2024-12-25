select * from s_ericsson limit 1000;

----MTN-----
select left(callingPartyNumber,2), count() from s_ericsson group by left(callingPartyNumber,2);
select left(callingPartyNumber,4), count() from s_ericsson where callingPartyNumber like '14%' group by left(callingPartyNumber,4);

select callingPartyNumber,translatedNumber,outgoingRoute,incomingRoute from s_ericsson where callingPartyNumber like '1477%'
group by left(callingPartyNumber,4);

/*
calling
11 - INTL Format
14 - national

*/


select  callingPartyNumber,
        translatedNumber,
        toUnixTimestamp(chargeableDuration)
from s_ericsson limit 100;



----Orange----

18 - Local
19 - Internation format may be local and international
1E - 4 SMSs (Not relevant)
0E - short numnber 11 SMS (Not relevant)
08 - short numebr 2 SMSs (Not relevant)

