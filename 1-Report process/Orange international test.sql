-- OPC__SBC1_SIP
-- OPC__SBC2_SIP_PRODUCTION
-- OPC__SBC1_SIP_PRODUCTION

         SELECT callReference,
            if(multiIf(callingNumber like '19%' and substring(callingNumber,3,2) not in ('00','DD'),substring(callingNumber,3),
            callingNumber not like '19%' and substring(callingNumber,5,2) in ('00','DD'),substring(callingNumber,7),
            substring(callingNumber,5)) like '1%',substring(callingNumber,1,4),substring(callingNumber,1,3)) CountryCode,
                answerTime AS Date,
                (callDuration)            AS Duration
         FROM mediation.zte
         WHERE type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD',
                    'MT_CALL_RECORD','INC_GATEWAY_RECORD')
                and toYYYYMM(eventTimeStamp) = (:yyyymm)
                and callDuration > 0
                AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
         GROUP BY Date,callReference,Duration,CountryCode;


select top 1000 filepath,callReference,answerTime,type, servedMSISDN, callingNumber,
           calledNumber, roamingNumber, callDuration, incomingTKGPName,outgoingTKGPName
from mediation.zte
where   toYYYYMMDD(eventTimeStamp) = (:yyyymmdd)
    and callDuration > 0
    and type in ('ROAM_RECORD','MCF_CALL_RECORD','MT_CALL_RECORD','INC_GATEWAY_RECORD')
order by answerTime,callReference;

-- select sum(callDuration)/60
-- from (
select Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,CallDuration callDuration,Route,c.country_name CountryName
from
(
SELECT  'ORANGE' Operator,'3' Direction,
    greatest(t1.eventTimeStamp,t2.eventTimeStamp,t3.eventTimeStamp,t6.eventTimeStamp) AS Date,
    greatest(t1.callReference,t2.callReference,t3.callReference,t6.callReference) as callReference,
    greatest(t1.incomingTKGPName,t2.incomingTKGPName,t3.incomingTKGPName,t6.incomingTKGPName) as Route,
    multiIf(greatest(t1.callingNumber,t2.callingNumber,t3.callingNumber,t6.callingNumber) as b like '1900%',substring(b,5),
        b like '113800%',substring(b,7),b like '113A00%',substring(b,7),b like '11%',substring(b,5),substring(b,3)) CallingNumber,
    substring(if(greatest(t1.servedMSISDN,t2.servedMSISDN,t3.servedMSISDN,t6.servedMSISDN) as a != '',a,
    greatest(t1.calledNumber,t2.calledNumber,t3.calledNumber,t6.calledNumber)),3) CalledNumber,
    multiIf(RoamingNumber !='' and RoamingNumber like '1%',substring(RoamingNumber,1,4),
            RoamingNumber !='' and RoamingNumber not like '1%',substring(RoamingNumber,1,3),
            CallingNumber = '', '999999',CallingNumber like '1%',substring(CallingNumber,1,4),
            substring(CallingNumber,1,3)) CountryCode,
    substring(t6.roamingNumber,5) AS RoamingNumber,
    greatest(t1.callDuration,t2.callDuration,t3.callDuration,t6.callDuration) as CallDuration
FROM
    (SELECT callReference,answerTime,eventTimeStamp, servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
     FROM mediation.zte
     WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
       AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
       AND type = 'INC_GATEWAY_RECORD') t1
FULL OUTER JOIN
    (SELECT callReference,answerTime,eventTimeStamp, servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
     FROM mediation.zte
     WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
       AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
       AND type = 'MT_CALL_RECORD') t2
    ON t1.callReference = t2.callReference and t1.answerTime = t2.answerTime
FULL OUTER JOIN
    (SELECT callReference,answerTime, eventTimeStamp, servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
     FROM mediation.zte
     WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
       AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
       AND type = 'MCF_CALL_RECORD') t3
    ON t1.callReference = t3.callReference and t1.answerTime = t3.answerTime
FULL OUTER JOIN
    (SELECT callReference,answerTime, eventTimeStamp, servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
     FROM mediation.zte
     WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
       AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
       AND type = 'ROAM_RECORD') t6
    ON t1.callReference = t6.callReference and t1.answerTime = t6.answerTime
where (t1.callDuration >0 or t2.callDuration > 0 or t3.callDuration > 0 or t6.callDuration > 0)
    ) as t7
left JOIN
       mediation.country_keys c on toString(t7.CountryCode) = toString(c.country_code)
ORDER BY Date, callReference--);
;
--------------------
-- zte.translatedNumber,zte.connectedNumber,zte.mscAddress,cAMELCallLegInformationconnectedNumber,
-- cAMELCallLegInformationroamingNumber,zte.dialledNumber,gatewayRecordType,

--roam
SELECT  callReference,answerTime,type,
        if(substring(callingNumber,5,2) = '00',substring(callingNumber,7),
          substring(callingNumber,5)) CallingNumber,
        if(substring(servedMSISDN,3,2) = '00',substring(servedMSISDN,5),
          substring(servedMSISDN,3)) CalledNumber,
        if(substring(roamingNumber,3,2)='71','231' || substring(roamingNumber,3),
           substring(roamingNumber,5)) RoamingNumber,
        servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
FROM mediation.zte
WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
    AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
    AND type in ('ROAM_RECORD')--,'MCF_CALL_RECORD','MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and callDuration > 0
-- group by callReference,answerTime
order by callReference,answerTime
limit 500;

create table default.Pre_INTL (Operator Nullable(String),Direction Nullable(String),
    callReference Nullable(String),Date DateTime,CallingNumber Nullable(String),
    CalledNumber Nullable(String),RoamingNumber Nullable(String),callDuration Nullable(Float64),
    Route Nullable(String),CountryCode Nullable(String),CountryName Nullable(String),Type Array(Int32))
    ENGINE = MergeTree() order by Date;

-- select sum(callDuration)/60
-- from (
-- SELECT  'ORANGE' Operator,'3' Direction,callReference,answerTime Date,CallingNumber,
--         if(type = 'INC_GATEWAY_RECORD',called,served) CalledNumber,RoamingNumber,callDuration,
--         incomingTKGPName Route,CountryCode,CountryName
-- from (
SELECT  'ORANGE' Operator,'3' Direction,filepath,hex(callReference) callReference,answerTime,
        multiIf(callingNumber like '19%' and substring(callingNumber,3,2) not in ('00','DD'),substring(callingNumber,3),
            callingNumber not like '19%' and substring(callingNumber,5,2) in ('00','DD'),substring(callingNumber,7),
            substring(callingNumber,5)) CallingNumber,
        if(type = 'INC_GATEWAY_RECORD',
            multiIf(substring(calledNumber,3,2)='00',substring(calledNumber,5),
            calledNumber not like '19' and substring(calledNumber,3,2) in ('77','71'),'231' || substring(calledNumber,3),
            substring(calledNumber,3)) ,
            if(substring(servedMSISDN,3,2)='00',substring(servedMSISDN,5),
            substring(servedMSISDN,3)) ) CalledNumber,
        if(substring(roamingNumber,3,2)='71','',substring(roamingNumber,5)) RoamingNumber,
--         servedMSISDN, callingNumber, calledNumber, roamingNumber, connectedNumber,
        callDuration, incomingTKGPName Route,--,outgoingTKGPName--,callingLocation,mscAddress,isCAMELCall
        if(CallingNumber like '1%',substring(CallingNumber,1,4),
           substring(CallingNumber,1,3)) CountryCode,
        c.country_name CountryName,groupArray(type) Type
FROM mediation.zte a
     left JOIN mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
    AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
    AND type in ('ROAM_RECORD','MCF_CALL_RECORD','MT_CALL_RECORD','INC_GATEWAY_RECORD')
--     and callReference='3430463345334431'
--     and roaming <> ''
    and callDuration > 0
group by callReference,answerTime,CallingNumber,CalledNumber,RoamingNumber,callDuration,
        incomingTKGPName,CountryCode,CountryName,filepath
order by answerTime,callReference;
;
-- limit 500;


select  left(roamingNumber,2) x,
        substring(roamingNumber,3,2) y,
--         substring(roamingNumber,5,2) z,
        count()
from    mediation.zte d
--     join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYear(eventTimeStamp) = (:year)
    and callDuration > 0
--     and x <> '19'
    and type in ('ROAM_RECORD','MCF_CALL_RECORD','MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
group by x,y--,z
order by x,y--,z

select  hex(callReference) callReference,type,answerTime,callDuration,servedMSISDN,callingNumber,calledNumber,connectedNumber,
--         multiIf(/*type = ('ROAM_RECORD') and */substring(callingNumber,5,2) in ('77','88','55'),'231' || substring(callingNumber,5),
--                 /*type = ('ROAM_RECORD') and */substring(callingNumber,5,2) in ('07'),'231' || substring(callingNumber,6),
--         substring(callingNumber,5)) CallingNumber,
--         '' CalledNumber,
        left(roamingNumber,2) x,
        substring(roamingNumber,3,2) y,
        substring(roamingNumber,5,2) z,
        roamingNumber,incomingTKGPName,outgoingTKGPName
from    mediation.zte d
--     join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYear(eventTimeStamp) = (:year)
    and callDuration > 0
    and type in ('ROAM_RECORD','MCF_CALL_RECORD','MT_CALL_RECORD','INC_GATEWAY_RECORD')
  -- ('MO_CALL_RECORD','OUT_GATEWAY_RECORD','ROAM_RECORD','MCF_CALL_RECORD','MT_CALL_RECORD','INC_GATEWAY_RECORD')
--     and x = '1A'
    and y = 'DD'
--     and z='77'
--     and CallingNumber like '231%'
    and incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
-- group by answerTime,callReference,callDuration
order by answerTime,callReference
limit 500;

--orange outgoing
select  'ORANGE' Operator,'4' Direction,hex(callReference) callReference,answerTime Date,type,servedMSISDN,callingNumber,calledNumber,
        multiIf(left((if(type = 'MO_CALL_RECORD',servedMSISDN,callingNumber)) as x,2)
               in ('10','11','12','14') and substring(x,5,2) in ('77','88','55')
                ,'231' || substring(x,5),
                left(x,2) in ('18','19') and  substring(x,3,2) = '00',substring(x,5),
                left(x,2) in ('1A','1C') and  substring(x,3,2) in ('77','88','55'),'231' || substring(x,3),
                substring(x,3)) CallingNumber,
                multiIf(substring((multiIf(roamingNumber <> '',roamingNumber,
                                    type = 'ROAM_RECORD',servedMSISDN,calledNumber)
                ) as z,3,2) = '00',substring(z,5),
                substring(z,3,2) = '07','231' || substring(z,4),
                substring(z,1,4) = '1877', '231' || substring(z,3),
                substring(z,3)) CalledNumber,
                if(roamingNumber <>'',
                (multiIf(substring((if(type = 'ROAM_RECORD',servedMSISDN,calledNumber)) as y,3,2) = '00',substring(y,5),
                substring(y,3,2) = '07','231' || substring(y,4),
                substring(y,1,4) = '1877', '231' || substring(y,3),
                substring(y,3))),'') RoamingNumber,
        callDuration,outgoingTKGPName Route,
        if(CalledNumber like '1%',substring(CalledNumber,1,4),substring(CalledNumber,1,3)) CountryCode,c.country_name CountryName
from    mediation.zte d
    join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYYYYMMDD(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD','OUT_GATEWAY_RECORD')
    and outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
-- group by answerTime,callReference,callDuration,
--          outgoingTKGPName,CallingNumber,CalledNumber,CountryCode,country_name
order by answerTime,callReference;



----------

--orange incoming

select  'ORANGE' Operator,'3' Direction,
        hex(callReference) callReference,answerTime Date,callDuration,type,servedMSISDN,callingNumber,calledNumber,
        multiIf(callingNumber like '1900%',substring(callingNumber,5),
                left(callingNumber,2) ='11' and substring(callingNumber,5,2) ='00',
                substring(callingNumber,7),
                left(callingNumber,2) ='11',substring(callingNumber,5),
                substring(callingNumber,3)) CallingNumber,
        multiIf(substring((if(type = 'INC_GATEWAY_RECORD',calledNumber,servedMSISDN)) as a,3,2) = '00',
        substring(a,5),substring(a,3,2) = '77' and substring(a,1,2) = '1A' ,'231' || substring(a,3),
        substring(a,3)) CalledNumber,
        substring(roamingNumber,5) RoamingNumber,
        if(CallingNumber like '1%',left(CallingNumber,4),left(CallingNumber,3)) CountryCode,
        incomingTKGPName Route,country_name CountryName
from    mediation.zte d
    join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYYYYMMDD(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('ROAM_RECORD','MCF_CALL_RECORD','MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
-- group by callReference,Date,CallingNumber,CalledNumber,/*RoamingNumber,*/callDuration,Route,CountryCode,CountryName
order by Date,callReference;


 /*
-- select sum(callDuration)/60
-- from (
--orange outgoing
select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  'ORANGE' Operator,'4' Direction,hex(callReference) callReference,answerTime Date,
        multiIf(left((if(type = 'MO_CALL_RECORD',servedMSISDN,callingNumber)) as x,2)
               in ('10','11','12','14') and substring(x,5,2) in ('77','88','55')
                ,'231' || substring(x,5),
                left(x,2) in ('18','19') and  substring(x,3,2) = '00',substring(x,5),
                left(x,2) in ('1A','1C') and  substring(x,3,2) in ('77','88','55'),'231' || substring(x,3),
                substring(x,3)) CallingNumber,
--                 multiIf(substring((multiIf(roamingNumber <> '',roamingNumber,
--                                     type = 'ROAM_RECORD',servedMSISDN,calledNumber)
--                 ) as z,3,2) = '00',substring(z,5),
--                 substring(z,3,2) = '07','231' || substring(z,4),
--                 substring(z,1,4) = '1877', '231' || substring(z,3),
--                 substring(z,3))
                multiIf(substring((if(type = 'ROAM_RECORD',servedMSISDN,calledNumber)) as y,3,2) = '00',substring(y,5),
                substring(y,3,2) = '07','231' || substring(y,4),
                substring(y,1,4) = '1877', '231' || substring(y,3),
                substring(y,3)) CalledNumber,
--                 max(if(roamingNumber <>'',
--                 (multiIf(substring((if(type = 'ROAM_RECORD',servedMSISDN,calledNumber)) as y,3,2) = '00',substring(y,5),
--                 substring(y,3,2) = '07','231' || substring(y,4),
--                 substring(y,1,4) = '1877', '231' || substring(y,3),
--                 substring(y,3))),''))
                if(roamingNumber like '1800%',substring(roamingNumber,5),substring(roamingNumber,3)) RoamingNumber,
        callDuration,outgoingTKGPName Route,
--         if(CalledNumber like '1%',substring(CalledNumber,1,4),substring(CalledNumber,1,3))
        if(if(RoamingNumber <>'',RoamingNumber,CalledNumber) as z like '1%',
           substring(z,1,4),substring(z,1,3)) CountryCode,
        c.country_name CountryName
from    mediation.zte d
    join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD','OUT_GATEWAY_RECORD')
    and outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
group by answerTime,callReference,callDuration,RoamingNumber,
         outgoingTKGPName,CallingNumber,CalledNumber,CountryCode,country_name
order by answerTime,callReference);--);


-- select sum(callDuration)/60
-- from (
--orange incoming
select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from (
select  'ORANGE' Operator,'3' Direction,
        hex(callReference) callReference,answerTime Date,callDuration,--type,servedMSISDN,callingNumber,calledNumber,
        multiIf(callingNumber like '1900%',substring(callingNumber,5),
                left(callingNumber,2) ='11' and substring(callingNumber,5,2) ='00',
                substring(callingNumber,7),
                left(callingNumber,2) ='11',substring(callingNumber,5),
                substring(callingNumber,3)) CallingNumber,
        multiIf(substring((if(type = 'INC_GATEWAY_RECORD',calledNumber,servedMSISDN)) as a,3,2) = '00',
        substring(a,5),substring(a,3,2) = '77' and substring(a,1,2) = '1A' ,'231' || substring(a,3),
        substring(a,3)) CalledNumber,
        max(substring(roamingNumber,5)) RoamingNumber,
        if(CallingNumber like '1%',left(CallingNumber,4),left(CallingNumber,3)) CountryCode,
        incomingTKGPName Route,country_name CountryName
from    mediation.zte d
    join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('ROAM_RECORD','MCF_CALL_RECORD','MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
group by callReference,Date,CallingNumber,CalledNumber,/*RoamingNumber,*/callDuration,Route,CountryCode,CountryName
order by Date,callReference);--);


select  left(roamingNumber,2) x,
        substring(roamingNumber,3,2) y,
--         substring(roamingNumber,5,2) z,
        count()
from    mediation.zte d
--     join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYear(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('ROAM_RECORD','MCF_CALL_RECORD','MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
group by x,y--,z
order by x,y--,z
;

select  hex(callReference) callReference,type,answerTime,callDuration,servedMSISDN,callingNumber,calledNumber,
--         multiIf(left(callingNumber,2) <> '19',substring(callingNumber,5),
        multiIf(callingNumber like '1900%',substring(callingNumber,5),
                left(callingNumber,2) ='11' and substring(callingNumber,5,2) ='00',
                substring(callingNumber,7),
                left(callingNumber,2) ='11',substring(callingNumber,5),
                substring(callingNumber,3)) CallingNumber,
        multiIf(substring((if(type = 'INC_GATEWAY_RECORD',calledNumber,servedMSISDN)) as a,3,2) = '00',substring(a,5),
        substring(a,3,2) = '77' and substring(a,1,2) = '1A' ,'231' || substring(a,3),
        substring(a,3)) CalledNumber,
        left(roamingNumber,2) x,
        substring(roamingNumber,3,2) y,
        substring(roamingNumber,5,2) z,
        roamingNumber,incomingTKGPName
from    mediation.zte d
--     join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('ROAM_RECORD','MCF_CALL_RECORD','MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and x = '1A'
    and y <> '71'
--     and z='01'
--     and CallingNumber like '231%'
    and incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
-- group by answerTime,callReference,callDuration
order by answerTime,callReference
;



------------------------------------------------------------------------------------------------



----------------------------------------------------------------
----------------- MT, ROAM & MCF

select sum(callDuration)/60
from (
select Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,CallDuration callDuration,Route,c.country_name CountryName
from
(
SELECT  'ORANGE' Operator,'3' Direction,
    greatest(t1.eventTimeStamp,t2.eventTimeStamp,t3.eventTimeStamp,t6.eventTimeStamp) AS Date,
    greatest(t1.callReference,t2.callReference,t3.callReference,t6.callReference) as callReference,
    greatest(t1.incomingTKGPName,t2.incomingTKGPName,t3.incomingTKGPName,t6.incomingTKGPName) as Route,
    multiIf(greatest(t1.callingNumber,t2.callingNumber,t3.callingNumber,t6.callingNumber) as b like '1900%',substring(b,5),
        b like '113800%',substring(b,7),b like '113A00%',substring(b,7),b like '11%',substring(b,5),substring(b,3)) CallingNumber,
    substring(if(greatest(t1.servedMSISDN,t2.servedMSISDN,t3.servedMSISDN,t6.servedMSISDN) as a != '',a,
    greatest(t1.calledNumber,t2.calledNumber,t3.calledNumber,t6.calledNumber)),3) CalledNumber,
    multiIf(RoamingNumber !='' and RoamingNumber like '1%',substring(RoamingNumber,1,4),
            RoamingNumber !='' and RoamingNumber not like '1%',substring(RoamingNumber,1,3),
            CallingNumber = '', '999999',CallingNumber like '1%',substring(CallingNumber,1,4),
            substring(CallingNumber,1,3)) CountryCode,
    substring(t6.roamingNumber,5) AS RoamingNumber,
    greatest(t1.callDuration,t2.callDuration,t3.callDuration,t6.callDuration) as CallDuration
FROM
    (SELECT callReference,answerTime,eventTimeStamp, servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
     FROM mediation.zte
     WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
       AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
       AND type = 'INC_GATEWAY_RECORD') t1
FULL OUTER JOIN
    (SELECT callReference,answerTime,eventTimeStamp, servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
     FROM mediation.zte
     WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
       AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
       AND type = 'MT_CALL_RECORD') t2
    ON t1.callReference = t2.callReference and t1.answerTime = t2.answerTime
FULL OUTER JOIN
    (SELECT callReference,answerTime, eventTimeStamp, servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
     FROM mediation.zte
     WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
       AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
       AND type = 'MCF_CALL_RECORD') t3
    ON t1.callReference = t3.callReference and t1.answerTime = t3.answerTime
FULL OUTER JOIN
    (SELECT callReference,answerTime, eventTimeStamp, servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
     FROM mediation.zte
     WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
       AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
       AND type = 'ROAM_RECORD') t6
    ON t1.callReference = t6.callReference and t1.answerTime = t6.answerTime
where (t1.callDuration >0 or t2.callDuration > 0 or t3.callDuration > 0 or t6.callDuration > 0)
    ) as t7
left JOIN
       mediation.country_keys c on toString(t7.CountryCode) = toString(c.country_code)
ORDER BY Date, callReference);

select *
from default.INTL
where toYYYYMM(Date) = 202410
  and Operator = 'ORANGE'
  and Direction = '4'
order by Date,callReference,callDuration

select type,answerTime,servedMSISDN,callingNumber,calledNumber,callDuration,incomingTKGPName,outgoingTKGPName
from mediation.zte
where toYYYYMMDD(answerTime) = 20241003
--     and servedMSISDN like '%776777000'
    and (callingNumber like '%777797777' or servedMSISDN like '%777797777')
order by answerTime
;

select * from mediation.orange_trunk_groups;
772867936



