Given /^I have an? "([^"]*)" YAML file with content:$/ do |filename, text|
  filename = "#{filename}.yml" unless filename.end_with? '.yml'

  ::File.write(::File.join(@tmpdir, filename), text)
end

And /^I load drivers from the "([^"]*)" file$/ do |file|
  begin
    @error = nil
    QAT::Web::Browser::Loader.load(::File.join(@tmpdir, file))
  rescue => @error
    log.error @error
  end
end