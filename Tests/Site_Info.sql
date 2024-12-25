select type,systemType,location1,location2,location3,calledLocation,callingLocation,outgoingTKGPName
from zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and location1 <> ''
    and type = 'MO_CALL_RECORD'
limit 500;

select  type,count(distinct firstCallingLocationInformation)--,lastCallingLocationInformation
from    ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
--     and firstCallingLocationInformation is not null
--     and type not in ('M_S_ORIGINATING','M_S_TERMINATING','CALL_FORWARDING','M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC')
group by type--,firstCallingLocationInformation,lastCallingLocationInformation
order by type
limit 500

select CGI,TYPE,SITE_NAME,COUNTY,Latitude,Longitude
from
(
select distinct firstCallingLocationInformation CGI
from    ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
)any left join
(select CGI,TYPE,SITE_NAME,COUNTY,Latitude,Longitude
from Site_Info_MTN
) using CGI
order by CGI
