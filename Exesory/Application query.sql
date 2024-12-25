<?xml version="1.0" encoding="UTF-8" ?>
<QueryList>

    <queries>

        <QueryEntity>
            <name>EricssonGetIncomingCallsFromInternational</name>
            <query>
            <![CDATA[
                     select toYYYYMMDD(Date) date,round(sum(chargeableDuration) / 60) duration
                     from (
                             select  dateForStartOfCharge Date,toUnixTimestamp(chargeableDuration) chargeableDuration
                             from    mediation.ericsson
                             where   EventDate > toStartOfDay(now() - (86400*:days))
                                     and type not in ('M_S_ORIGINATING','M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC','S_S_PROCEDURE')
                                     and incomingRoute in
                                         ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I',
                                          'L1MBC2I', 'L2MBC2I')
                             group by Date,networkCallReference,chargeableDuration
                             )
                     group by date
                     order by date
                 ]]>
            </query>

        </QueryEntity>

        <QueryEntity>
            <name>EricssonPostIncomingCallsFromInternationalByDay</name>
            <query>
            <![CDATA[
                    select toString(toHour(EventDate)) date,round(sum(chargeableDuration) / 60) duration
                    from (
                             select EventDate, toUnixTimestamp(chargeableDuration) chargeableDuration
                             from ericsson
                             where EventDate >= toDateTime(:dateFrom)
                               and EventDate < toDateTime(:dateTo)
                               and type not in
                                   ('M_S_ORIGINATING', 'M_S_ORIGINATING_SMS_IN_MSC', 'M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
                               and incomingRoute in
                                   ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
                                    'L2MBC2I')
                             group by EventDate, networkCallReference, chargeableDuration
                             )
                    group by date
                    order by toHour(EventDate)
            	    ]]>
            </query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonGetInternationalIncomingBetween</name>
            <query>
            <![CDATA[
                    select  toYYYYMMDD(EventDate) date,round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
                    from (
                        select EventDate, toUnixTimestamp(chargeableDuration) chargeableDuration
                        from ericsson
                        where EventDate >= toDateTime(:dateFrom)
                          and EventDate < toDateTime(:dateTo)
                          and type not in
                              ( 'M_S_ORIGINATING_SMS_IN_MSC', 'M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
                          and incomingRoute in
                              ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I', 'L1MBC2I',
                               'L2MBC2I')
                        group by EventDate, networkCallReference, chargeableDuration
                        )
                    group by date
                    order by date
                    ]]>
            </query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonGetOutgoingCallsToInternational</name>
            <query>
            <![CDATA[
                    select toYYYYMMDD(EventDate) date,round(sum(chargeableDuration) / 60) duration
                    from (
                    select  EventDate,toUnixTimestamp(chargeableDuration) chargeableDuration
                    from    ericsson
                    where   EventDate > toStartOfDay(now() - (86400*:days))
                        and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
                        and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
                    group by EventDate,networkCallReference,chargeableDuration
                    )
                    group by date
                    order by date
		            ]]>
		    </query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonPostOutgoingCallsToInternationalByDay</name>
            <query>
            <![CDATA[
                    select toString(toHour(EventDate)) date,round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
                    from (
                    select  EventDate,toUnixTimestamp(chargeableDuration) chargeableDuration
                    from ericsson
                    where EventDate >=  toDateTime(:dateFrom)
                        and EventDate < toDateTime(:dateTo)
                        and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
                        and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
                    group by EventDate,networkCallReference,chargeableDuration
                        )
                    group by date
                    order by toHour(EventDate)
                    ]]>
            </query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonGetInternationalOutgoingBetween</name>
            <query>
            <![CDATA[
                    select toYYYYMMDD(EventDate) date,round(sum(chargeableDuration) / 60) duration
                    from (
                    select  EventDate,toUnixTimestamp(chargeableDuration) chargeableDuration
                    from    ericsson
                    where   EventDate >=  toDateTime(:dateFrom)
                        and EventDate < toDateTime(:dateTo)
                        and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
                        and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
                    group by EventDate,networkCallReference,chargeableDuration
                    )
                    group by date
                    order by date
		            ]]>
		    </query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonGetOnNet</name>
            <query>
            <![CDATA[
                    select   toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration))/60) duration
        	from    ericsson
        	where   EventDate > toStartOfDay(now() - (86400*:days))
  			and originForCharging = '1'
  			and incomingRoute not in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I','L2MBC1I', 'L1MBC2I','L2MBC2I', 'CELLCI')
  			and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO')
  			and length(calledPartyNumber) > 7
  			and length(callingPartyNumber) > 7
		group by date
		order by date
		]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonPostOnNetByDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(sum(toUnixTimestamp(chargeableDuration))/60) duration
        	from    ericsson
        	where   EventDate >=  toDateTime(:dateFrom)
        		and EventDate < toDateTime(:dateTo)
  			and originForCharging = '1'
  			and incomingRoute not in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I','L2MBC1I', 'L1MBC2I','L2MBC2I', 'CELLCI')
  			and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO')
  			and length(calledPartyNumber) > 7
  			and length(callingPartyNumber) > 7
        	group by date
        	order by toHour(EventDate)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonPostOnNetBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration))/60) duration
        	from    ericsson
        	where   EventDate >=  toDateTime(:dateFrom)
        		and EventDate <= toDateTime(:dateTo)
  			and originForCharging = '1'
  			and incomingRoute not in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I','L2MBC1I', 'L1MBC2I','L2MBC2I', 'CELLCI')
  			and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO')
  			and length(calledPartyNumber) > 7
  			and length(callingPartyNumber) > 7
        	group by date
        	order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonGetOffNetVoiceOutgoing</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        	from ericsson
        	where EventDate > toStartOfDay(now() - (86400*:days))
        		and outgoingRoute in ('CELLCO','ORGSBCO')
        	group by date
        	order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonPostOffNetVoiceOutgoingByDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        	from ericsson
        	where EventDate >=  toDateTime(:dateFrom)
        		and EventDate < toDateTime(:dateTo)
        		and outgoingRoute in ('CELLCO','ORGSBCO')
        	group by date
        	order by toHour(EventDate)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonPostOffNetVoiceOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        	from ericsson
        	where EventDate >= toDateTime(:dateFrom)
            		and EventDate <= toDateTime(:dateTo)
        		and outgoingRoute in ('CELLCO','ORGSBCO')
        	group by date
        	order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonGetOffNetVoiceIncoming</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        	from ericsson
        	where   EventDate > toStartOfDay(now() - (86400*:days))
        		and originForCharging = '1'
        		and incomingRoute in ('CELLCI','ORGSBCI')
        	group by date
        	order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonPostOffNetVoiceIncomingByDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        	from ericsson
        	where EventDate >=  toDateTime(:dateFrom)
        		and EventDate < toDateTime(:dateTo)
        		and originForCharging = '1'
        		and incomingRoute in ('CELLCI','ORGSBCI')
        	group by date
        	order by toHour(EventDate)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonPostOffNetVoiceIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
        	from ericsson
        	where EventDate >= toDateTime(:dateFrom)
        		and EventDate <= toDateTime(:dateTo)
        		and originForCharging = '1'
        		and incomingRoute in ('CELLCI','ORGSBCI')
        	group by date
        	order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonDataDefault</name>
            <query><![CDATA[select toYYYYMMDD(recordOpeningTime) date, sum(listOfTrafficIn)/1024/1024 download, sum(listOfTrafficOut)/1024/1024 upload, (sum(listOfTrafficIn) + sum(listOfTrafficOut))/1024/1024 total
   		from data_ericsson
   		where recordOpeningTime  > toStartOfDay(now() - (86400*:days))
               		and ((filePath like '%LIMO%')
                 		or (filePath like '%chsLog%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                                                   			accessPointNameOI <> 'mnc001.mcc618.gprs')))
   		group by date
   		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonDataBetween</name>
            <query>
   		    <![CDATA[
                    select toYYYYMMDD(recordOpeningTime) date, sum(listOfTrafficIn)/1024/1024 download, sum(listOfTrafficOut)/1024/1024 upload, (sum(listOfTrafficIn) + sum(listOfTrafficOut))/1024/1024 total
                    from data_ericsson
                    where   recordOpeningTime >= toDateTime(:dateFrom)
                        and recordOpeningTime <= toDateTime(:dateTo)
                        and accessPointNameOI <> 'mnc001.mcc618.gprs'
                    group by date
                    order by date
   		            ]]>
   		    </query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonDataDay</name>
            <query><![CDATA[select toString(toHour(recordOpeningTime)) date, sum(listOfTrafficIn)/1024/1024 download, sum(listOfTrafficOut)/1024/1024 upload, (sum(listOfTrafficIn) + sum(listOfTrafficOut))/1024/1024 total
   		from data_ericsson
   		where recordOpeningTime >= toDateTime(:dateFrom)
   			and recordOpeningTime < toDateTime(:dateTo)
               		and ((filePath like '%LIMO%')
                 		or (filePath like '%chsLog%' and ((accessPointNameOI like 'mnc%' or accessPointNameOI like 'MNC%') and
                                                   			accessPointNameOI <> 'mnc001.mcc618.gprs')))
   		group by date
   		order by toHour(recordOpeningTime)]]></query>
        </QueryEntity>

<QueryEntity>
            <name>EricssonSearchByNumberBetweenDate</name>
            <query><![CDATA[select rowNumberInAllBlocks() id, case type when 'M_S_ORIGINATING' then 'Outgoing' else 'Incoming' end types
        ,substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12) start_date
        ,substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(chargeableDuration), 12) end_date
        ,toUnixTimestamp(chargeableDuration) call_duration
        ,substring(callingPartyNumber,3) calling_number
        ,case when ((substring(calledPartyNumber,3)) like '025%'
                    or (substring(calledPartyNumber,3)) like '074%')
             then substring(calledPartyNumber,6)
             else substring(calledPartyNumber,3) end as called_number
        ,case  when type = 'M_S_ORIGINATING' then callingSubscriberIMEI else calledSubscriberIMEI end imei
from    ericsson
where   EventDate >= toDateTime(:startDate)
        and EventDate <= toDateTime(:endDate)
        and type in ('M_S_ORIGINATING', 'M_S_TERMINATING')
        and case when type = 'M_S_ORIGINATING' then callingPartyNumber like (:phoneNumber) else calledPartyNumber like (:phoneNumber) end
order by start_date]]></query>
        </QueryEntity>


<QueryEntity>
            <name>EricssonACDInternationalIncomingDefault</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date,
                 round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
                 from ericsson
                 where  EventDate > toStartOfDay(now() - (86400*:days))
		 	and chargeableDuration > 0
		    	and originForCharging not in ('0')
                    	and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I','L1MBC1I', 'L2MBC1I', 'L1MBC2I','L2MBC2I')
                 group by date
                 order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonACDInternationalIncomingDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            	from ericsson
            	where EventDate >=  toDateTime(:dateFrom)
            		and EventDate < toDateTime(:dateTo)
	    		and chargeableDuration > 0
	    		and originForCharging not in ('0')
            		and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I','L1MBC1I', 'L2MBC1I', 'L1MBC2I','L2MBC2I')
            	group by date
            	order by toHour(EventDate)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonACDInternationalIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            	from ericsson
            	where EventDate >=  toDateTime(:dateFrom)
            		and EventDate <= toDateTime(:dateTo)
	    		and chargeableDuration > 0
	    		and originForCharging not in ('0')
            		and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I','L1MBC1I', 'L2MBC1I', 'L1MBC2I','L2MBC2I')
            	group by date
            	order by date]]></query>
        </QueryEntity>

   <QueryEntity>
            <name>EricssonACDInternationalOutgoingDefault</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date,round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            	from ericsson
            	where EventDate > toStartOfDay(now() - (86400*:days))
        		and originForCharging not in ('0')
        		and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O','L2MBC2O', 'ZURO')
            	group by date
            	order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonACDInternationalOutgoingDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            	from ericsson
            	where EventDate >=  toDateTime(:dateFrom)
            		and EventDate < toDateTime(:dateTo)
       			and originForCharging not in ('0')
        		and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O','L2MBC2O', 'ZURO')
            	group by date
            	order by toHour(EventDate)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonACDInternationalOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            	from ericsson
            	where EventDate >=  toDateTime(:dateFrom)
            		and EventDate <= toDateTime(:dateTo)
        		and originForCharging not in ('0')
        		and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O','L2MBC2O', 'ZURO')
            	group by date
            	order by date]]></query>
        </QueryEntity>

  <QueryEntity>
            <name>EricssonACDOnNetDefault</name>
            <query><![CDATA[select  toYYYYMMDD(EventDate) date,
       		round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
        	from    ericsson
        	where   EventDate > toStartOfDay(now() - (86400*:days))
  			and originForCharging = '1'
  			and incomingRoute not in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I','L2MBC1I', 'L1MBC2I','L2MBC2I', 'CELLCI')
  			and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO')
  			and length(calledPartyNumber) > 7
  			and length(callingPartyNumber) > 7
        	group by date
        	order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonACDOnNetDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            	from ericsson
            	where   EventDate >=  toDateTime(:dateFrom)
            		and EventDate < toDateTime(:dateTo)
  			and originForCharging = '1'
  			and incomingRoute not in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I','L2MBC1I', 'L1MBC2I','L2MBC2I', 'CELLCI')
  			and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO')
  			and length(calledPartyNumber) > 7
  			and length(callingPartyNumber) > 7
            	group by date
            	order by toHour(EventDate)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonACDOnNetBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            	from ericsson
            	where   EventDate >=  toDateTime(:dateFrom)
            		and EventDate < toDateTime(:dateTo)
  			and originForCharging = '1'
  			and incomingRoute not in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I','L2MBC1I', 'L1MBC2I','L2MBC2I', 'CELLCI')
  			and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO')
  			and length(calledPartyNumber) > 7
  			and length(callingPartyNumber) > 7
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
        		and outgoingRoute in ('CELLCO','ORGSBCO')
        	group by date
        	order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonACDOffNetOutgoingDay</name>
            <query><![CDATA[select toString(toHour(EventDate)) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            	from ericsson
            	where type in ('M_S_ORIGINATING', 'TRANSIT')
            		nd EventDate >=  toDateTime(:dateFrom)
            		and EventDate < toDateTime(:dateTo)
            		and outgoingRoute in ('CELLCO','ORGSBCO')
            	group by date
            	order by toHour(EventDate)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonACDOffNetOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            	from ericsson
            	where type in ('M_S_ORIGINATING', 'TRANSIT')
            		and EventDate >=  toDateTime(:dateFrom)
            		and EventDate <= toDateTime(:dateTo)
            		and outgoingRoute in ('CELLCO','ORGSBCO')
            	group by date
            	order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonACDOffNetIncomingDefault</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date,round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
            	from ericsson
            	where   originForCharging = '1'
            		and EventDate > toStartOfDay(now() - (86400*:days))
            		and incomingRoute in ('CELLCI','ORGSBCI')
            	group by date
            	order by date]]></query>
        </QueryEntity>

        <QueryEntity>
        <name>EricssonACDOffNetIncomingDay</name>
        <query><![CDATA[select toString(toHour(EventDate)) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
        	from ericsson
        	where   originForCharging = '1'
        		and EventDate >=  toDateTime(:dateFrom)
        		and EventDate < toDateTime(:dateTo)
        		and incomingRoute in ('CELLCI','ORGSBCI')
        	group by date
        	order by toHour(EventDate)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonACDOffNetIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(EventDate) date, round(round(sum(toUnixTimestamp(chargeableDuration)) / 60) / count(), 4) duration
        	from ericsson
        	where   originForCharging = '1'
        		and EventDate >=  toDateTime(:dateFrom)
        		and EventDate <= toDateTime(:dateTo)
        		and incomingRoute in ('CELLCI','ORGSBCI')
        	group by date
        	order by date]]></query>
        </QueryEntity>

<QueryEntity>
            <name>EricssonInternationalIncomingCause</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    		from ericsson
    		where   EventDate > toStartOfDay(now() - (86400*:days))
			and originForCharging not in ('0')
                    	and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I','L1MBC1I', 'L2MBC1I', 'L1MBC2I','L2MBC2I')
    		group by code
    		order by toInt16OrNull(code)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonInternationalIncomingCauseBetween</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    		from ericsson
    		where   EventDate >=  toDateTime(:dateFrom)
    			and EventDate <= toDateTime(:dateTo)
		    	and originForCharging not in ('0')
                    	and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I','L1MBC1I', 'L2MBC1I', 'L1MBC2I','L2MBC2I')
    		group by code
    		order by toInt16OrNull(code)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonInternationalOutgoingCause</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    		from ericsson
    		where   EventDate > toStartOfDay(now() - (86400*:days))
        		and originForCharging not in ('0')
        		and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O','L2MBC2O', 'ZURO')
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
        		and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O','L2MBC2O', 'ZURO')
    		group by code
    		order by toInt16OrNull(code)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonOnNetCause</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    		from ericsson
    		where   EventDate > toStartOfDay(now() - (86400*:days))
  			and originForCharging = '1'
  			and incomingRoute not in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I','L2MBC1I', 'L1MBC2I','L2MBC2I', 'CELLCI')
  			and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO')
  			and length(calledPartyNumber) > 7
  			and length(callingPartyNumber) > 7
    		group by code
    		order by toInt16OrNull(code)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonOnNetCauseBetween</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    		from ericsson
    		where EventDate >=  toDateTime(:dateFrom)
    			and EventDate <= toDateTime(:dateTo)
  			and originForCharging = '1'
  			and incomingRoute not in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I','L2MBC1I', 'L1MBC2I','L2MBC2I', 'CELLCI')
  			and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO')
  			and length(calledPartyNumber) > 7
  			and length(callingPartyNumber) > 7
    		group by code
    		order by toInt16OrNull(code)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonOffNetVoiceOutgoingCause</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    		from ericsson
    		where   EventDate > toStartOfDay(now() - (86400*:days))
    			and type in ('M_S_ORIGINATING', 'TRANSIT')
    			and outgoingRoute in ('CELLCO','ORGSBCO')
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
    			and outgoingRoute in ('CELLCO','ORGSBCO')
    		group by code
    		order by toInt16OrNull(code)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>EricssonOffNetVoiceIncomingCause</name>
            <query><![CDATA[select internalCauseAndLoc code, count() count
    		from ericsson
    		where   EventDate > toStartOfDay(now() - (86400*:days))
    			and originForCharging = '1'
    			and incomingRoutein ('CELLCI','ORGSBCI')
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
    			and incomingRoute in ('CELLCI','ORGSBCI')
    		group by code
    		order by toInt16OrNull(code)]]></query>
        </QueryEntity>

<QueryEntity>
            <name>EricssonMissedVTF1Default</name>
            <query><![CDATA[select filepath path,toUInt32(substring((splitByChar('/', filepath)[-1]),4,5)) sequence,max(EventDate) date
      		from ericsson
                where EventDate > toStartOfDay(now() - (86400*:days))
                	and filepath like '%VTF%'
                        and length(filepath) = 48
                group by filepath
                order by date,sequence ]]></query>
        </QueryEntity>

	<QueryEntity>
            <name>EricssonMissedVTF2Default</name>
            <query><![CDATA[select filepath path,toUInt32(substring((splitByChar('/', filepath)[-1]),4,5)) sequence,max(EventDate) date
    		from ericsson
    		where EventDate > toStartOfDay(now() - (86400*:days))
    			and filepath like '%VTF%'
    			and length(filepath) = 46
    		group by filepath
    		order by date,sequence]]></query>
        </QueryEntity>

	<QueryEntity>
            <name>EricssonMissedVTF1Between</name>
            <query><![CDATA[select filepath path,toUInt32(substring((splitByChar('/', filepath)[-1]),4,5)) sequence,max(EventDate) date
    		from ericsson
    		where   EventDate >=  toDateTime(:dateFrom)
    			and EventDate <= toDateTime(:dateTo)
    			and filepath like '%VTF%'
    			and length(filepath) = 48
    		group by filepath
    		order by date,sequence]]></query>
        </QueryEntity>

	<QueryEntity>
            <name>EricssonMissedVTF2Between</name>
            <query><![CDATA[select filepath path,toUInt32(substring((splitByChar('/', filepath)[-1]),4,5)) sequence,max(EventDate) date
    		from ericsson
    		where   EventDate >=  toDateTime(:dateFrom)
    			and EventDate <= toDateTime(:dateTo)
    			and filepath like '%VTF%'
    			and length(filepath) = 46
    		group by filepath
    		order by date,sequence]]></query>
	</QueryEntity>

	<QueryEntity>
            <name>EricssonMissedDataDefault</name>
            <query><![CDATA[select filePath path,toUInt32OrZero(substring((splitByChar('/', filePath)[-1]),27,5)) sequence,max(recordOpeningTime) date
    		from data_ericsson
    		where recordOpeningTime  > toStartOfDay(now() - (86400*:days))
     			and filePath like '%LIM%'
    		group by filePath
    		order by date,sequence]]></query>
        </QueryEntity>

	<QueryEntity>
            <name>EricssonMissedDataBetween</name>
            <query><![CDATA[select filePath path,toUInt32OrZero(substring((splitByChar('/', filePath)[-1]),27,5)) sequence,max(recordOpeningTime) date
    		from data_ericsson
    		where recordOpeningTime >= toDateTime(:dateFrom)
    			and recordOpeningTime < toDateTime(:dateTo)
    			and filePath like '%LIM%'
    		group by filePath
    		order by date,sequence]]></query>
        </QueryEntity>



<QueryEntity>
            <name>OrangeGetInternationalOutgoing</name>
            <query><![CDATA[select date,round(sum(callDuration)/60) duration
		from (
      			select callReference, toYYYYMMDD(eventTimeStamp) date, max(callDuration) callDuration
      			from zte
      			where eventTimeStamp > toStartOfDay(now() - (86400*:days))
        			and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
      			group by date,callReference
         		)
		group by date
		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangePostInternationalOutgoingByDay</name>
            <query><![CDATA[select date,round(sum(callDuration)/60) duration
		from (
      			select callReference, toYYYYMMDD(eventTimeStamp) date1, max(toString(toHour(eventTimeStamp))) date,max(callDuration) callDuration
      			from zte
      			where eventTimeStamp >=  toDateTime(:dateFrom)
	    			and eventTimeStamp < toDateTime(:dateTo)
        			and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
      			group by date1,callReference
         		)
		group by date
		order by toInt16(date)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeGetInternationalOutgoingBetween</name>
            <query><![CDATA[select date,round(sum(callDuration)/60) duration
		from (
      			select callReference, toYYYYMMDD(eventTimeStamp) date, max(callDuration) callDuration
      			from zte
      			where eventTimeStamp >=  toDateTime(:dateFrom)
    				and eventTimeStamp <= toDateTime(:dateTo)
        			and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
      			group by date,callReference
         		)
		group by date
		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeGetInternationalIncoming</name>
            <query><![CDATA[select date,round(sum(callDuration)/60) duration
		from (
      			select callReference, toYYYYMMDD(eventTimeStamp) date, max(callDuration) callDuration
      			from zte
      			where eventTimeStamp > toStartOfDay(now() - (86400*:days))
        			and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
      			group by date,callReference
         		)
		group by date
		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangePostInternationalIncomingByDay</name>
            <query><![CDATA[select date,round(sum(callDuration)/60) duration
		from (
      			select callReference, toYYYYMMDD(eventTimeStamp) date1, max(toString(toHour(eventTimeStamp))) date,max(callDuration) callDuration
      			from zte
      			where eventTimeStamp >=  toDateTime(:dateFrom)
	    			and eventTimeStamp < toDateTime(:dateTo)
        			and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
      			group by date1,callReference
         		)
		group by date
		order by toInt16(date)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeGetInternationalIncomingBetween</name>
            <query><![CDATA[select date,round(sum(callDuration)/60) duration
		from (
      			select callReference, toYYYYMMDD(eventTimeStamp) date, max(callDuration) callDuration
      			from zte
      			where eventTimeStamp >=  toDateTime(:dateFrom)
    				and eventTimeStamp <= toDateTime(:dateTo)
        			and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
      			group by date,callReference
         		)
		group by date
		order by date]]></query>
        </QueryEntity>

    <QueryEntity>
            <name>OrangeGetIncomingFromMTN</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date,round(sum(callDuration)/60)  duration
		from zte where eventTimeStamp > toStartOfDay(now() - (86400*:days))
    			and type not in ('MT_CALL_RECORD')
    			and incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangePostIncomingFromMTNByDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date,round(sum(callDuration)/60)  duration
		from zte where  eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp < toDateTime(:dateTo)
    			and type not in ('MT_CALL_RECORD')
    			and incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    		group by date
    		order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangePostIncomingFromMTNBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date,round(sum(callDuration)/60)  duration
    		from zte where eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp <= toDateTime(:dateTo)
    			and type not in ('MT_CALL_RECORD')
    			and incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeGetOutgoingToMTN</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date,round(sum(callDuration)/60) duration
    		from zte where eventTimeStamp > toStartOfDay(now() - (86400*:days))
    			and type not in ('MO_CALL_RECORD')
    			and outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangePostOutgoingToMTNByDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date,round(sum(callDuration)/60) duration
    		from zte where  eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp < toDateTime(:dateTo)
    			and type not in ('MO_CALL_RECORD')
    			and outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    		group by date
    		order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangePostOutgoingToMTNBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date,round(sum(callDuration)/60) duration
    		from zte where eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp <= toDateTime(:dateTo)
    			and type not in ('MO_CALL_RECORD')
    			and outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeGetOnNet</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date,round(sum(callDuration)/60) duration
    		from zte where eventTimeStamp > toStartOfDay(now() - (86400*:days))
    			and type in ('MO_CALL_RECORD','OUT_GATEWAY_RECORD','ROAM_RECORD','INC_GATEWAY_RECORD','MCF_CALL_RECORD','TERM_CAMEL_INT_RECORD')
    			and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    		group by date
    		order by date]]></query>
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
            <name>OrangeSearchByNumberBetweenDate</name>
            <query><![CDATA[select rowNumberInAllBlocks() id, case type when 'MO_CALL_RECORD' then 'Outgoing' else 'Incoming' end types, answerTime start_date,
        releaseTime end_date, callDuration as call_duration
        ,case when (substring((case when callingNumber = '' then servedMSISDN else callingNumber end),3)) like '38%'
            THEN substring((case when callingNumber = '' then servedMSISDN else callingNumber end),5)
            else substring((case when callingNumber = '' then servedMSISDN else callingNumber end),3)
            end  as calling_number
        ,substring((case when calledNumber = '' then servedMSISDN else calledNumber end),3) as called_number
        ,servedIMEI imei
from    zte
where   type in ('MO_CALL_RECORD', 'MT_CALL_RECORD')
        and eventTimeStamp >= toDateTime(:startDate)
        and eventTimeStamp <= toDateTime(:endDate)
        and (servedMSISDN like (:phoneNumber))
order by end_date]]></query>
        </QueryEntity>


<QueryEntity>
            <name>OrangeACDInternationalOutgoingDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
    			and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeACDInternationalOutgoingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(count() / round(sum(callDuration) / 60),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp < toDateTime(:dateTo)
    		group by date
    		order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeACDInternationalOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp <= toDateTime(:dateTo)
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
            <name>OrangeACDInternationalIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    		from zte
		where type = 'MT_CALL_RECORD'
    			and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp <= toDateTime(:dateTo)
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeACDOffNetIncomingDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    		from zte where type = 'MT_CALL_RECORD'
    			and incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    			and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeACDOffNetIncomingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(count() / round(sum(callDuration) / 60),4) duration
    		from zte
		where type = 'MT_CALL_RECORD'
    			and incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp < toDateTime(:dateTo)
    		group by date
    		order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeACDOffNetIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    		from zte
		where type = 'MT_CALL_RECORD'
    			and incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp <= toDateTime(:dateTo)
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeACDOffNetOutgoingDefault</name>
            <query><![CDATA[select  toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    		from zte where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    			and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeACDOffNetOutgoingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(count() / round(sum(callDuration) / 60),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp < toDateTime(:dateTo)
    		group by date
    		order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeACDOffNetOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp <= toDateTime(:dateTo)
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
            <name>OrangeACDOnNetDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(count() / round(sum(callDuration) / 60),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp < toDateTime(:dateTo)
    		group by date
    		order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeACDOnNetBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(count() / round(sum(callDuration) / 60),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp <= toDateTime(:dateTo)
    		group by date
    		order by date]]></query>
        </QueryEntity>


<QueryEntity>
            <name>OrangeASRInternationalOutgoingDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
    			and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeASRInternationalOutgoingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp < toDateTime(:dateTo)
    		group by date
    		order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeASRInternationalOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp <= toDateTime(:dateTo)
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeASRInternationalIncomingDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MT_CALL_RECORD'
    			and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    			and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeASRInternationalIncomingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MT_CALL_RECORD'
    			and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp < toDateTime(:dateTo)
    		group by date
    		order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>

       <QueryEntity>
            <name>OrangeASRInternationalIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MT_CALL_RECORD'
    			and incomingTKGPName in ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp <= toDateTime(:dateTo)
    		group by date
    		order by date]]></query>
        </QueryEntity>

	<QueryEntity>
            <name>OrangeASROffNetIncomingDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MT_CALL_RECORD'
    			and incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    			and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeASROffNetIncomingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MT_CALL_RECORD'
    			and incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp < toDateTime(:dateTo)
    		group by date
    		order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeASROffNetIncomingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MT_CALL_RECORD'
    			and incomingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp <= toDateTime(:dateTo)
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeASROffNetOutgoingDefault</name>
            <query><![CDATA[select  toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    			and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    		group by date
    		rder by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeASROffNetOutgoingDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp < toDateTime(:dateTo)
    		group by date
    		order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeASROffNetOutgoingBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('Comium', 'LoneStar','MSC_SBC_MTN')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp <= toDateTime(:dateTo)
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeASROnNetDefault</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    			and eventTimeStamp > toStartOfDay(now() - (86400*:days))
    		group by date
    		order by date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeASROnNetDay</name>
            <query><![CDATA[select toString(toHour(eventTimeStamp)) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp < toDateTime(:dateTo)
    		group by date
    		order by toHour(eventTimeStamp)]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeASROnNetBetween</name>
            <query><![CDATA[select toYYYYMMDD(eventTimeStamp) date, round(sum(case when callDuration = 0 then 0 else 1 end) / count(),4) duration
    		from zte
		where type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
    			and eventTimeStamp >=  toDateTime(:dateFrom)
    			and eventTimeStamp <= toDateTime(:dateTo)
    		group by date
    		order by date]]></query>
        </QueryEntity>


<QueryEntity>
            <name>OrangeInternationalOutgoingCauseDefault</name>
            <query><![CDATA[select causeForTerm code, count() count
    		from zte
    		where eventTimeStamp > toStartOfDay(now() - (86400*:days))
    			and type = 'MO_CALL_RECORD'
    			and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
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
    			and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
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
            <query><![CDATA[select filePath path,toUInt32OrZero(substring((splitByChar('/', filePath)[-1]),14,5)) sequence,max(recordOpeningTime) date
    		from data_zte
    		where recordOpeningTime  > toStartOfDay(now() - (86400*:days))
    		group by path
    		order by date,sequence]]></query>
        </QueryEntity>

	<QueryEntity>
            <name>OrangeMissedDataBetween</name>
            <query><![CDATA[select filePath path,toUInt32OrZero(substring((splitByChar('/', filePath)[-1]),14,5)) sequence,max(recordOpeningTime) date
    		from data_zte
    		where recordOpeningTime >= toDateTime(:dateFrom)
    			and recordOpeningTime < toDateTime(:dateTo)
    		group by path
     		order by date,sequence]]></query>
        </QueryEntity>

<QueryEntity>
            <name>EricssonSearchByNumberBetweenDate</name>
            <query><![CDATA[select  rowNumberInAllBlocks() id,types,start_date,end_date,calling_number,called_number,IMEI
                            from (
                            select  'Outgoing' types,
                                    substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12) start_date,
                                    substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(chargeableDuration), 12) end_date,
                                    substring(callingPartyNumber, 3) calling_number
                                    ,case   when calledPartyNumber like '120%' and substring(calledPartyNumber, 1, 5) not in ('12055', '12077', '12088')
                                            then substring(calledPartyNumber, 6)
                                            else substring(calledPartyNumber, 3) end as called_number
                                    ,callingSubscriberIMEI IMEI
                            from 	ericsson
                            where	EventDate >= toDateTime(:startDate)
                                    and EventDate <= toDateTime(:endDate)
                                    and type in ('M_S_ORIGINATING')
                                    and callingPartyNumber like (:phoneNumber)
                            union all
                            select  'Incoming' types,
                                    substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12) start_date,
                                    substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(chargeableDuration), 12) end_date,
                                    substring(callingPartyNumber, 3) calling_number
                                    ,substring(calledPartyNumber, 3) called_number
                                    ,calledSubscriberIMEI IMEI
                            from 	ericsson
                            where	EventDate >= toDateTime(:startDate)
                                    and EventDate <= toDateTime(:endDate)
                                    and type in ('M_S_TERMINATING')
                                    and calledPartyNumber like (:phoneNumber)
                            )order by start_date,end_date]]></query>
        </QueryEntity>

        <QueryEntity>
            <name>OrangeSearchByNumberBetweenDate</name>
            <query><![CDATA[select rowNumberInAllBlocks() id,types,start_date,end_date,call_duration,calling_number,called_number,IMEI
                            from (
                            select  'Outgoing' types, answerTime start_date,releaseTime end_date,callDuration call_duration,
                                    substring(servedMSISDN,3) calling_number,substring(dialledNumber,3) called_number,servedIMEI IMEI
                            from 	zte
                            where	type in ('MO_CALL_RECORD')
                            	and eventTimeStamp >= toDateTime(:startDate)
                            	and eventTimeStamp <= toDateTime(:endDate)
                            	and (servedMSISDN like (:phoneNumber))
                            union all
                            select  'Incoming' types, answerTime start_date,releaseTime end_date,callDuration call_duration,
                                    substring(callingNumber,5) calling_number,substring(servedMSISDN,3) called_number,servedIMEI IMEI
                            from 	zte
                            where	type in ('MT_CALL_RECORD')
                            	and eventTimeStamp >= toDateTime(:startDate)
                            	and eventTimeStamp <= toDateTime(:endDate)
                            	and (servedMSISDN like (:phoneNumber))
                            ) order by  start_date]]></query>
        </QueryEntity>

    </queries>
</QueryList>
