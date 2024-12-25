

select  date,CCR_On_net,CCR_Off_net,CCR_INTL
from    (

select  date,CCR_On_net,CCR_Off_net
from    (
---------- On net

select toDate(eventTimeStamp) date, round(sum(case when causeForTerm in ('1','2','3','4') then 1 else 0 end)
        / sum(case when causeForTerm in ('0') then 1 else 0 end),2) CCR_On_net
from    zte
where   type = 'MO_CALL_RECORD'
    	and incomingTKGPName in
          ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat',
           'SBC_siptrunk', 'VOIPE_PBX_SIP', 'OCS-SIP-A', 'OCS-SIP-B', 'OCS-SIP-C', 'OCS-SIP-D')
        and outgoingTKGPName in
            ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat',
             'SBC_siptrunk', 'VOIPE_PBX_SIP', 'OCS-SIP-A', 'OCS-SIP-B', 'OCS-SIP-C', 'OCS-SIP-D')
		and toYear(eventTimeStamp) = (:year)
		and toMonth(eventTimeStamp) = (:month)
		and toHour(eventTimeStamp) = 20
group by date
order by date) any left join
(

--------- Off net

select toDate(eventTimeStamp) date, round(sum(case when causeForTerm in ('1','2','3','4') then 1 else 0 end)
        / sum(case when causeForTerm in ('0') then 1 else 0 end),2) CCR_Off_net
from    zte
where   type = 'MO_CALL_RECORD'
    	and outgoingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
		and toYear(eventTimeStamp) = (:year)
		and toMonth(eventTimeStamp) = (:month)
		and toHour(eventTimeStamp) = 20
group by date
order by date)  using  date
        ) any left join
        (
---------- INTL

select toDate(eventTimeStamp) date, round(sum(case when causeForTerm in ('1','2','3','4') then 1 else 0 end)
        / sum(case when causeForTerm in ('0') then 1 else 0 end),2) CCR_INTL
from    zte
where   type = 'MO_CALL_RECORD'
		and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
		and toYear(eventTimeStamp) = (:year)
		and toMonth(eventTimeStamp) = (:month)
		and toHour(eventTimeStamp) = 20
group by date
order by date)  using date