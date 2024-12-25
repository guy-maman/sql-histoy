
select  toDate(start_date) MTN
        ,case   when    substring(calling_number,1,4) in ('2318','2315') then callDuration else 0 end as callDuration
from (
      select start_date, end_date, calling_number, called_number, callDuration
      from (
            select /*type,*/substring(toString(dateForStartOfCharge), 1, 10) || ' ' ||
                            substring(toString(timeForStartOfCharge), 12)                                                  start_date
                 , substring(toString(dateForStartOfCharge), 1, 10) || ' ' ||
                   substring(toString(chargeableDuration), 12)                                                             end_date
                 , toUnixTimestamp(chargeableDuration)                                                                     callDuration
                 , case
                       when substring(callingPartyNumber, 3, 2) in ('55', '88', '77')
                           then '231' || '' || substring(callingPartyNumber, 3)
                       else substring(callingPartyNumber, 3) end                                                        as calling_number
                 , case
                       when substring(calledPartyNumber, 3, 3) in ('055', '077', '088')
                           then '231' || '' || substring(calledPartyNumber, 4)
                       else
                           (case
                                when substring(calledPartyNumber, 3, 6)
                                    in ('025055', '025088', '025077', '074055', '074088', '074077', '095055', '095088',
                                        '095077', '096055', '096088', '096077')
                                    then ('231' || '' || substring(calledPartyNumber, 7))
                                else
                                    (case
                                         when substring(calledPartyNumber, 3, 5) in ('02500', '07400', '09500', '09600')
                                             then substring(calledPartyNumber, 8)
                                         else
                                             (case
                                                  when substring(calledPartyNumber, 3, 2) = '00'
                                                      then substring(calledPartyNumber, 5)
                                                  else
                                                      (case
                                                           when substring(calledPartyNumber, 3, 3) in ('025', '074', '095', '096')
                                                               then substring(calledPartyNumber, 6)
                                                           else substring(calledPartyNumber, 3) end) end) end) end) end as called_number
--         ,incomingRoute
--         ,outgoingRoute
            from ericsson
            where toYear(EventDate) = (:year)
              and toMonth(EventDate) = (:month)
--                 and toDayOfMonth(EventDate) = 1
              and callDuration > 0
--                 and substring(called_number, 1, 5) not in ('23155','23177','23188')
              and length(calling_number) > 4
              and length(called_number) > 4
              and type in
                  ('CALL_FORWARDING', 'M_S_ORIGINATING', 'M_S_TERMINATING', 'ROAMING_CALL_FORWARDING', 'TRANSIT')
               )
      group by start_date, end_date, calling_number, called_number, callDuration
         )