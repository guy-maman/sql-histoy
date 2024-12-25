<?xml version="1.0" encoding="UTF-8" ?>
<QueryList>
    <queries>
        <QueryEntity>
            <name>EricssonGetIncomingCallsFromInternational</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date,round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
                from ericsson where EventDate > toStartOfDay(now() - (86400*:days))
                and type in  ('TRANSIT')
                and eosInfo <> '2'
                and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
                    'L2MBC2I')
                group by date
                order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonGetOutgoingCallsToInternational</name>
            <query><![CDATA[select date, sum(duration) duration
        from (
        select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where  EventDate > toStartOfDay(now() - (86400*:days))
                and type in ('ROAMING_CALL_FORWARDING')
                and mobileStationRoamingNumber not like '11231%'
        group by date
        order by date
        union all
        select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where  EventDate > toStartOfDay(now() - (86400*:days))
                and type in ('CALL_FORWARDING')
                and translatedNumber like '14%'
                and translatedNumber not like '14231%'
        group by date
        order by date
        union all
        select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where  EventDate > toStartOfDay(now() - (86400*:days))
                and type in ('CALL_FORWARDING')
                and translatedNumber like '11%'
                and translatedNumber not like '11231%'
        group by date
        order by date
        union all
        select date, round(sum(duration) / 60) duration
        from (
                select toYYYYMMDD(EventDate) date,
                        toUnixTimestamp(chargeableDuration)/count() duration
                from ericsson
               where  EventDate > toStartOfDay(now() - (86400*:days))
                        and type in ('M_S_ORIGINATING')
                        and translatedNumber not like '1488%'
                        and translatedNumber not like '1477%'
                        and translatedNumber not like '1455%'
                        and translatedNumber not like '14088%'
                        and translatedNumber not like '14077%'
                        and translatedNumber not like '14055%'
                        and translatedNumber not like '14231%'
                        and translatedNumber not like '1400231%'
                        and translatedNumber not like '12088%'
                        and translatedNumber not like '12077%'
                        and translatedNumber not like '12055%'
                        and translatedNumber not like '12231%'
                        and translatedNumber not like '1200231%'
                        and translatedNumber not like '11231%'
                        and length(substring(translatedNumber, 3)) > 6
                group by date,dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge, callingPartyNumber, translatedNumber,chargeableDuration
                )group by  date order by date
        ) group by  date order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonGetOnNet</name>
            <query><![CDATA[select   toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration))/60) duration
        from    ericsson
        where   EventDate > toStartOfDay(now() - (86400*:days))
        and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and length(calledPartyNumber) > 9
        and originForCharging = '1'
        and (calledPartyNumber like '1423188%' or calledPartyNumber  like '1423155%'
                or calledPartyNumber  like '14088%' or calledPartyNumber  like '14055%'
                or calledPartyNumber  like '120023188%' or calledPartyNumber  like '12088%'
                or calledPartyNumber  like '120023155%' or calledPartyNumber  like '12055%'
                or calledPartyNumber  like '1202523188%' or calledPartyNumber  like '1207423188%'
                or calledPartyNumber  like '1202523155%' or calledPartyNumber  like '1207423155%'
                or calledPartyNumber  like '1223188%')
        and length(callingPartyNumber) > 9
        and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%'
                OR callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
        group by date
        order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonGetOffNetVoiceOutgoing</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where EventDate > toStartOfDay(now() - (86400*:days))
        and outgoingRoute = 'CELLCO'
        group by date
        order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonGetOffNetVoiceIncoming</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where   EventDate > toStartOfDay(now() - (86400*:days))
        and originForCharging = '1'
        and incomingRoute = 'CELLCI'
        group by date
        order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonPostIncomingCallsFromInternationalByDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date,round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
            from ericsson where
                EventDate >=  toDateTime(:dateFrom)
                and EventDate < toDateTime(:dateTo)
                and type in  ('TRANSIT')
                and eosInfo <> '2'
                and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
                    'L2MBC2I')
            group by date
            order by toHour(EventDate)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonPostOutgoingCallsToInternationalByDay</name>
            <query><![CDATA[select date, sum(duration) duration
from (
        select toString(toHour(EventDate)) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where  EventDate >=  toDateTime(:dateFrom)
        and EventDate < toDateTime(:dateTo)
                and type in ('ROAMING_CALL_FORWARDING')
                and mobileStationRoamingNumber not like '11231%'
        group by date
        union all
        select toString(toHour(EventDate)) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where  EventDate >=  toDateTime(:dateFrom)
        and EventDate < toDateTime(:dateTo)
                  and type in ('CALL_FORWARDING')
                and translatedNumber like '14%'
                and translatedNumber not like '14231%'
        group by date
        union all
        select toString(toHour(EventDate)) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where  EventDate >=  toDateTime(:dateFrom)
        and EventDate < toDateTime(:dateTo)
                  and type in ('CALL_FORWARDING')
                and translatedNumber like '11%'
                and translatedNumber not like '11231%'
        group by date
        union all
        select date, round(sum(duration) / 60) duration
        from (
                select toString(toHour(EventDate)) date,
                        toUnixTimestamp(chargeableDuration)/count() duration
                from ericsson
        where  EventDate >=  toDateTime(:dateFrom)
        and EventDate < toDateTime(:dateTo)
                        and type in ('M_S_ORIGINATING')
                        and translatedNumber not like '1488%'
                        and translatedNumber not like '1477%'
                        and translatedNumber not like '1455%'
                        and translatedNumber not like '14088%'
                        and translatedNumber not like '14077%'
                        and translatedNumber not like '14055%'
                        and translatedNumber not like '14231%'
                        and translatedNumber not like '1400231%'
                        and translatedNumber not like '12088%'
                        and translatedNumber not like '12077%'
                        and translatedNumber not like '12055%'
                        and translatedNumber not like '12231%'
                        and translatedNumber not like '1200231%'
                        and translatedNumber not like '11231%'
                        and length(substring(translatedNumber, 3)) > 6
                group by date, dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge, callingPartyNumber, translatedNumber,chargeableDuration
                ) group by  date
        ) group by  date order by CAST(date as int)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonPostOnNetByDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(sum(toUnixTimestamp(chargeableDuration))/60) duration
        from    ericsson
        where   EventDate >=  toDateTime(:dateFrom)
        and EventDate < toDateTime(:dateTo)
        and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and length(calledPartyNumber) > 9
        and originForCharging = '1'
        and (calledPartyNumber like '1423188%' or calledPartyNumber  like '1423155%'
                or calledPartyNumber  like '14088%' or calledPartyNumber  like '14055%'
                or calledPartyNumber  like '120023188%' or calledPartyNumber  like '12088%'
                or calledPartyNumber  like '120023155%' or calledPartyNumber  like '12055%'
                or calledPartyNumber  like '1202523188%' or calledPartyNumber  like '1207423188%'
                or calledPartyNumber  like '1202523155%' or calledPartyNumber  like '1207423155%'
                or calledPartyNumber  like '1223188%')
        and length(callingPartyNumber) > 9
        and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%'
                OR callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
        group by date
        order by toHour(EventDate)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonPostOffNetVoiceOutgoingByDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where EventDate >=  toDateTime(:dateFrom)
        and EventDate < toDateTime(:dateTo)
        and outgoingRoute = 'CELLCO'
        group by date
        order by toHour(EventDate)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonPostOffNetVoiceIncomingByDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where EventDate >=  toDateTime(:dateFrom)
        and EventDate < toDateTime(:dateTo)
        and originForCharging = '1'
        and incomingRoute = 'CELLCI'
        group by date
        order by toHour(EventDate)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeGetInternationalOutgoing</name>
            <query><![CDATA[select toYYYYMMDD(date) date,round(sum(callDuration)/60) duration
            from (
                  select    answerTime,
                           callReference,
                           callDuration,
                           toDate(answerTime) date
                    from zte
                    where type in
                          ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD',
                           'OUT_GATEWAY_RECORD',
                           'ROAM_RECORD')
                      and outgoingTKGPName in
                          ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                           'Orange-12482',
                           'BARAK SIP 2', 'OLIB_SBC_OFR')
                      and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                      and callDuration > 0
                    group by callReference, answerTime, callDuration, date
                    union all
                    select answerTime,
                           callReference,
                           callDuration,
                           toDate(answerTime) date
                    from zte
                    where type in ('MCF_CALL_RECORD')
                      and outgoingTKGPName in
                          ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                           'Orange-12482',
                           'BARAK SIP 2', 'OLIB_SBC_OFR')
                      and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                      and callDuration > 0
                    group by callReference, answerTime, callDuration, date
                 )
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeGetInternationalIncoming</name>
            <query><![CDATA[select toYYYYMMDD(date) date,round(sum(callDuration) / 60) duration
                from (
                     select answerTime,
                             callReference,
                             callDuration,
                             toDate(answerTime) date
                      from zte
                      where type in
                            ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD',
                             'OUT_GATEWAY_RECORD',
                             'ROAM_RECORD')
                        and incomingTKGPName in
                            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                             'Orange-12482',
                             'BARAK SIP 2', 'OLIB_SBC_OFR')
                        and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                        and callDuration > 0
                      group by callReference, answerTime, callDuration, date
                      union all
                      select answerTime,
                             callReference,
                             callDuration,
                             toDate(answerTime) date
                      from zte
                      where type in ('MCF_CALL_RECORD')
                        and incomingTKGPName in
                            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                             'Orange-12482',
                             'BARAK SIP 2', 'OLIB_SBC_OFR')
                        and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                        and callDuration > 0
                      group by callReference, answerTime, callDuration, date
                      union all
                      select answerTime,
                             callReference,
                             callDuration,
                             toDate(answerTime) date
                      from zte
                      where type in ('ROAM_RECORD')
                        and incomingTKGPName in
                            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                             'Orange-12482',
                             'BARAK SIP 2', 'OLIB_SBC_OFR')
                        and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                        and callDuration > 0
                      group by callReference, answerTime, callDuration, date
                  ) group by date order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeGetIncomingFromMTN</name>
            <query><![CDATA[select toYYYYMMDD(date) date,round(sum(callDuration)/60)  duration
                   from (
                         select answerTime,
                                callReference,
                                callDuration,
                                toDate(answerTime) date
                         from zte
                         where type in
                               ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'OUT_GATEWAY_RECORD',
                                'ROAM_RECORD')
                           and incomingTKGPName in ('Comium', 'LoneStar')
                           and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                           and callDuration > 0
                         group by callReference, answerTime, callDuration, date
                         union all
                         select answerTime,
                                callReference,
                                callDuration,
                                toDate(answerTime) date
                         from zte
                         where type in ('MCF_CALL_RECORD')
                           and incomingTKGPName in ('Comium', 'LoneStar')
                           and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                           and callDuration > 0
                         group by callReference, answerTime, callDuration, date
                            )
                     group by date
                     order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeGetOutgoingToMTN</name>
            <query><![CDATA[select toYYYYMMDD(date) date,round(sum(callDuration)/60) duration
                          from (
                                select answerTime,
                                       callReference,
                                       callDuration,
                                       toDate(answerTime) date
                                from zte
                                where type in
                                      ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'OUT_GATEWAY_RECORD',
                                       'ROAM_RECORD')
                                  and outgoingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                                  and callDuration > 0
                                group by callReference, answerTime, callDuration, date
                                union all
                                select answerTime,
                                       callReference,
                                       callDuration,
                                       toDate(answerTime) date
                                from zte
                                where type in ('MCF_CALL_RECORD')
                                  and outgoingTKGPName in ('Comium', 'LoneStar')
                                  and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                                  and callDuration > 0
                                group by callReference, answerTime, callDuration, date
                                   )
                            group by date
                            order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeGetOnNet</name>
            <query><![CDATA[select toYYYYMMDD(date) date,round(sum(duration)/60) duration
                    from (
                            select toDate(answerTime) date, sum(callDuration) duration
                            from zte
                            where type in ('MO_CALL_RECORD', 'OUT_GATEWAY_RECORD', 'ROAM_RECORD', 'INC_GATEWAY_RECORD')
                              and outgoingTKGPName in
                                  ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY', 'CALL_CENTER', 'Religious_Service')
                              and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                              and callDuration > 0
                            group by date
                            union all
                            select toDate(answerTime) date, sum(callDuration) duration
                            from zte
                            where type in ('MCF_CALL_RECORD')
                              and outgoingTKGPName in
                                  ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY', 'CALL_CENTER', 'Religious_Service')
                              and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                              and callDuration > 0
                            group by date
                               )
                    group by date
                    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangePostInternationalOutgoingByDay</name>
            <query><![CDATA[select toString(toHour(answerTime)) date,round(sum(callDuration)/60) duration
           from (
                  select    answerTime,
                           callReference,
                           callDuration,
                           toDate(answerTime) date
                    from zte
                    where type in
                          ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD',
                           'OUT_GATEWAY_RECORD',
                           'ROAM_RECORD')
                      and outgoingTKGPName in
                          ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                           'Orange-12482',
                           'BARAK SIP 2', 'OLIB_SBC_OFR')
                      and eventTimeStamp >=  toDateTime(:dateFrom)
                      and eventTimeStamp < toDateTime(:dateTo)
                      and callDuration > 0
                    group by callReference, answerTime, callDuration, date
                    union all
                    select answerTime,
                           callReference,
                           callDuration,
                           toDate(answerTime) date
                    from zte
                    where type in ('MCF_CALL_RECORD')
                      and outgoingTKGPName in
                          ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                           'Orange-12482',
                           'BARAK SIP 2', 'OLIB_SBC_OFR')
                      and eventTimeStamp >=  toDateTime(:dateFrom)
                      and eventTimeStamp < toDateTime(:dateTo)
                      and callDuration > 0
                    group by callReference, answerTime, callDuration, date
                 )
            group by date
            order by toHour(answerTime)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangePostInternationalIncomingByDay</name>
            <query><![CDATA[select date,round(sum(callDuration) / 60) duration
                from (
                     select answerTime,
                             callReference,
                             callDuration,
                             toDate(answerTime) date
                      from zte
                      where type in
                            ('MO_CALL_RECORD', 'MT_CALL_RECORD', 'INC_GATEWAY_RECORD',
                             'OUT_GATEWAY_RECORD',
                             'ROAM_RECORD')
                        and incomingTKGPName in
                            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                             'Orange-12482',
                             'BARAK SIP 2', 'OLIB_SBC_OFR')
                        and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                        and callDuration > 0
                      group by callReference, answerTime, callDuration, date
                      union all
                      select answerTime,
                             callReference,
                             callDuration,
                             toDate(answerTime) date
                      from zte
                      where type in ('MCF_CALL_RECORD')
                        and incomingTKGPName in
                            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                             'Orange-12482',
                             'BARAK SIP 2', 'OLIB_SBC_OFR')
                        and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                        and callDuration > 0
                      group by callReference, answerTime, callDuration, date
                      union all
                      select answerTime,
                             callReference,
                             callDuration,
                             toDate(answerTime) date
                      from zte
                      where type in ('ROAM_RECORD')
                        and incomingTKGPName in
                            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                             'Orange-12482',
                             'BARAK SIP 2', 'OLIB_SBC_OFR')
                        and eventTimeStamp > toStartOfDay(now() - (86400*:days))
                        and callDuration > 0
                      group by callReference, answerTime, callDuration, date
                  )
-- from (
--       select date, sum(duration) duration
--       from (
--             select toYYYYMMDD(eventTimeStamp) date,
--                    answerTime
--                  , substring(callingNumber, length(callingNumber) - 8) callingNumber
--                  , substring((case when servedMSISDN = '' then calledNumber else servedMSISDN end),
--                              length(case when servedMSISDN = '' then calledNumber else servedMSISDN end) -
--                              8) as                                     calledNumber
--                  ,sum(callDuration) / count() duration
--             from zte
--             where incomingTKGPName in
--                   ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482',
--                    'Orange-12490')
--               and type in ('MT_CALL_RECORD', 'INC_GATEWAY_RECORD')
--               and eventTimeStamp >=  toDateTime(:dateFrom)
--               and eventTimeStamp < toDateTime(:dateTo)
--             group by answerTime, callingNumber, calledNumber, date
--                ) group by date
--       union all
--       select toYYYYMMDD(eventTimeStamp) date, round(sum(callDuration) / 60) duration
--       from zte
--       where type not in ('MT_CALL_RECORD', 'INC_GATEWAY_RECORD')
--         and incomingTKGPName in
--             ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482',
--              'Orange-12490')
--         and eventTimeStamp >=  toDateTime(:dateFrom)
--         and eventTimeStamp < toDateTime(:dateTo)
--          group by date
--          )
            group by date order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangePostIncomingFromMTNByDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date,round(sum(callDuration)/60)  duration
from zte where  eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    and type not in ('MT_CALL_RECORD')
    and incomingTKGPName in ('Comium', 'LoneStar')
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangePostOutgoingToMTNByDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date,round(sum(callDuration)/60) duration
    from zte where  eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    and type not in ('MO_CALL_RECORD')
    and outgoingTKGPName in ('Comium', 'LoneStar')
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangePostOnNetByDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date,round(sum(callDuration)/60) duration
    from zte where  eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    and type in ('MO_CALL_RECORD','OUT_GATEWAY_RECORD','ROAM_RECORD','INC_GATEWAY_RECORD','MCF_CALL_RECORD','TERM_CAMEL_INT_RECORD')
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonGetInternationalIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date,round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
                from ericsson where
                EventDate >=  toDateTime(:dateFrom)
                and EventDate <= toDateTime(:dateTo)
                and type in  ('TRANSIT')
                and eosInfo <> '2'
                and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
                group by date
                order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonGetInternationalOutgoingBetween</name>
            <query><![CDATA[select date, sum(duration) duration
        from (
        select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where  EventDate >=  toDateTime(:dateFrom)
            and EventDate <= toDateTime(:dateTo)
            and type in ('ROAMING_CALL_FORWARDING')
            and mobileStationRoamingNumber not like '11231%'
        group by date
        order by date
        union all
        select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where  EventDate >=  toDateTime(:dateFrom)
            and EventDate <= toDateTime(:dateTo)
                and type in ('CALL_FORWARDING')
                and translatedNumber like '14%'
                and translatedNumber not like '14231%'
        group by date
        order by date
        union all
        select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where  EventDate >=  toDateTime(:dateFrom)
            and EventDate <= toDateTime(:dateTo)
                and type in ('CALL_FORWARDING')
                and translatedNumber like '11%'
                and translatedNumber not like '11231%'
        group by date
        order by date
        union all
        select date, round(sum(duration) / 60) duration
        from (
                select toYYYYMMDD(EventDate) date,
                        toUnixTimestamp(chargeableDuration)/count() duration
                from ericsson
        where  EventDate >=  toDateTime(:dateFrom)
            and EventDate <= toDateTime(:dateTo)
                        and type in ('M_S_ORIGINATING')
                        and translatedNumber not like '1488%'
                        and translatedNumber not like '1477%'
                        and translatedNumber not like '1455%'
                        and translatedNumber not like '14088%'
                        and translatedNumber not like '14077%'
                        and translatedNumber not like '14055%'
                        and translatedNumber not like '14231%'
                        and translatedNumber not like '1400231%'
                        and translatedNumber not like '12088%'
                        and translatedNumber not like '12077%'
                        and translatedNumber not like '12055%'
                        and translatedNumber not like '12231%'
                        and translatedNumber not like '1200231%'
                        and translatedNumber not like '11231%'
                        and length(substring(translatedNumber, 3)) > 6
                group by date,dateForStartOfCharge,timeForStartOfCharge,timeForStopOfCharge, callingPartyNumber, translatedNumber,chargeableDuration
                )group by  date order by date
        ) group by  date order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeGetInternationalIncomingBetween</name>
            <query><![CDATA[select date,round(sum(duration) / 60) duration
from (
      select date, sum(duration) duration
      from (
            select toYYYYMMDD(eventTimeStamp) date,
                   answerTime
                 , substring(callingNumber, length(callingNumber) - 8) callingNumber
                 , substring((case when servedMSISDN = '' then calledNumber else servedMSISDN end),
                             length(case when servedMSISDN = '' then calledNumber else servedMSISDN end) -
                             8) as                                     calledNumber
                 ,sum(callDuration) / count() duration
            from zte
            where incomingTKGPName in
                  ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482',
                   'Orange-12490')
              and type in ('MT_CALL_RECORD', 'INC_GATEWAY_RECORD')
              and eventTimeStamp >=  toDateTime(:dateFrom)
              and eventTimeStamp <= toDateTime(:dateTo)
            group by answerTime, callingNumber, calledNumber, date
               ) group by date
      union all
      select toYYYYMMDD(eventTimeStamp) date, round(sum(callDuration) / 60) duration
      from zte
      where type not in ('MT_CALL_RECORD', 'INC_GATEWAY_RECORD')
        and incomingTKGPName in
            ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482',
             'Orange-12490')
        and eventTimeStamp >=  toDateTime(:dateFrom)
        and eventTimeStamp <= toDateTime(:dateTo)
         group by date
         ) group by date order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeGetInternationalOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date,round(sum(callDuration)/60) duration
    from zte where  eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    and type in ('OUT_GATEWAY_RECORD','ROAM_RECORD','INC_GATEWAY_RECORD','MCF_CALL_RECORD','TERM_CAMEL_INT_RECORD')
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonPostOnNetBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration))/60) duration
        from    ericsson
        where   EventDate >=  toDateTime(:dateFrom)
        and EventDate <= toDateTime(:dateTo)
        and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and length(calledPartyNumber) > 9
        and originForCharging = '1'
        and (calledPartyNumber like '1423188%' or calledPartyNumber  like '1423155%'
                or calledPartyNumber  like '14088%' or calledPartyNumber  like '14055%'
                or calledPartyNumber  like '120023188%' or calledPartyNumber  like '12088%'
                or calledPartyNumber  like '120023155%' or calledPartyNumber  like '12055%'
                or calledPartyNumber  like '1202523188%' or calledPartyNumber  like '1207423188%'
                or calledPartyNumber  like '1202523155%' or calledPartyNumber  like '1207423155%'
                or calledPartyNumber  like '1223188%')
        and length(callingPartyNumber) > 9
        and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%'
                OR callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
        group by date
        order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangePostOnNetBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date,round(sum(callDuration)/60) duration
    from zte where  eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    and type in ('MO_CALL_RECORD','OUT_GATEWAY_RECORD','ROAM_RECORD','INC_GATEWAY_RECORD','MCF_CALL_RECORD','TERM_CAMEL_INT_RECORD')
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangePostIncomingFromMTNBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date,round(sum(callDuration)/60)  duration
    from zte where eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    and type not in ('MT_CALL_RECORD')
    and incomingTKGPName in ('Comium', 'LoneStar')
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangePostOutgoingToMTNBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date,round(sum(callDuration)/60) duration
    from zte where eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    and type not in ('MO_CALL_RECORD')
    and outgoingTKGPName in ('Comium', 'LoneStar')
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonPostOffNetVoiceOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where EventDate >= toDateTime(:dateFrom)
            and EventDate <= toDateTime(:dateTo)
        and outgoingRoute = 'CELLCO'
        group by date
        order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonPostOffNetVoiceIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        from ericsson
        where EventDate >= toDateTime(:dateFrom)
        and EventDate <= toDateTime(:dateTo)
        and originForCharging = '1'
        and incomingRoute = 'CELLCI'
        group by date
        order by date]]></query>
        </QueryEntity>




        <QueryEntity>
            <name>EricssonACDInternationalIncomingDefault</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date,
                 round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
                    from ericsson
                    where originForCharging = '1'
                    and chargeableDuration > 0
                    and EventDate > toStartOfDay(now() - (86400*:days))
                    and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
                    group by date
                    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonACDInternationalOutgoingDefault</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date,round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            from ericsson
            where type in ('M_S_ORIGINATING', 'TRANSIT')
            and EventDate > toStartOfDay(now() - (86400*:days))
            and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')
            group by date
            order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonACDOnNetDefault</name>
            <query><![CDATA[select  toYYYYMMDD(EventDate) date,
       round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
        from    ericsson
        where   EventDate > toStartOfDay(now() - (86400*:days))
        and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and length(calledPartyNumber) > 9
        and originForCharging = '1'
        and (calledPartyNumber like '1423188%' or calledPartyNumber  like '1423155%'
                or calledPartyNumber  like '14088%' or calledPartyNumber  like '14055%'
                or calledPartyNumber  like '120023188%' or calledPartyNumber  like '12088%'
                or calledPartyNumber  like '120023155%' or calledPartyNumber  like '12055%'
                or calledPartyNumber  like '1202523188%' or calledPartyNumber  like '1207423188%'
                or calledPartyNumber  like '1202523155%' or calledPartyNumber  like '1207423155%'
                or calledPartyNumber  like '1223188%')
        and length(callingPartyNumber) > 9
        and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%'
                OR callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
        group by date
        order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonACDOffNetOutgoingDefault</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date,
        round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
        from ericsson
        where type in ('M_S_ORIGINATING', 'TRANSIT')
        and EventDate > toStartOfDay(now() - (86400*:days))
        and outgoingRoute = 'CELLCO'
        group by date
        order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonACDOffNetIncomingDefault</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date,round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            from ericsson
            where   originForCharging = '1'
            and EventDate > toStartOfDay(now() - (86400*:days))
            and incomingRoute = 'CELLCI'
            group by date
            order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonACDInternationalIncomingDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            from ericsson
            where originForCharging = '1'
            and chargeableDuration > 0
            and EventDate >=  toDateTime(:dateFrom)
            and EventDate < toDateTime(:dateTo)
            and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
            group by date
            order by toHour(EventDate)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonACDInternationalOutgoingDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            from ericsson
            where type in ('M_S_ORIGINATING', 'TRANSIT')
            and EventDate >=  toDateTime(:dateFrom)
            and EventDate < toDateTime(:dateTo)
            and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')
            group by date
            order by toHour(EventDate)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonACDOnNetDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            from ericsson
            where   EventDate >=  toDateTime(:dateFrom)
            and EventDate < toDateTime(:dateTo)
            and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
            and length(calledPartyNumber) > 9
            and originForCharging = '1'
            and (calledPartyNumber like '1423188%' or calledPartyNumber  like '1423155%'
                or calledPartyNumber  like '14088%' or calledPartyNumber  like '14055%'
                or calledPartyNumber  like '120023188%' or calledPartyNumber  like '12088%'
                or calledPartyNumber  like '120023155%' or calledPartyNumber  like '12055%'
                or calledPartyNumber  like '1202523188%' or calledPartyNumber  like '1207423188%'
                or calledPartyNumber  like '1202523155%' or calledPartyNumber  like '1207423155%'
                or calledPartyNumber  like '1223188%')
            and length(callingPartyNumber) > 9
            and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%'
                OR callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
            group by date
            order by toHour(EventDate)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonACDOffNetOutgoingDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            from ericsson
            where type in ('M_S_ORIGINATING', 'TRANSIT')
            and EventDate >=  toDateTime(:dateFrom)
            and EventDate < toDateTime(:dateTo)
            and outgoingRoute = 'CELLCO'
            group by date
            order by toHour(EventDate)]]></query>
        </QueryEntity>
        <QueryEntity>
        <name>EricssonACDOffNetIncomingDay</name>
        <query><![CDATA[select toString(toHour(EventDate)) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
        from ericsson
        where   originForCharging = '1'
        and EventDate >=  toDateTime(:dateFrom)
        and EventDate < toDateTime(:dateTo)
        and incomingRoute = 'CELLCI'
        group by date
        order by toHour(EventDate)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonACDInternationalIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            from ericsson
            where originForCharging = '1'
            and chargeableDuration > 0
            and EventDate >=  toDateTime(:dateFrom)
            and EventDate <= toDateTime(:dateTo)
            and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
            group by date
            order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonACDInternationalOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            from ericsson
            where type in ('M_S_ORIGINATING', 'TRANSIT')
            and EventDate >=  toDateTime(:dateFrom)
            and EventDate <= toDateTime(:dateTo)
            and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')
            group by date
            order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonACDOnNetBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            from ericsson
            where   EventDate >=  toDateTime(:dateFrom)
            and EventDate < toDateTime(:dateTo)
            and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
            and length(calledPartyNumber) > 9
            and originForCharging = '1'
            and (calledPartyNumber like '1423188%' or calledPartyNumber  like '1423155%'
                or calledPartyNumber  like '14088%' or calledPartyNumber  like '14055%'
                or calledPartyNumber  like '120023188%' or calledPartyNumber  like '12088%'
                or calledPartyNumber  like '120023155%' or calledPartyNumber  like '12055%'
                or calledPartyNumber  like '1202523188%' or calledPartyNumber  like '1207423188%'
                or calledPartyNumber  like '1202523155%' or calledPartyNumber  like '1207423155%'
                or calledPartyNumber  like '1223188%')
            and length(callingPartyNumber) > 9
            and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%'
                OR callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
            group by date
            order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonACDOffNetOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            from ericsson
            where type in ('M_S_ORIGINATING', 'TRANSIT')
            and EventDate >=  toDateTime(:dateFrom)
            and EventDate <= toDateTime(:dateTo)
            and outgoingRoute = 'CELLCO'
            group by date
            order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonACDOffNetIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
        from ericsson
        where   originForCharging = '1'
        and EventDate >=  toDateTime(:dateFrom)
        and EventDate <= toDateTime(:dateTo)
        and incomingRoute = 'CELLCI'
        group by date
        order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDInternationalOutgoingDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDInternationalIncomingDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDOffNetIncomingDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDOffNetOutgoingDefault</name>
            <query><![CDATA[select  toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDOnNetDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDInternationalOutgoingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDInternationalIncomingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDOffNetIncomingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDOffNetOutgoingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDOnNetDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDInternationalOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    group by date
    order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeACDInternationalIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    group by date
    order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeACDOffNetIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDOffNetOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeACDOnNetBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonSearchByNumberBetweenDate</name>
            <query><![CDATA[select rowNumberInAllBlocks() id, case type when 'M_S_ORIGINATING' then 'Outgoing' else 'Incoming' end types,
       substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12) start_date,
       substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(chargeableDuration), 12) end_date,
       substring(callingPartyNumber,3) calling_number,
       substring(calledPartyNumber,3) called_number
    from ericsson where
    EventDate >= toDateTime(:startDate)
    and EventDate <= toDateTime(:endDate)
    and type in ('M_S_ORIGINATING', 'M_S_TERMINATING')
    and (callingPartyNumber like (:phoneNumber) or calledPartyNumber like (:phoneNumber))]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeSearchByNumberBetweenDate</name>
            <query><![CDATA[select rowNumberInAllBlocks() id, case type when 'MO_CALL_RECORD' then 'Outgoing' else 'Incoming' end types, answerTime start_date,
       releaseTime end_date,
       multiIf(type='MO_CALL_RECORD',substring(servedMSISDN,3), '') calling_number,
       multiIf(type='MT_CALL_RECORD',substring(servedMSISDN,3), '') called_number
   from zte where
   type in ('MO_CALL_RECORD', 'MT_CALL_RECORD')
   and eventTimeStamp >= toDateTime(:startDate)
   and eventTimeStamp <= toDateTime(:endDate)
   and (servedMSISDN like (:phoneNumber))]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASRInternationalOutgoingDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASRInternationalIncomingDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASROffNetIncomingDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASROffNetOutgoingDefault</name>
            <query><![CDATA[select  toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASROnNetDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASRInternationalOutgoingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASRInternationalIncomingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASROffNetIncomingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASROffNetOutgoingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASROnNetDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    group by date
    order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASRInternationalIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASRInternationalOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASROnNetBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASROffNetIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    group by date
    order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeASROffNetOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    from zte where type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('Comium', 'LoneStar')
    and eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    group by date
    order by date]]></query>
        </QueryEntity>


        <QueryEntity>
            <name>OrangeDataDefault</name>
            <query><![CDATA[select toYYYYMMDD(recordOpeningTime) date, sum(listOfTrafficIn)/1024/1024 download, sum(listOfTrafficOut)/1024/1024 upload, (sum(listOfTrafficIn) + sum(listOfTrafficOut))/1024/1024 total
   from data_zte
   where recordOpeningTime  > toStartOfDay(now() - (86400*:days))
   group by date
   order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeDataBetween</name>
            <query><![CDATA[select toYYYYMMDD(recordOpeningTime) date, sum(listOfTrafficIn)/1024/1024 download, sum(listOfTrafficOut)/1024/1024 upload, (sum(listOfTrafficIn) + sum(listOfTrafficOut))/1024/1024 total
   from data_zte
   where recordOpeningTime >= toDateTime(:dateFrom)
   and recordOpeningTime <= toDateTime(:dateTo)
   group by date
   order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeDataDay</name>
            <query><![CDATA[select toString(toHour(recordOpeningTime)) date, sum(listOfTrafficIn)/1024/1024 download, sum(listOfTrafficOut)/1024/1024 upload, (sum(listOfTrafficIn) + sum(listOfTrafficOut))/1024/1024 total
   from data_zte
   where recordOpeningTime >= toDateTime(:dateFrom)
   and recordOpeningTime < toDateTime(:dateTo)
   group by date
   order by toHour(recordOpeningTime)]]></query>
        </QueryEntity>


        <QueryEntity>
            <name>EricssonDataDefault</name>
            <query><![CDATA[select toYYYYMMDD(recordOpeningTime) date, sum(listOfTrafficIn)/1024/1024 download, sum(listOfTrafficOut)/1024/1024 upload, (sum(listOfTrafficIn) + sum(listOfTrafficOut))/1024/1024 total
   from data_ericsson
   where recordOpeningTime  > toStartOfDay(now() - (86400*:days))
   group by date
   order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonDataBetween</name>
            <query><![CDATA[select toYYYYMMDD(recordOpeningTime) date, sum(listOfTrafficIn)/1024/1024 download, sum(listOfTrafficOut)/1024/1024 upload, (sum(listOfTrafficIn) + sum(listOfTrafficOut))/1024/1024 total
   from data_ericsson
   where recordOpeningTime >= toDateTime(:dateFrom)
   and recordOpeningTime <= toDateTime(:dateTo)
   group by date
   order by date]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonDataDay</name>
            <query><![CDATA[select toString(toHour(recordOpeningTime)) date, sum(listOfTrafficIn)/1024/1024 download, sum(listOfTrafficOut)/1024/1024 upload, (sum(listOfTrafficIn) + sum(listOfTrafficOut))/1024/1024 total
   from data_ericsson
   where recordOpeningTime >= toDateTime(:dateFrom)
   and recordOpeningTime < toDateTime(:dateTo)
   group by date
   order by toHour(recordOpeningTime)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonInternationalIncomingCause</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    from ericsson
    where   EventDate > toStartOfDay(now() - (86400*:days))
    and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
    and originForCharging = '1'
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonInternationalOutgoingCause</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    from ericsson
    where   EventDate > toStartOfDay(now() - (86400*:days))
    and type in ('M_S_ORIGINATING', 'TRANSIT')
    and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonOnNetCause</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    from ericsson
    where   EventDate > toStartOfDay(now() - (86400*:days))
 and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and length(calledPartyNumber) > 9
        and originForCharging = '1'
        and (calledPartyNumber like '1423188%' or calledPartyNumber  like '1423155%'
                or calledPartyNumber  like '14088%' or calledPartyNumber  like '14055%'
                or calledPartyNumber  like '120023188%' or calledPartyNumber  like '12088%'
                or calledPartyNumber  like '120023155%' or calledPartyNumber  like '12055%'
                or calledPartyNumber  like '1202523188%' or calledPartyNumber  like '1207423188%'
                or calledPartyNumber  like '1202523155%' or calledPartyNumber  like '1207423155%'
                or calledPartyNumber  like '1223188%')
        and length(callingPartyNumber) > 9
        and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%'
                OR callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonOffNetVoiceOutgoingCause</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    from ericsson
    where   EventDate > toStartOfDay(now() - (86400*:days))
    and type in ('M_S_ORIGINATING', 'TRANSIT')
    and outgoingRoute = 'CELLCO'
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonOffNetVoiceIncomingCause</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    from ericsson
    where   EventDate > toStartOfDay(now() - (86400*:days))
    and originForCharging = '1'
    and incomingRoute = 'CELLCI'
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>



        <QueryEntity>
            <name>EricssonInternationalIncomingCauseBetween</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    from ericsson
    where   EventDate >=  toDateTime(:dateFrom)
    and EventDate <= toDateTime(:dateTo)
    and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
    and originForCharging = '1'
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonInternationalOutgoingCauseBetween</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    from ericsson
    where   EventDate >=  toDateTime(:dateFrom)
    and EventDate <= toDateTime(:dateTo)
    and type in ('M_S_ORIGINATING', 'TRANSIT')
    and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonOnNetCauseBetween</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    from ericsson
    where EventDate >=  toDateTime(:dateFrom)
    and EventDate <= toDateTime(:dateTo)
 and type not in ('M_S_TERMINATING_SMS_IN_MSC', 'M_S_ORIGINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and length(calledPartyNumber) > 9
        and originForCharging = '1'
        and (calledPartyNumber like '1423188%' or calledPartyNumber  like '1423155%'
                or calledPartyNumber  like '14088%' or calledPartyNumber  like '14055%'
                or calledPartyNumber  like '120023188%' or calledPartyNumber  like '12088%'
                or calledPartyNumber  like '120023155%' or calledPartyNumber  like '12055%'
                or calledPartyNumber  like '1202523188%' or calledPartyNumber  like '1207423188%'
                or calledPartyNumber  like '1202523155%' or calledPartyNumber  like '1207423155%'
                or calledPartyNumber  like '1223188%')
        and length(callingPartyNumber) > 9
        and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%'
                OR callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonOffNetVoiceOutgoingCauseBetween</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    from ericsson
    where EventDate >=  toDateTime(:dateFrom)
    and EventDate <= toDateTime(:dateTo)
    and type in ('M_S_ORIGINATING', 'TRANSIT')
    and outgoingRoute = 'CELLCO'
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonOffNetVoiceIncomingCauseBetween</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    from ericsson
    where   EventDate >=  toDateTime(:dateFrom)
    and EventDate <= toDateTime(:dateTo)
    and originForCharging = '1'
    and incomingRoute = 'CELLCI'
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>





        <QueryEntity>
            <name>OrangeInternationalOutgoingCauseDefault</name>
            <query><![CDATA[select causeForTerm code, count() count
    from zte
    where eventTimeStamp > toStartOfDay(now() - (86400*:days))
    and type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeInternationalIncomingCauseDefault</name>
            <query><![CDATA[select causeForTerm code, count() count
    from zte
    where eventTimeStamp > toStartOfDay(now() - (86400*:days))
    and type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeOffNetIncomingCauseDefault</name>
            <query><![CDATA[select causeForTerm code, count() count
    from zte
    where eventTimeStamp > toStartOfDay(now() - (86400*:days))
    and type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('Comium', 'LoneStar')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeOffNetOutgoingCauseDefault</name>
            <query><![CDATA[select causeForTerm code, count() count
    from zte
    where eventTimeStamp > toStartOfDay(now() - (86400*:days))
    and type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('Comium', 'LoneStar')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeOnNetCauseDefault</name>
            <query><![CDATA[select causeForTerm code, count() count
    from zte
    where eventTimeStamp > toStartOfDay(now() - (86400*:days))
    and type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>



        <QueryEntity>
            <name>OrangeInternationalOutgoingCauseBetween</name>
            <query><![CDATA[select causeForTerm code, count() count
    from zte
    where eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    and type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeInternationalIncomingCauseBetween</name>
            <query><![CDATA[select causeForTerm code, count() count
    from zte
    where eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    and type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeOffNetIncomingCauseBetween</name>
            <query><![CDATA[select causeForTerm code, count() count
    from zte
    where eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    and type = 'MT_CALL_RECORD'
    and incomingTKGPName in ('Comium', 'LoneStar')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeOffNetOutgoingCauseBetween</name>
            <query><![CDATA[select causeForTerm code, count() count
    from zte
    where eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    and type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('Comium', 'LoneStar')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeOnNetCauseBetween</name>
            <query><![CDATA[select causeForTerm code, count() count
    from zte
    where eventTimeStamp >=  toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)
    and type = 'MO_CALL_RECORD'
    and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    group by code
    order by toInt16OrNull(code)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonMissedVTF1Default</name>
            <query><![CDATA[select filepath path,toUInt32(substring((splitByChar('/', filepath)[-1]),7,5)) sequence,max(EventDate) date
    from ericsson
    where EventDate > toStartOfDay(now() - (86400*:days))
    and filepath like '%VTF_1%'
    group by filepath
    order by date, sequence]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonMissedVTF2Default</name>
            <query><![CDATA[select filepath path,toUInt32(substring((splitByChar('/', filepath)[-1]),7,5)) sequence,max(EventDate) date
    from ericsson
    where EventDate > toStartOfDay(now() - (86400*:days))
    and filepath like '%VTF_2%'
    group by filepath
    order by date, sequence]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonMissedVTF1Between</name>
            <query><![CDATA[select filepath path,toUInt32(substring((splitByChar('/', filepath)[-1]),7,5)) sequence,max(EventDate) date
    from ericsson
    where   EventDate >=  toDateTime(:dateFrom)
    and EventDate <= toDateTime(:dateTo)
    and filepath like '%VTF_1%'
    group by filepath
    order by date, sequence]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonMissedVTF2Between</name>
            <query><![CDATA[select filepath path,toUInt32(substring((splitByChar('/', filepath)[-1]),7,5)) sequence,max(EventDate) date
    from ericsson
    where   EventDate >=  toDateTime(:dateFrom)
    and EventDate <= toDateTime(:dateTo)
    and filepath like '%VTF_2%'
    group by filepath
    order by date, sequence]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonMissedDataDefault</name>
            <query><![CDATA[select filePath path,toUInt32(substring(filePath,(position(filePath,'.' )+1),position(filePath,'-' )-2 - position(filePath,'.' )+1)) sequence,max(recordOpeningTime) date
    from data_ericsson
    where recordOpeningTime  > toStartOfDay(now() - (86400*:days))
    group by filePath
    order by date,sequence]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>EricssonMissedDataBetween</name>
            <query><![CDATA[select filePath path, toUInt32(substring(filePath,(position(filePath,'.' )+1),position(filePath,'-' )-2 - position(filePath,'.' )+1)) sequence,max(recordOpeningTime) date
    from data_ericsson
    where recordOpeningTime >= toDateTime(:dateFrom)
    and recordOpeningTime < toDateTime(:dateTo)
    group by filePath
    order by date,sequence]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeMissedDefault</name>
            <query><![CDATA[select filepath path,toUInt32(substring(filepath,30,5)) sequence,max(eventTimeStamp) date
    from zte
    where eventTimeStamp  > toStartOfDay(now() - (86400*:days))
    group by path
    order by date,sequence]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeMissedBetween</name>
            <query><![CDATA[select filepath path,toUInt32(substring(filepath,30,5)) sequence,max(eventTimeStamp) date
    from zte
    where eventTimeStamp >= toDateTime(:dateFrom)
    and eventTimeStamp < toDateTime(:dateTo)
    group by path
    order by date,sequence]]></query>
        </QueryEntity>


        <QueryEntity>
            <name>OrangeMissedDataDefault</name>
            <query><![CDATA[select filePath path,toUInt32(substring(filePath,46,5)) sequence,max(recordOpeningTime) date
    from data_zte
    where recordOpeningTime  > toStartOfDay(now() - (86400*:days))
    group by path
    order by date,sequence]]></query>
        </QueryEntity>
        <QueryEntity>
            <name>OrangeMissedDataBetween</name>
            <query><![CDATA[select filePath path,toUInt32(substring(filePath,46,5)) sequence,max(recordOpeningTime) date
    from data_zte
    where recordOpeningTime >= toDateTime(:dateFrom)
    and recordOpeningTime < toDateTime(:dateTo)
    group by path
    order by date,sequence]]></query>
        </QueryEntity>

    </queries>
</QueryList>
