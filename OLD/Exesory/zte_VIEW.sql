

CREATE VIEW zte_view
AS


select *
from zte
where   eventTimeStamp > toStartOfDay(now() - (86400*60))
    and type in ('INC_GATEWAY_RECORD','MO_CALL_RECORD','MT_CALL_RECORD','OUT_GATEWAY_RECORD','MCF_CALL_RECORD','ROAM_RECORD')


/*select callReference,type,eventTimeStamp,answerTime,callDuration,servedMSISDN,servedIMEI,callingNumber,calledNumber,roamingNumber
        ,incomingTKGPName,outgoingTKGPName
select callReference,min(eventTimeStamp),toDayOfMonth(eventTimeStamp) day,toHour(eventTimeStamp) hour,sum(callDuration) callDuration
from zte
where   eventTimeStamp > toStartOfDay(now() - (86400*30))
    and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR',
                          '', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat','SBC_siptrunk', 'VOIPE_PBX_SIP',
                          'Comium', 'LoneStar', 'MSC_SBC_MTN')
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR',
                            '',  'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS','SBC_FriendnChat','SBC_siptrunk','Comium','LoneStar', 'MSC_SBC_MTN')
    and type in ('INC_GATEWAY_RECORD','MO_CALL_RECORD','MT_CALL_RECORD','OUT_GATEWAY_RECORD','MCF_CALL_RECORD','ROAM_RECORD')
*/
/*select distinct type
from zte
where eventTimeStamp > toStartOfDay(now() - (86400*30))
*/
select  Operator,Direction,Route,CountryName,Date,CallingNumber,CalledNumber,callDuration
from
     (
select  'ORANGE' Operator,'Outgoing' Direction,outgoingTKGPName Route,answerTime Date,
        case when substring(CalledNumber,1,1) = '1' then substring(CalledNumber,1,4)
              else
        (case when CalledNumber = '' then '231' else substring(CalledNumber,1,3)end) end as CountryCode,
        case   when substring(callingNumber,1,2) = '12' then '231' || '' || substring(callingNumber,5)
                else substring(callingNumber,5)
                end as CallingNumber,
        case    when (substring(servedMSISDN,3,3) = '231' or substring(servedMSISDN,1,2) = '18')
                then
                ((case when substring(calledNumber,3,2) = '00' then substring(calledNumber,5) else substring(calledNumber,3) end) || '-' || substring(servedMSISDN,3))
                else substring(servedMSISDN,3) || '-' || (case when substring(calledNumber,3,2) = '00' then substring(calledNumber,5) else substring(calledNumber,3)
                    end) end as CalledNumber,
       callDuration
from    zte_view
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('MCF_CALL_RECORD')
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
order by answerTime
        )any left join
(
    select CountryName, toString(CountryCode) CountryCode from CountryCodes
    )using CountryCode;
