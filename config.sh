#!/usr/bin/env bash


# Broker list
# brokers=("host1" "host2" "host3")
brokers=("localhost")
brokerPort=9092

# Zookeeper list
# zookeepers=("host1" "host2" "host3")
zookeepers=("localhost")
zookeeperPort=2181

# Topic configuration
topicReplicationFactor=1
topicName="test"

# Number of clients
clientID="performance-test-client"
numProducers=1
numConsumers=1
numConsumerThreads=1

# Performance test configuration
recordSizeArray=(1000)
compressionTypeArray=("lz4")
# batch size in bytes (default 16384)
batchSizeArray=(32768 65536)
partitionNumberArray=(9)
