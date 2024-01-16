require 'fileutils'
require 'qat/logger'
require 'httparty'

Around do |_, block|
  Dir.mktmpdir do |dir|
    @tmpdir = dir
    block.call
  end
end

Before '@video_recording' do
  require 'selenium-webdriver'
  @video_file                                  = File.join @tmpdir, "video_#{Time.now.to_i}.mkv"
  QAT::Web::Screen::Wrapper.default_video_name = @video_file
end

After '@video_recording' do
  if QAT::Web::Screen::Factory.current_screen&.video_capture_running?
    QAT::Web::Screen::Factory.current_screen.stop_and_discard_video_capture
  end
end

After do
  if @old_screen_variable
    @old_screen_variable.destroy
  end

  if QAT::Web::Screen::Factory.current_screen
    QAT::Web::Screen::Factory.current_screen.destroy
    QAT::Web::Screen::Factory.instance_exec { @current_screen = nil }
  end

  Capybara.class_exec do
    unless session_pool.empty?
      if current_session.instance_variable_defined? :@driver and current_session.driver.respond_to? :quit
        current_session.driver.quit rescue Selenium::WebDriver::Error::WebDriverError
      end
      session_pool.delete "#{current_driver}:#{session_name}:#{app.object_id}"
    end
  end

  if Capybara.drivers
    Capybara.drivers.delete_if { |k, _| k.to_s =~ /^(?:custom|my)_/ }
  end
end

module Hooks
  module Sinatra
    include QAT::Logger
    extend self

    def sinatra_path
      @path ||= File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'sinatra'))
    end

    def pid_filename
      @pid_file ||= "/tmp/sinatra_#{Time.now.to_i}.pid"
    end

    def sinatra_log_file
      unless @sinatra_log_file
        @sinatra_log_file ||= File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'public', 'sinatra.log'))
        File.open(@sinatra_log_file, 'w') {}
      end
      @sinatra_log_file
    end

    def start_app
      if File.exist? pid_filename
        begin
          Process.getpgid(File.read(pid_filename).to_i)
        rescue Errno::ESRCH
          log.warn 'PID file found but process does not exist...Removing File!'
          File.delete pid_filename
        end
      end

      unless File.exist? pid_filename
        log.info 'Sinatra server not running, starting a new one...'

        pid = nil
        FileUtils.cd sinatra_path do
          pid = Process.spawn 'rackup', [:out, :err] => sinatra_log_file
        end

        Process.detach(pid)
        File.open(pid_filename, 'w') { |file| file.write(pid.to_s) }
      end

      log.info "Running sinatra server with pid #{File.read pid_filename}"
      log.info "Waiting for server to finish startup"

      Retriable.retriable on:            [Errno::ECONNREFUSED],
                          tries:         30,
                          base_interval: 1,
                          multiplier:    1.0,
                          rand_factor:   0.0 do
        HTTParty.get 'http://localhost:8090'
        log.info "Server started"
      end

    rescue Errno::ECONNREFUSED
      log.error "Sinatra server failed to start!!!!"
      log.debug { File.read sinatra_log_file }
    end

    def stop_app
      pid = File.read(pid_filename).to_i

      log.info "Stoping sinatra: PID #{pid}"
      Process.kill("KILL", pid)

    rescue Errno::ESRCH
      log.warn "Process with PID #{pid} not found! Skipping..."
    ensure
      log.info "Sinatra stopped, removing #{pid_filename}."
      File.delete pid_filename
    end

  end
end

Around '@sinatra_mock' do |_, block|
  Hooks::Sinatra.start_app
  block.call
  Hooks::Sinatra.stop_app
end
