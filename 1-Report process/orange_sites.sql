/*
create table default.siteInfo (Operator Nullable(String),siteId String,siteName Nullable(String),technology Nullable(String),county Nullable(String),
                                latitude Nullable(Float64),longitude Nullable(Float64))
    ENGINE = MergeTree() order by siteId;
*/
--site info orange
select arrayElement(arr, 1),
       arrayElement(arr, 2),
       arrayElement(arr, 3),
       arrayElement(arr, 4),
       arrayElement(arr, 5),
       from(
               select splitByChar('-', loc) arr  from (
               select distinct location1 loc
               from mediation.zte
               where toDate(eventTimeStamp) = '2024-07-22' and location1 != ''
               limit 100) a) b;

select /*arrayElement(arr, 1),
       arrayElement(arr, 2),
       arrayElement(arr, 3),*/
       arrayElement(arr, 4) ci,
       arrayElement(arr, 5) sac,
       systemType
       from(
                select  distinct splitByChar('-', location1) arr,systemType
                from    mediation.zte
                where   toDate(eventTimeStamp) = '2024-07-22' and location1 != ''
       );

select          multiIf((systemType) = '1',left(arrayElement(arr, 5),4)
                ,(systemType) = '2',left(arrayElement(arr, 4),4)
                ,(arrayElement(arr, 4))='0',left(arrayElement(arr, 5),4)
                ,(arrayElement(arr, 4))='65535',left(arrayElement(arr, 5),4)
                ,left(arrayElement(arr, 4),4)) loc
       from(
                select  distinct splitByChar('-', location1) arr,systemType
                from    mediation.zte
                where   toStartOfMonth(eventTimeStamp) = '2024-08-01'
                    and location1 != ''
                    and type not in ('MT_SMS_RECORD','MO_SMS_RECORD')
       )
group by loc
order by loc;


select  type, servedMSISDN,arrayElement(arr, 4) ci,arrayElement(arr, 5) sac,systemType,
                multiIf((systemType) = '1',left(arrayElement(arr, 5),4)
                ,(systemType) = '2',left(arrayElement(arr, 4),4)
                ,(arrayElement(arr, 4))='0',left(arrayElement(arr, 5),4)
                ,(arrayElement(arr, 4))='65535',left(arrayElement(arr, 5),4)
                ,left(arrayElement(arr, 4),4)) loc
from (
         select type, servedMSISDN, systemType, splitByChar('-', location1) arr
         from mediation.zte
         where toStartOfMonth(eventTimeStamp) = '2024-08-01'
           and location1 != ''
--            and type not in ('MT_SMS_RECORD','MO_SMS_RECORD')
         )
where   loc not in ('0','1','6553')
order by loc
limit 1000;


-- sites MTN
select arrayElement(arr, 1),
       arrayElement(arr, 2),
       arrayElement(arr, 3),
       arrayElement(arr, 4),
       left(arrayElement(arr, 4),(length(arrayElement(arr, 4))-1)) site
       from(
               select splitByChar('-', loc) arr,loc
               from (
                        select distinct firstCallingLocationInformation loc
                        from mediation.ericsson
                        where toDate(EventDate) = '2024-07-22'
                          and firstCallingLocationInformation != ''
               limit 100) a) b
order by site;

select left(arrayElement(arr, 4),(length(arrayElement(arr, 4))-1)) site--,loc
       from(
               select splitByChar('-', loc) arr,loc
               from (
                        select distinct firstCallingLocationInformation loc
                        from mediation.ericsson
                        where toDate(EventDate) = '2024-07-22'
                          and firstCallingLocationInformation != ''
                        ) a
           ) b
group by site--,loc
order by site;

select distinct firstCallingLocationInformation from mediation.ericsson where toDate(EventDate) = '2024-07-22' and firstCallingLocationInformation != '' order by 1 limit 1000;

select top 48 toStartOfHour(EventDate) date from mediation.ericsson where toYYYYMM(EventDate) = 202409 group by date order by date desc;

select top 10 eventTimeStamp from mediation.zte where toYYYYMM(eventTimeStamp) = 202409 order by eventTimeStamp desc;


-- orange sum duration by site
SELECT
    a.date,
    a.loc,
    b.siteName,
    a.duration,
    a.numberOfCalls
FROM     (
        SELECT
            toDate(eventTimeStamp) AS date,
            multiIf(
                systemType = '1', left(arrayElement(splitByChar('-', location1), 5), 4),
                systemType = '2', left(arrayElement(splitByChar('-', location1), 4), 4),
                arrayElement(splitByChar('-', location1), 4) = '0', left(arrayElement(splitByChar('-', location1), 5), 4),
                arrayElement(splitByChar('-', location1), 4) = '65535', left(arrayElement(splitByChar('-', location1), 5), 4),
                left(arrayElement(splitByChar('-', location1), 4), 4)
            ) AS loc,
            sum(callDuration) / 60 AS duration,
            count() AS numberOfCalls
        FROM mediation.zte
        WHERE
            toDate(eventTimeStamp) = '2024-08-01'
            AND location1 != ''
            AND loc NOT IN ('0', '1', '65535')
            and type not in ('MO_SMS_RECORD','MT_SMS_RECORD')
        GROUP BY date, loc
    ) AS a
LEFT JOIN default.siteInfo b
    ON a.loc = b.siteId and b.Operator = 'ORANGE'
ORDER BY a.date, a.loc;

COMMON_EQUIP_RECORD
HLR_INT_RECORD
INC_GATEWAY_RECORD
MCF_CALL_RECORD
MO_CALL_RECORD
MO_SMS_RECORD
MO_LCS_RECORD
MT_CALL_RECORD
MT_SMS_RECORD
OUT_GATEWAY_RECORD
ROAM_RECORD
TERM_CAMEL_INT_RECORD
SS_ACTION_RECORD
USSD_RECORD
