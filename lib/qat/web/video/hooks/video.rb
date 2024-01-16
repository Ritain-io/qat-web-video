require 'qat/web/hooks/common'
require 'qat/web/exceptions'
require_relative '../../video'

module QAT::Web
  module Exceptions
    VIDEO = GLOBAL.dup
  end
end

Before do |scenario|
  QAT::Web::Screen::Wrapper.default_video_name = File.join('public', "#{QAT::Web::Hooks::Common.scenario_tag(scenario)}.mkv")

  if %w(always success failure).include?(ENV['QAT_WEB_VIDEO_MODE']) and QAT::Web::Screen::Factory.current_screen and not QAT::Web::Screen::Factory.current_screen.video_capture_running?
    QAT::Web::Screen::Factory.current_screen.start_video_capture
  end
end

After do |scenario|
  if ENV['QAT_WEB_VIDEO_MODE'] and QAT::Web::Screen::Factory.current_screen and QAT::Web::Screen::Factory.current_screen.video_capture_running?
    case ENV['QAT_WEB_VIDEO_MODE']
      when 'always'
        attach QAT::Web::Screen::Factory.current_screen.stop_and_save_video_capture, 'video/mp4'
      when 'success'
        if scenario.passed?
          attach QAT::Web::Screen::Factory.current_screen.stop_and_save_video_capture, 'video/mp4'
        else
          QAT::Web::Screen::Factory.current_screen.stop_and_discard_video_capture
        end
      when 'failure'
        if scenario.failed? and QAT::Web::Exceptions::VIDEO.any? { |exception| scenario.exception.kind_of?(exception) }
          attach QAT::Web::Screen::Factory.current_screen.stop_and_save_video_capture, 'video/mp4'
        else
          QAT::Web::Screen::Factory.current_screen.stop_and_discard_video_capture
        end
    end
  end
end