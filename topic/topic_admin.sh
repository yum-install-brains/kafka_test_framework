#!/usr/bin/env bash


brokerConnectionString=$(connection_string_from_array ${brokerPort} "${brokers[@]}")
zookeeperConnectionString=$(connection_string_from_array ${zookeeperPort} "${zookeepers[@]}")

# delete_topic удаляет топик ${topicName}, определяемый в файле config.sh из кластера
# операция удаления топика в Kafka асинхронная, поэтому в функции delete_topic стоит ожидание реального
# удаления топика из кластера.
# Удаление происходит при запуске каждого consume теста для предотвращения чтения событий разного размера
function delete_topic {
	kafka-topics \
	--delete \
	--zookeeper ${zookeeperConnectionString} \
	--topic ${topicName} > /dev/null 2>&1

	# Topics are deleted asyncronously. It could take some time for command to complete
	while [[ -n $(kafka-topics --describe --zookeeper ${zookeeperConnectionString} --topic ${topicName}) ]]
	do
		>&2 echo "WARN: topic was not removed. Will retry."
		sleep 10
	done
}

# create_topic создает топик ${topicName}, определяемый в файле config.sh
# Если топик с таким именем уже есть в кластере, он будет использован для тестов без изменения параметров конфигурации
function create_topic {
	local partitionRetentionBytes=5000000000 # 5 GB per partition
	local deleteRetentionMs=3600000 # 1 hour
	# topic level and producer level configuration name for compression are different
	local topicCompressionType=""

	if [[ ${compressionType} == "none" ]]
	then
		topicCompressionType="uncompressed"
	else
		topicCompressionType=${compressionType}
	fi

	if [[ $(kafka-topics --describe --zookeeper ${zookeeperConnectionString} --topic ${topicName}) ]]
	then
		>&2 echo "WARN: topic already exists. Will not try to recreate it."
		return
	fi

	kafka-topics \
	--create \
	--zookeeper ${zookeeperConnectionString} \
	--topic ${topicName} \
	--partitions ${partitionNumber} \
	--replication-factor $topicReplicationFactor \
	--config min.insync.replicas=2 \
	--config unclean.leader.election.enable=false > /dev/null

	kafka-configs \
	--zookeeper ${zookeeperConnectionString} \
	--entity-type topics \
	--entity-name ${topicName} \
	--alter \
	--add-config "retention.bytes=${partitionRetentionBytes},delete.retention.ms=${deleteRetentionMs},compression.type=${topicCompressionType}" > /dev/null
}
