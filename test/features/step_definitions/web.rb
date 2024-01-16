Given /^I (?:have|ask for) a "([^"]*)" driver$/ do |driver|
  begin
    @error = nil
    QAT::Web::Browser::Factory.for driver
  rescue => @error
  end
end

When /^I visit "([^"]*)"$/ do |site|
  Retriable.retriable(on:       [::Selenium::WebDriver::Error::WebDriverError, ::Net::ReadTimeout],
                      on_retry: (proc do |_, _, _, _|
                        driver = Capybara.current_driver
                        Capybara.current_session.reset!
                        QAT::Web::Browser::Factory.for driver
                      end)) do
    visit site
  end
end