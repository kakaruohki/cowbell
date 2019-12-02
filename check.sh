#!/bin/sh
cd $(dirname $0)
while :
do
  bundle exec ruby check_price.rb
  sleep 3600
done
