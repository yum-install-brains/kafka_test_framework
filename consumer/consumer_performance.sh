#!/usr/bin/env bash


brokerConnectionString=$(connection_string_from_array ${brokerPort} "${brokers[@]}")

function run_consumer {
  kafka-run-class kafka.tools.ConsumerPerformance  \
  --broker-list ${brokerConnectionString} \
  --topic=${topicName} \
  --consumer.config ${baseDir}/consumer.properties \
  --group ${topicName}_consumer_group \
  --messages=${numRecords} \
  --print-metrics \
  --threads ${numConsumerThreads}
}

# Spwan numProducers in background and wait for all of them to finish
function consume {
    local fetchMaxWaitMS=100
    local enableAutoCommit="true"
    local autoCommitIntervalMS=100
    local rackID="localRack"

    # Сбрасываем офсет группы в начало топика
    kafka-consumer-groups \
        --bootstrap-server ${brokerConnectionString} \
        --group ${topicName}_consumer_group \
        --topic ${topicName} \
        --execute --reset-offsets  --to-earliest  > /dev/null 2>&1


	for (( i=1; i<=${numConsumers}; i++ ))
	do
	    printf  "fetch.min.bytes=%s\n \
                 fetch.max.wait.ms=%s\n \
                 enable.auto.commit=%s\n \
                 auto.commit.interval.ms=%d\n \
                 client.rack=%s\n \
                 client.id=%s" \
                 ${batchSize} \
                 ${fetchMaxWaitMS} \
                 ${enableAutoCommit} \
                 ${autoCommitIntervalMS} \
                 ${rackID} \
                 ${clientID} \
        > ${baseDir}/consumer.properties

		run_consumer > ${baseDir}/consumer_test_${i}.log &

		# do not spawn new consumer processes too fast
		sleep 1
	done

	wait
}
