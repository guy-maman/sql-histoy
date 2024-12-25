--EricssonSearchByNumberBetweenDate

select  rowNumberInAllBlocks() id,types,start_date,end_date,calling_number,called_number,IMEI,call_duration
from (
select  'Outgoing' types,
		substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12) start_date,
		substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(chargeableDuration), 12) end_date,
        substring(callingPartyNumber, 3) calling_number
 	    ,case   when calledPartyNumber like '120%' and substring(calledPartyNumber, 1, 5) not in ('12055', '12077', '12088')
             	then substring(calledPartyNumber, 6)
             	else substring(calledPartyNumber, 3) end as called_number
 	    ,callingSubscriberIMEI IMEI
        ,toUnixTimestamp(chargeableDuration) call_duration
from 	ericsson
where	EventDate >= toDateTime(:startDate)
		and EventDate <= toDateTime(:endDate)
		and type in ('M_S_ORIGINATING')
		and callingPartyNumber like (:phoneNumber)
union all
select  'Incoming' types,
		substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12) start_date,
		substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(chargeableDuration), 12) end_date,
        substring(callingPartyNumber, 3) calling_number
 	    ,substring(calledPartyNumber, 3) called_number
 	    ,calledSubscriberIMEI IMEI
        ,toUnixTimestamp(chargeableDuration) call_duration
from 	ericsson
where	EventDate >= toDateTime(:startDate)
		and EventDate <= toDateTime(:endDate)
		and type in ('M_S_TERMINATING')
		and calledPartyNumber like (:phoneNumber)
)order by start_date,end_date

--OrangeSearchByNumberBetweenDate

select rowNumberInAllBlocks() id,types,start_date,end_date,call_duration,calling_number,called_number,IMEI
from (
select  'Outgoing' types, answerTime start_date,releaseTime end_date,callDuration call_duration,
        substring(servedMSISDN,3) calling_number,substring(dialledNumber,3) called_number,servedIMEI IMEI
from 	zte
where	type in ('MO_CALL_RECORD')
	and eventTimeStamp >= toDateTime(:startDate)
	and eventTimeStamp <= toDateTime(:endDate)
	and (servedMSISDN like (:phoneNumber))
union all
select  'Incoming' types, answerTime start_date,releaseTime end_date,callDuration call_duration,
        substring(callingNumber,5) calling_number,substring(servedMSISDN,3) called_number,servedIMEI IMEI
from 	zte
where	type in ('MT_CALL_RECORD')
	and eventTimeStamp >= toDateTime(:startDate)
	and eventTimeStamp <= toDateTime(:endDate)
	and (servedMSISDN like (:phoneNumber))
) order by  start_date