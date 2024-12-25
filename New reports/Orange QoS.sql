
select  date,ASR_On_net,ASR_Off_net,ASR_INTL,ACD_On_net,ACD_Off_net,ACD_INTL
from    (

select  date,ASR_On_net,ASR_Off_net,ASR_INTL
from    (

select  date,ASR_On_net,ASR_Off_net
from    (
---------- On net

select toDate(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),2) ASR_On_net
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
-- 		and toHour(eventTimeStamp) = 20
group by date
order by date) any left join
(

--------- Off net

select  toDate(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),2) ASR_Off_net
from    zte
where   type = 'MO_CALL_RECORD'
    	and outgoingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
		and toYear(eventTimeStamp) = (:year)
		and toMonth(eventTimeStamp) = (:month)
-- 		and toHour(eventTimeStamp) = 20
group by date
order by date)  using  date
        ) any left join
        (
---------- INTL

select  toDate(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),2) ASR_INTL
from    zte
where   type = 'MO_CALL_RECORD'
		and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
		and toYear(eventTimeStamp) = (:year)
		and toMonth(eventTimeStamp) = (:month)
-- 		and toHour(eventTimeStamp) = 20
group by date
order by date)  using date
        ) any left join

------------------------------------------------------ACD

(
select  date,ACD_On_net,ACD_Off_net,ACD_INTL
from    (

select  date,ACD_On_net,ACD_Off_net
from    (
---------- On net

select toDate(eventTimeStamp) date, round(round(count() / round(sum(callDuration) / 60),2)*60) ACD_On_net
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
		and callDuration > 0
-- 		and toHour(eventTimeStamp) = 20
group by date
order by date) any left join
(

--------- Off net

select  toDate(eventTimeStamp) date, round(round(count() / round(sum(callDuration) / 60),2)*60) ACD_Off_net
from    zte
where   type = 'MO_CALL_RECORD'
    	and outgoingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
		and toYear(eventTimeStamp) = (:year)
		and toMonth(eventTimeStamp) = (:month)
		and callDuration > 0
-- 		and toHour(eventTimeStamp) = 20
group by date
order by date)  using  date
        ) any left join
        (
---------- INTL

select  toDate(eventTimeStamp) date, round(round(count() / round(sum(callDuration) / 60),2)*60) ACD_INTL
from    zte
where   type = 'MO_CALL_RECORD'
		and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
		and toYear(eventTimeStamp) = (:year)
		and toMonth(eventTimeStamp) = (:month)
		and callDuration > 0
-- 		and toHour(eventTimeStamp) = 20
group by date
order by date)  using date
)  using date