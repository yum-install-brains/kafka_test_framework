#!/usr/bin/env bash


brokerConnectionString=$(connection_string_from_array ${brokerPort} "${brokers[@]}")
# Default variables
bufferMemory=16000000
acks="all"

function run_producer {
	kafka-run-class org.apache.kafka.tools.ProducerPerformance \
	--topic=${topicName} \
	--num-records=${numRecords} \
	--throughput=-1 \
	--record-size=${recordSizeBytes} \
	--producer-props bootstrap.servers=${brokerConnectionString} \
		compression.type=${compressionType} \
		batch.size=${batchSize} \
		buffer.memory=${bufferMemory} \
		acks=${acks} \
		client.id=${clientID} \
	--print-metrics
}

# Spwan numProducers in background and wait for all of them to finish
function produce {
	for (( i=1; i<=${numProducers}; i++ ))
	do
		run_producer > ${baseDir}/producer_test_${i}.log &

		# do not spawn new producer processes too fast
		sleep 1
	done

	wait
}
