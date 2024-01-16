Then /^no exception is raised$/ do
  message = "Expected no exception but found a #{@error.class}"
  message << " (#{@error.message})\n#{@error.backtrace.join("\n")}" if @error.respond_to?(:message)
  refute @error, message
end