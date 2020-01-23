require_relative "common"
require_relative "selenium_helper"
require_relative "rakuten/rakuten_parser"
require_relative "qoo10/qoo10_parser"

Qoo10.new.check_price
Rakuten.new.check_price
