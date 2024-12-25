select left(destinationNumber,2) Prefix ,count()
from zte
where type = 'MO_SMS_RECORD'
        and left(destinationNumber,2)  in ('18','19')
        and eventTimeStamp >= toDateTime('2019-04-01 00:00:00')
        and eventTimeStamp < toDateTime('2019-05-01 00:00:00')
        and destinationNumber not like '18231%' and destinationNumber not like '1808%'
        and destinationNumber not like '1805%' and destinationNumber not like '1807%'
        and destinationNumber not like '19231%' and destinationNumber not like '1800231%'
        and destinationNumber not like '1900231%'
        and length(destinationNumber) >10
group by Prefix
limit 100;


select * --servedMSISDN,destinationNumber
from zte
where type = 'MO_SMS_RECORD'
        and left(destinationNumber,2)  in ('18','19')
        and eventTimeStamp >= toDateTime('2019-04-01 00:00:00')
        and eventTimeStamp < toDateTime('2019-05-01 00:00:00')
        and destinationNumber not like '18231%' and destinationNumber not like '1808%'
        and destinationNumber not like '1805%' and destinationNumber not like '1807%'
        and destinationNumber not like '19231%' and destinationNumber not like '1800231%'
        and length(destinationNumber) >10
limit 100;

-- select * from ericsson