#!/usr/bin/env bash


function connection_string_from_array {
  local port=$1
  shift
  local hostArray=("$@")
  local connectionString=""

  for element in "${hostArray[@]}"
  do
    connectionString+=${element}":"${port}","
  done

  # we can't return strings in bash functions
  # return ${connectionString}

  echo "${connectionString}"
}