# Kafka performance tests framework
Обертка над встроенными в Kafka утилитами `org.apache.kafka.tools.ProducerPerformance` и `kafka.tools.ConsumerPerformance`.
Позволяет конфигурировать серии тестов с различными параметрами конфигурации топиков и клиентов.
Результаты тестов выводятся в stdout в json-like виде.

## Описание и назначение
Целью является определение оптимальных параметров конфигурации клиентов и брокера.

## Пример запуска
```bash
# Тест producer'а
./kafka_run_tests.sh -n 10000000   \
  > /tmp/kafka_producer.log 2>/tmp/kafka_producer.error.log &; tail -f /tmp/kafka_producer.log
# Тест producer'а и consumer'а
./kafka_run_tests.sh -m 'consume' -n 10000000   \
  > /tmp/kafka_consumer.log 2>/tmp/kafka_consumer.error.log &; tail -f /tmp/kafka_consumer.log
```

## Требования
Kafka 2.4

## Параметры по умолчанию
topic:
- min.insync.replicas=2
- config unclean.leader.election.enable=false
- delete.retention.ms=300000
- retention.bytes=50000000000

producer:
- acks=all
- enable.idempotence=true
- buffer.memory=16000000

consumer:
- fetch.max.wait.ms=100
- enable.auto.commit=true
- auto.commit.interval.ms=1000

## Алгоритм работы
1. Запускается kafka_run_tests
2. Запускается kafka_init_topic
3. Запускаетя kafka_producer или kafka_producer + kafka_consumer
4. Запускается kafka_results и формируются результаты теста
5. Возвращаемся на шаг 2

## Ограничения
- порт Kafka/ZK задается сразу на весь кластер, для тестирования на одной физической машине с разными портами нужна небольшая доработка
- rackID не прокидывается в конфиг, а задается хардкодом в параметрах консьюмера