#!/usr/bin/env bash

numTests=$((${#recordSizeArray[@]} * ${#compressionTypeArray[@]} * ${#batchSizeArray[@]} * ${#partitionNumberArray[@]}))
currentTest=1

function run_test {
  create_topic

  testStartDate=$(date +"%H:%M:%S")

  >&2 echo "mode: ${mode}, testStartDate: ${testStartDate}, test: ${currentTest}/${numTests}"

  if [[ ${mode} == "produce" ]]
  then
    produce
  else
    # generate some data to read 1st
    produce
    consume
  fi

  testEndDate=$(date +"%H:%M:%S")

  print_test_result

#  if [[ ${mode} == "consume" ]]
#  then
#    delete_topic
#  fi

  clean_test_logs
  currentTest=$((currentTest+1))
}
