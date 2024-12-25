--EricssonSearchByNumberBetweenDate
/*
select  rowNumberInAllBlocks() id
        ,case  when type = 'M_S_ORIGINATING' then 'Outgoing' else 'Incoming' end types
        ,substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12) start_date
        ,substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(chargeableDuration), 12) end_date
        ,toUnixTimestamp(chargeableDuration) callDuration
        ,case   when substring(callingPartyNumber, 3, 2) in ('55', '88', '77')
                then '231' || '' || substring(callingPartyNumber, 3)
                else substring(callingPartyNumber, 3) end                                                        as calling_number
        ,case   when substring(calledPartyNumber, 3, 3) in ('055', '077', '088')
                then '231' || '' || substring(calledPartyNumber, 4)
                else
        (case   when substring(calledPartyNumber, 3, 6)
                      in ('025055', '025088', '025077', '074055', '074088', '074077', '095055', '095088',
                          '095077', '096055', '096088', '096077')
                then ('231' || '' || substring(calledPartyNumber, 7))
                else
        (case   when substring(calledPartyNumber, 3, 5) in ('02500', '07400', '09500', '09600')
                then substring(calledPartyNumber, 8)
                else
        (case   when substring(calledPartyNumber, 3, 5) in ('02506', '07406', '09506', '09606')
                then ('23188' || '' || substring(calledPartyNumber, 7))
                else
        (case   when substring(calledPartyNumber, 3, 2) = '00'
                then substring(calledPartyNumber, 5)
                else
        (case   when substring(calledPartyNumber, 3, 3) in ('025', '074', '095', '096')
                then substring(calledPartyNumber, 6)
                else substring(calledPartyNumber, 3) end) end) end) end) end) end as called_number
        ,case   when type = 'M_S_ORIGINATING' then callingSubscriberIMEI else calledSubscriberIMEI end IMEI
--         ,case   when substring(calledPartyNumber, 1, 3) in ('055', '077', '088')
;*/
select  sum(toUnixTimestamp(callDuration))/60
from (
select  substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12) start_date
--         ,substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStopOfCharge), 12) end_date
        ,max(toUnixTimestamp(chargeableDuration)) callDuration
        ,substring(callingPartyNumber,3) callingPartyNumber
        ,substring(calledPartyNumber,3) calledPartyNumber
        ,incomingRoute
from    mediation.ericsson
where   toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
--         and toDayOfMonth(EventDate) = (:day)
--         and toHour(timeForStartOfCharge) = (:hour)
--         and toMinute(timeForStartOfCharge) = (:min)
        and filepath not like ('/ex')
--         and (callingPartyNumber like (:phoneNumber) or calledPartyNumber like (:phoneNumber))
--         and originForCharging = '1'
        and incomingRoute in
            ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I',
             'L1MBC2I', 'L2MBC2I')
        and type in ('M_S_ORIGINATING','ROAMING_CALL_FORWARDING','TRANSIT','CALL_FORWARDING')
--         and case when type = 'M_S_ORIGINATING' then callingPartyNumber like (:phoneNumber) else calledPartyNumber like (:phoneNumber)  end
group by start_date,callingPartyNumber,calledPartyNumber,incomingRoute)
-- order by start_date;
;
select  substring(callingPartyNumber,1,2) x,callingPartyNumber,calledPartyNumber,incomingRoute
from    mediation.ericsson
where   toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
        and toDayOfMonth(EventDate) = (:day)
        and incomingRoute in
            ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I',
             'L1MBC2I', 'L2MBC2I')
--         and type = 'ROAMING_CALL_FORWARDING'
        and filepath not like ('/ex')
--         and substring(callingPartyNumber,1,4) not in ('1477','1488','1455')
--         and incomingRoute not in ('L1MBC1I','L1MBC2I','L2MBC1I','L2MBC2I')
        and x = '11'
limit 500;
group by x;


-- select  sum(toUnixTimestamp(callDuration))/60
-- from (
select  substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12) start_date
--         ,substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStopOfCharge), 12) end_date
        ,toUnixTimestamp(chargeableDuration) callDuration
        ,substring(callingPartyNumber,3) callingPartyNumber
        ,substring(calledPartyNumber,3) calledPartyNumber
        ,outgoingRoute
-- select  sum(toUnixTimestamp(chargeableDuration))/60
from    mediation.ericsson
where   toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
        and toDayOfMonth(EventDate) = (:day)
--         and toHour(timeForStartOfCharge) = (:hour)
--         and toMinute(timeForStartOfCharge) = (:min)
        and filepath not like ('/ex')
        and (callingPartyNumber like (:phoneNumber) or calledPartyNumber like (:phoneNumber))
--         and originForCharging = '1'
--         and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
--         and type in ('M_S_ORIGINATING','ROAMING_CALL_FORWARDING','TRANSIT','CALL_FORWARDING')
--         and case when type = 'M_S_ORIGINATING' then callingPartyNumber like (:phoneNumber) else calledPartyNumber like (:phoneNumber)  end
-- group by start_date,callingPartyNumber,calledPartyNumber,incomingRoute)
order by start_date;

ROAMING_CALL_FORWARDING
CALL_FORWARDING
M_S_TERMINATING_SMS_IN_MSC
M_S_ORIGINATING_SMS_IN_MSC
TRANSIT
S_S_PROCEDURE
M_S_TERMINATING
M_S_ORIGINATING


/*select top 1 *--toHour(EventDate)--toHour(now())
from ericsson
where   toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
        and toDayOfMonth(EventDate) = (:day)
order by EventDate desc*/

/*select toYYYYMM(Date) date,sum(International_Outgoing) sun
from    Daily_Traffic
group by date
order by date*/