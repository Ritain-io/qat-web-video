require 'qat/web/screen/loader'
require 'headless/core_ext/random_display'
require 'qat/logger'
require 'headless_ext'

module QAT::Web
  module Screen

    #Screen wrapper to represent an abstract display. Can have a Headless instance associated.
    class Wrapper
      include QAT::Logger

      # Video recording configurations exception
      #@since 6.0.0
      class VideoRecordingConfigError < StandardError
      end

      #Start a new Xvfb instance
      #@return [Headless] Xvfb instance
      #@since 6.0.0
      def start
        if %w(always success failure).include?(ENV['QAT_WEB_VIDEO_MODE']) and (@options[:video].nil? or @options[:video].empty?)
          raise(VideoRecordingConfigError, "Video recording configuration is missing!")
        end

        @xvfb = Headless.new @options
        @xvfb.start
        log.info "Xvfb #{name} screen started"
        @xvfb
      end

      #Start Xvfb web capture
      #@since 6.0.0
      def start_video_capture
        @xvfb.video.start_capture
        log.debug "Started video capture"
      end

      #Stop Xvfb web capture and discard the recorded web
      #@since 6.0.0
      def stop_and_discard_video_capture
        return unless video_capture_running?
        @xvfb.video.stop_and_discard
        log.debug "Stopped and discarded video capture"
      end

      #Stop Xvfb web capture and save the recorded web
      #@since 6.0.0
      def stop_and_save_video_capture(path = nil)
        return unless video_capture_running?
        path ||= self.class.default_video_name
        @xvfb.video.stop_and_save path
        log.info "Saving video capture to #{path}"
        path
      end

      #Check if Xvfb web capture is running
      #@since 6.0.0
      def video_capture_running?
        return false unless @xvfb
        return false if ENV['QAT_WEB_VIDEO_MODE'] == 'never'
        @xvfb.video.capture_running?.tap { |value| log.debug "Video capture#{value ? '' : ' not'} running" }
      rescue Headless::Exception => e
        log.debug { "An error occurred while checking web recording:" }
        log.debug { e }
        log.debug { "Assuming video capture is not running" }
        false
      end

      def self.default_video_name
        return @@default_video_name ||= "video.mkv"
      end

      def self.default_video_name=(path)
        @@default_video_name = path
      end

    end
  end
end