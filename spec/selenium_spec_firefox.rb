# frozen_string_literal: true
require 'spec_helper'
require "selenium-webdriver"
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

Capybara.register_driver :selenium_firefox do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox(marionette: false)
  )
end

module TestSessions
  Selenium = Capybara::Session.new(:selenium_firefox, TestApp)
end

skipped_tests = [
  :response_headers,
  :status_code,
  :trigger
]
skipped_tests << :windows if ENV['TRAVIS'] && !ENV['WINDOW_TEST']

Capybara::SpecHelper.run_specs TestSessions::Selenium, "selenium", capybara_skip: skipped_tests

RSpec.describe "Capybara::Session with legacy firefox" do
  include_examples  "Capybara::Session", TestSessions::Selenium, :selenium_firefox
  include_examples  Capybara::RSpecMatchers, TestSessions::Selenium, :selenium_firefox
end

RSpec.describe Capybara::Selenium::Driver do
  before do
    @driver = Capybara::Selenium::Driver.new(TestApp, browser: :firefox, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox(marionette: false))
  end

  describe '#quit' do
    it "should reset browser when quit" do
      expect(@driver.browser).to be
      @driver.quit
      #access instance variable directly so we don't create a new browser instance
      expect(@driver.instance_variable_get(:@browser)).to be_nil
    end
  end
end

