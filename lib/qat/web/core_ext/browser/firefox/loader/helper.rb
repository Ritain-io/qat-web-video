module QAT::Web
  module Browser
    module Loader

      private

      def maximize_browser_window(driver, screen)
        if screen.xvfb
          driver.resize_window_to(driver.current_window_handle, screen.width, screen.height)

          screen.start_video_capture if %w(always success failure).include? ENV['QAT_WEB_VIDEO_MODE']
        else
          driver.maximize_window(driver.current_window_handle) if driver.respond_to? :maximize_window
        end
      end
    end
  end
end