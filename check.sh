#!/bin/sh
cd $(dirname $0)
while :
do
  echo start
  date
  bundle exec ruby check_price.rb
  echo end
  date
  sleep 3600
done
