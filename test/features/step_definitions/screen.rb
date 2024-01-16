When /^I load virtual screen definitions$/ do
  begin
    @error = nil
    QAT::Web::Screen::Loader.load(::File.join(@tmpdir, 'screens.yml'))
  rescue => @error
  end
end

And /^I request a virtual screen( without destroying the last one)?$/ do |keep_screen|
  if keep_screen and QAT::Web::Screen::Factory.current_screen
    @old_screen_variable = QAT::Web::Screen::Factory.current_screen
    QAT::Web::Screen::Factory.instance_exec { @current_screen=nil }
  end

  begin
    @error = nil
    QAT::Web::Screen::Factory.for
  rescue => @error
  end
end

Then /^a virtual screen is( not)? created$/ do |negated|
  begin
    if negated
      refute QAT::Web::Screen::Factory.current_screen.xvfb, "Expected no virtual screen, but one was created"
    else
      refute_nil QAT::Web::Screen::Factory.current_screen.xvfb, "Expected a virtual screen, but none was created"
    end
  rescue Minitest::Assertion
    log.warn { @error } if @error
    raise
  end
end

And /^the current screen video settings are:$/ do |table|
  video_settings = QAT::Web::Screen::Factory.current_screen.xvfb.video

  table.hashes.each do |line|
    line.each do |property, value|
      assert_equal value, video_settings.instance_variable_get("@#{property}").to_s, "Unexpected value for property #{property}"
    end
  end
end

And /^the current screen video is( not)? recording$/ do |negative|
  is_recording = QAT::Web::Screen::Factory.current_screen.video_capture_running?
  if negative
    refute is_recording, 'Expected video recording not to be running, but it is'
  else
    assert is_recording, "Expected video recording to be running, but it isn't"
  end
end

When /^I start recording a video of the current screen$/ do
  QAT::Web::Screen::Factory.current_screen.start_video_capture
end

When /^I save the current screen video(?: to file "([^"]*)")?$/ do |file|
  if file
    @video_file = File.join @tmpdir, file
    QAT::Web::Screen::Factory.current_screen.stop_and_save_video_capture @video_file
  else
    QAT::Web::Screen::Factory.current_screen.stop_and_save_video_capture
  end
end

Then /^a video file is( not)? present$/ do |negative|
  if negative
    refute File.exist?(@video_file), "Expected to not find video file #{@video_file} but it present!"
  else
    Retriable.retriable on:            Minitest::Assertion,
                        base_interval: 1 do
      assert File.exist?(@video_file), "Expected to find video file #{@video_file} but it was not found!"
    end
  end
end

When(/^I discard the current screen video$/) do
  QAT::Web::Screen::Factory.current_screen.stop_and_discard_video_capture
end