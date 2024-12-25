
-- truncate table mediation.MTN_2022

-- select * from mediation.MTN_2022 limit 500

insert into mediation.MTN_2022

select  toDate(start_date) MTN,
        case
            when substring(calling_number, 1, 5) in ('23155', '23188')
                and substring(called_number, 1, 5) in ('23155', '23188')
                then 'On_Net'
            else
        (case
             when substring(calling_number, 1, 5) not in ('23155','23177','23188')
                    and length(calling_number) > 4
                    and length(called_number) > 4
                then 'International_Incoming'
             else
        (case
             when substring(called_number, 1, 5) not in ('23155','23177','23188')
                    and length(calling_number) > 4
                    and length(called_number) > 4
                 then 'International_Outgoing'
             else
         (case
              when substring(called_number, 1, 5) in ('23177')
                  then 'MTN_To_Orange'
              else
          (case
               when substring(calling_number, 1, 5) in ('23177')
                   then 'Orange_To_MTN'
               else
          (case
               when (length(calling_number) < 6
                   or length(called_number) < 6)
                   then 'Ex'
            else (calling_number || ',' || called_number) end) end) end) end) end) end as Call_Type
        ,/*sum(callDuration)*/ callDuration
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
                         when substring(calledPartyNumber, 3, 5) in ('02506', '07406', '09506', '09606')
                             then ('23188' || '' || substring(calledPartyNumber, 7))
                         else
                    (case
                         when substring(calledPartyNumber, 3, 2) = '00'
                             then substring(calledPartyNumber, 5)
                         else
                    (case
                         when substring(calledPartyNumber, 3, 3) in ('025', '074', '095', '096')
                             then substring(calledPartyNumber, 6)
                         else substring(calledPartyNumber, 3) end) end) end) end) end) end as called_number
--         ,incoming
--         ,outgoingRoute
            from ericsson
            where toYear(EventDate) = (:year)
              and toMonth(EventDate) = (:month)
--                 and toDayOfMonth(EventDate) = 1
                and callDuration > 0
                and type in
                  ('CALL_FORWARDING', 'M_S_ORIGINATING', 'M_S_TERMINATING', 'ROAMING_CALL_FORWARDING', 'TRANSIT')
               )
      group by start_date, end_date, calling_number, called_number, callDuration

         ) --group by MTN,Call_Type
order by MTN--start_date,end_date,calling_number,called_number
-- limit 500;

select  MTN,round(sum(On_Net)/60) On_Net,round(sum(International_Incoming)/60) International_Incoming
        ,round(sum(International_Outgoing)/60) International_Outgoing
        ,round(sum(MTN_To_Orange)/60) MTN_To_Orange,round(sum(Orange_To_MTN)/60) Orange_To_MTN,round(sum(Ex)/60) Ex
from (
      select MTN, On_Net, International_Incoming, International_Outgoing, MTN_To_Orange, Orange_To_MTN, Ex
      from (
            select toDate(MTN)                                                                     MTN
                 , case when Call_Type in 'On_Net' then callDuration else 0 end                 as On_Net
                 , case
                       when Call_Type in 'International_Incoming' then callDuration
                       else 0 end                                                               as International_Incoming
                 , case
                       when Call_Type in 'International_Outgoing' then callDuration
                       else 0 end                                                               as International_Outgoing
                 , case when Call_Type in 'MTN_To_Orange' then callDuration else 0 end          as MTN_To_Orange
                 , case when Call_Type in 'Orange_To_MTN' then callDuration else 0 end          as Orange_To_MTN
                 , case when Call_Type in 'Ex' then callDuration else 0 end                     as Ex
            from mediation.MTN_2022
            where toYear(MTN) = (:year)
              and toMonth(MTN) = (:month)
               )
      group by MTN, On_Net, International_Incoming, International_Outgoing, MTN_To_Orange, Orange_To_MTN, Ex
         )group by MTN
order by MTN

/*
select  toDate(start_date) MTN,
        case
            when substring(calling_number, 1, 5) in ('23155', '23188')
                and substring(called_number, 1, 5) in ('23155', '23188')
                then 'On_Net'
            else '0' end as Call_Type,sum(callDuration) callDuration
-- select substring(calling_number, 1, 5)
*/

