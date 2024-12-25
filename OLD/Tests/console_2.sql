select
       'Incoming calls from International' desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from s_ericsson where
                               type = 'M_S_TERMINATING'
                           and callingPartyNumber not like '14%'
                           and callingPartyNumber not like '11231%'
                           and EventDate between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
union all
select desc, sum(minutes) from (

select
       'Outgoing Calls to International' desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) minutes
from s_ericsson where
        type = 'M_S_ORIGINATING'
    and substring(translatedNumber, 3,2) = '00'
    and substring(translatedNumber,5,3) != '231'
    and EventDate between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
union all

select
       'Outgoing Calls to International' desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60)
from s_ericsson where
        type = 'M_S_ORIGINATING'
    and translatedNumber like '11%'
    and translatedNumber not like '11231%'
    and EventDate between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
) group by desc
union all
select
       'Outgoing Calls to Orange' desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60)
from s_ericsson where
    type = 'M_S_ORIGINATING'
and (translatedNumber like '1123177%'
or translatedNumber like '12077%'
or translatedNumber like '120023177%')
and EventDate between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
union all
select
       'Incoming Calls from Orange' desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60)
from s_ericsson where
                         type = 'M_S_TERMINATING'
and (callingPartyNumber like '1477%' or callingPartyNumber like '1123177%')
and EventDate between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
union all
select desc,sum(minutes) minutes from (
                                       select 'OnNet voice'                                        desc,
                                              round(sum(toUnixTimestamp(chargeableDuration)) / 60) minutes
                                       from s_ericsson
                                       where type = 'M_S_ORIGINATING'
                                         and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%' or
                                              callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
                                         and (translatedNumber like '12088%' or translatedNumber like '120023188%' or
                                              translatedNumber like '1123188%'
                                           or translatedNumber like '12055%' or translatedNumber like '120023155%' or
                                              translatedNumber like '1123155%')
                                        and EventDate between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'

                                       union all
                                       select 'OnNet voice'                                        desc,
                                              round(sum(toUnixTimestamp(chargeableDuration)) / 60) minutes
                                       from s_ericsson
                                       where type = 'CALL_FORWARDING'
                                         and (callingPartyNumber like '1488%' or callingPartyNumber like '1455%' or
                                              callingPartyNumber like '1123188%' or callingPartyNumber like '1123155%')
                                         and (translatedNumber like '12088%' or translatedNumber like '120023188%' or
                                              translatedNumber like '1123188%'
                                           or translatedNumber like '12055%' or translatedNumber like '120023155%' or
                                              translatedNumber like '1123155%')
                                         and EventDate between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
                                          ) group by desc;
