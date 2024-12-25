
-- create table mediation.Orange_Daily (Date DateTime,Call_Type String,callDuration int)
-- ENGINE = Memory;

------------------------------------MTN FilePath-------------------------------------
------chsLog
select substring(filePath,29) chsLog,max(recordOpeningTime) date, (splitByChar('_', substring(filePath,36))[-2]) seq
-- (splitByChar('_', substring(filePath,36))[-1]) date
--     ,(splitByChar('.', filePath)[-1]) sa,(splitByChar('_', substring(filePath,36))[-2]) ba
from mediation.data_ericsson
      where toYear(recordOpeningTime) = (:year)
        and toMonth(recordOpeningTime) = (:month)
    and filePath like '%chsLog%'
   group by filePath,seq
order by date,seq;

------LIMO
select substring(filePath,30) LIMO,substring(filePath,41,14) date,substring(filePath,56)  seq
-- select substring(filePath,30) LIMO,max(recordOpeningTime) date, substring(filePath,56) seq--,filePath
--      ,toUInt32OrZero(substring((splitByChar('/', filePath)[-1]),12,14)) sequence
--         ,(splitByChar('/', filePath)[-1]) sequence
from mediation.data_ericsson
      where toYear(recordOpeningTime) = (:year)
        and toMonth(recordOpeningTime) = (:month)
    and filePath like '%LIMO%'
group by LIMO,seq,date--,sequence
order by date,seq;

----MBC 1
select substring(filepath,24,23) MBC1,max(EventDate)/*substring(filepath,33,14)*/ date, substring(filepath,27,5) seq,mscIdentification
from mediation.ericsson
where toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
--         and toDayOfMonth(EventDate) = (:day)
        and length(filepath) <> 46
        and mscIdentification <> ''
--         filepath like '%VTF10003_20241023175046%'
group by MBC1,seq,mscIdentification--,date
order by date,seq;

-----MBC 2
select substring(filepath,24,23) MBC2,max(EventDate)/*substring(filepath,33)*/ date, substring(filepath,27,5) seq,mscIdentification
from mediation.ericsson
where toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
--         and toDayOfMonth(EventDate) = (:day)
        and length(filepath) = 46
        and mscIdentification <> ''
group by MBC2,seq,mscIdentification--,date
order by date,seq;

-- select top 10 EventDate,dateForStartOfCharge,timeForStartOfCharge
-- from mediation.ericsson
-- where toYear(EventDate) = 2024
--         and filepath like '%VTF10002_20241023175046%'
;

-- select *
-- from mediation.ericsson
-- where toYear(EventDate) = (:year)
--         and toMonth(EventDate) = (:month)
-- limit 10
-------MBC 1&2
/*
select /*substring(filepath,24) FP1,*/substring(filepath,24,23) FP,substring(filepath,33,14) date,substring(filepath,27,5) seq,mscIdentification--,count() x
from mediation.ericsson
where toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
--         and toDayOfMonth(EventDate) = (:day)
        and mscIdentification <> ''
        and filepath like '%VTF17085_20221231173448%'
group by FP,seq,mscIdentification,date
order by mscIdentification,date,seq
;

select top 3 *
from mediation.ericsson
where toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
        and filepath like '%VTF14321_20230105124618%'
--         and length(filepath) <> 46
        and mscIdentification = ''

*/
-- select count()--dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge,filepath,callingPartyNumber,calledPartyNumber
-- from   mediation.ericsson
-- where toYear(EventDate) = (:year)
--         and toMonth(EventDate) = (:month)
--         and substring(filepath,24,23) = 'VTF13326_20210704090755'
-- order by dateForStartOfCharge,timeForStartOfCharge
-- limit 500;



---------------------------------------Orange FilePath------------------------------------------------
-- MSC
--MSC1
select  if(filepath like '%MSC%',substring(filepath,19,16),substring(filepath,19,17)) FileName,
        if(filepath like '%MSC%',substring(filepath,22,8),substring(filepath,23,8)) date,
        if(filepath like '%MSC%',substring(filepath,30,5),substring(filepath,31,5)) seq
--     substring(filepath,19,16) FileName, max(eventTimeStamp) date,substring(filepath,30,5) seq
from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
--     and filepath like '%MSC2024091819087.dat%'
group by FileName,seq,filepath
order by FileName,date,seq;

-- GPRS
select substring(filePath,24,23) FileName,max(recordOpeningTime) date,substring(filePath,37,5) seq
from mediation.data_zte
      where toYear(recordOpeningTime) = (:year)
        and toMonth(recordOpeningTime) = (:month)
--     and filePath like '%GGSN_2022091287853.dat%'
group by FileName,seq
order by date,seq;

/*-------Orange

select distinct(incomingTKGPName)
from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)

select callReference,type,eventTimeStamp,servedMSISDN,callingNumber,calledNumber,incomingTKGPName,outgoingTKGPName,mscAddress
from mediation.zte
      where toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
--         and toDayOfMonth(eventTimeStamp) = 2
        and callReference in ('E1D6B4F3','E0F4D050')
        and incomingTKGPName in ('OCS-SIP-A')
        limit 500;

""
BICS-4193
BICS-4194
CALL_CENTER
IVR1_SERV1
IVR_OBD_SERV2
LEC_PBX
LoneStar
MSC_SBC_MTN
OCI_ASSB
OCI_KM4
OCS-SIP-A
OCS-SIP-C
OCS-SIP-D
OLIB_SBC_OFR
Orange-12490
Religious_Service
SBC_FriendnChat
US AMBASY
VOIPE_PBX_SIP
*/

/*
select filepath path,toUInt32(substring((splitByChar('/', filepath)[-1]),4,5)) sequence,max(EventDate) date
from ericsson
where   toYear(dateForStartOfCharge) = (:year)
        and toMonth(dateForStartOfCharge) = (:month)
	    and filepath like '%VTF%'
	    and length(filepath) = 48
group by filepath
order by date,sequence;

select filepath path,toUInt32(substring((splitByChar('/', filepath)[-1]),4,5)) sequence,max(EventDate) date
from ericsson
where   EventDate >=  toDateTime(:dateFrom)
	and EventDate <= toDateTime(:dateTo)
	and filepath like '%VTF%'
	and length(filepath) = 46
group by filepath
order by date,sequence

select filePath path,toUInt32OrZero(substring((splitByChar('/', filePath)[-1]),27,5)) sequence,max(recordOpeningTime) date
from data_ericsson
where recordOpeningTime >= toDateTime(:dateFrom)
	and recordOpeningTime < toDateTime(:dateTo)
	and filePath like '%LIM%'
group by filePath
order by date,sequence


select filepath path,toUInt32(substring(filepath,30,5)) sequence,max(eventTimeStamp) date
from zte
where eventTimeStamp >= toDateTime(:dateFrom)
	and eventTimeStamp < toDateTime(:dateTo)
group by path
order by date,sequence

select filePath path,toUInt32OrZero(substring((splitByChar('/', filePath)[-1]),14,5)) sequence,max(recordOpeningTime) date
from data_zte
where recordOpeningTime >= toDateTime(:dateFrom)
	and recordOpeningTime < toDateTime(:dateTo)
group by path
order by date,sequence

*/
/*
select toDayOfMonth(recordOpeningTime) a,toHour(recordOpeningTime) b,count()
from data_zte
where toYear(recordOpeningTime) = (:year)
        and toMonth(recordOpeningTime) = (:month)
group by a,b
order by a,b*/

