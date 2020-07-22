#!/usr/bin/env bash
# Модуль, отвечающий за запуск тестов throughput и latency для producer/consumer
# Примеры запуска
# ./kafka_run_tests.sh -m 'produce'				 -n 100000	 > /tmp/kafka_producer.log
# ./kafka_run_tests.sh -m 'consume'				 -n 1000000	> /tmp/kafka_consumer.log
# Аргументы
# m: [producer, consumer, producerconsumer] – режим тестирования
# n: [1-inf] – число сообщений от одного producer'a


# Заносим все переменные в окружение чтобы использовать их в внутренних вызовах
set -ae

# Export config and packages
source config.sh
source utils/connection_string_from_array.sh
source utils/print_test_result.sh
source topic/topic_admin.sh
source producer/producer_performance.sh
source consumer/consumer_performance.sh
source test/run_test.sh

baseDir=$(pwd)
# Default variables
mode="consume"
numRecords=100000

# Command line arguments
while getopts ":m:n:" opt; do
	case $opt in
		m) mode="$OPTARG"
		;;
		n) numRecords="$OPTARG"
		;;
		\?) echo "Invalid option -$OPTARG" >&2
		;;
	esac
done

# Запускаем перебор параметров
for recordSizeBytes in "${recordSizeArray[@]}"
do
	for compressionType in "${compressionTypeArray[@]}"
	do
		for batchSize in "${batchSizeArray[@]}"
		do
			for partitionNumber in "${partitionNumberArray[@]}"
			do
				run_test
			done # end partitions
		done # end batch size
	done # end compression
done # end record size
