#!/usr/bin/env bash


function grep_producer_logs {
	for (( i=1; i<=${numProducers}; i++ ))
	do
	awk \
	-v mode=${mode} \
	-v numRecords=${numRecords} \
	-v testStartDate=${testStartDate} \
	-v testEndDate=${testEndDate} \
	-v recordSizeBytes=${recordSizeBytes} \
	-v compressionType=${compressionType} \
	-v batchSize=${batchSize} \
	-v partitionNumber=${partitionNumber} \
	'BEGIN{ \
				print "{"; \
				print "\"mode\":" "\"produce\"" ","; \
				print "\"numRecords\":" numRecords ","; \
				print "\"testStartDate\":" "\""testStartDate"\"" ","; \
				print "\"testEndDate\":" "\""testEndDate"\"" ","; \
				print "\"recordSizeBytes\":" recordSizeBytes ","; \
				print "\"compressionType\":" "\""compressionType"\"" ","; \
				print "\"batchSize\":" batchSize ","; \
				print "\"partitionNumber\":" partitionNumber ","; \
				} \
				/99.9th./{print "\"recordsSec\":" $4 ","} \
				/99.9th./{print "\"latencyAvg\":" $8 ","} \
				/99.9th./{print "\"latency99\":" $25 ","} \
				/producer-metrics:request-rate:\{client-id='${clientID}'producer-1\}/{print "\"requestRate\":" $3 ","} \
				/producer-metrics:response-rate:\{client-id='${clientID}'\}/{print "\"responseRate\":" $3 ","} \
				/producer-metrics:request-latency-avg:\{client-id='${clientID}'\}/{print "\"requestLatencyAvg\":" $3 ","} \
				/producer-metrics:io-wait-time-ns-avg:\{client-id='${clientID}'\}/{print "\"ioWaitTimeNsAvg\":" $3 ","} \
				/producer-metrics:record-send-rate:\{client-id='${clientID}'\}/{print "\"recordSendRate\":" $3 ","} \
				/producer-topic-metrics:byte-rate:\{client-id='${clientID}', topic='${topicName}'\}/{print "\"byteRate\":" $4} \
				END{print "},"}' ${baseDir}/producer_test_${i}.log
	done
}

function grep_consumer_logs {
	for (( i=1; i<=${numConsumers}; i++ ))
	do
	awk \
	-v numRecords=${numRecords} \
	-v testStartDate=${testStartDate} \
	-v testEndDate=${testEndDate} \
	-v recordSizeBytes=${recordSizeBytes} \
	-v compressionType=${compressionType} \
	-v batchSize=${batchSize} \
	-v partitionNumber=${partitionNumber} \
	'BEGIN{ \
				print "{"; \
				print "\"mode\":" "\"consume\"" ","; \
				print "\"numRecords\":" numRecords ","; \
				print "\"testStartDate\":" "\""testStartDate"\"" ","; \
				print "\"testEndDate\":" "\""testEndDate"\"" ","; \
				print "\"recordSizeBytes\":" recordSizeBytes ","; \
				print "\"compressionType\":" "\""compressionType"\"" ","; \
				print "\"batchSize\":" batchSize ","; \
				print "\"partitionNumber\":" partitionNumber ","; \
				} \
				/consumer-coordinator-metrics:commit-latency-avg:\{client-id='${clientID}'\}/{print "\"commitLatencyAvg\":" $3 ","} \
				/consumer-fetch-manager-metrics:bytes-consumed-rate:\{client-id='${clientID}', topic='${topicName}'\}/{print "\"byteRate\":" $4 ","} \
				/consumer-fetch-manager-metrics:fetch-latency-avg:\{client-id='${clientID}'\}/{print "\"fetchLatencyAvg\":" $3 ","} \
				/consumer-fetch-manager-metrics:records-consumed-rate:\{client-id='${clientID}'\}/{print "\"recordsSec\":" $3 ","} \
				/consumer-fetch-manager-metrics:records-per-request-avg:\{client-id='${clientID}'\}/{print "\"recordsPerRequestAvg\":" $3} \

				END{print "},"}' ${baseDir}/consumer_test_${i}.log
	done
}

function print_test_result {
	if [[ ${mode} == "produce" ]]
	then
		grep_producer_logs
	else
	    grep_producer_logs
		grep_consumer_logs
	fi
}

function clean_test_logs {
    if [[ ${mode} == "produce" ]]
	then
	    for (( i=1; i<=${numProducers}; i++ ))
        do
            rm ${baseDir}/producer_test_${i}.log
        done
	else
	    rm ${baseDir}/consumer.properties
        for (( i=1; i<=${numConsumers}; i++ ))
        do
            rm ${baseDir}/consumer_test_${i}.log
        done
	fi
}
