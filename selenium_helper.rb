class SeleniumHelper
  attr_accessor :session
  attr_accessor :sleep_time
  attr_accessor :timeout_wait
  def initialize(sleep_time: 1)
    @sleep_time = sleep_time
    # Selenium::WebDriver::Chrome.driver_path = "/mnt/c/chromedriver.exe"
    ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36"
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--user-agent=#{ua}')
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-setuid-sandbox')
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.read_timeout = timeout_wait
    client.open_timeout = timeout_wait
    @session = Selenium::WebDriver.for :chrome, options: options, http_client: client
    @session.manage.timeouts.implicit_wait = timeout_wait
  end

  def timeout_wait
    return 300 if @timeout_wait.nil?
    @timeout_wait
  end

  def sleep_designated
    sleep @sleep_time
  end

  def query_click(css_selector)
    javascript_statement = %Q{document.querySelector("#{css_selector}").click()}
    @session.execute_script(javascript_statement)
    sleep_designated
    self
  end

  def switch_frame(*css_selectors)
    @session.switch_to.window @session.window_handle
    css_selectors.each do |css_selector|
      iframe = @session.find_element(:css,css_selector)
      @session.switch_to.frame(iframe)
    end
  end

  def css_exist?(css_selector)
    rescue_session = @session
    rescue_session.manage.timeouts.implicit_wait = 5
    rescue_session.find_elements(:css,css_selector).present?
  end
  def send_value(css_selector,value)
    javascript_statement = %Q{document.querySelector("#{css_selector}").value = "#{value}"}
    @session.execute_script(javascript_statement)
  end

  def html
    @session.page_source
  end
end
