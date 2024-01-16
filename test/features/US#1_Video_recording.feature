@us#1 @video_recording @announce-directory @announce-stdout @announce-stderr @announce-output @announce-command @announce-changed-environment
Feature: Video Recording
  As a Web tester
  In order to have better debugging
  I want to record a video with the test run

  @test#1
  Scenario: Video settings can be read from configuration
    Given I unset the "QAT_WEB_VIDEO_MODE" environment variable
    And I have a "screens" YAML file with content:
    """
    default:
      resolution:
        width: 800
        height: 600
      video:
        provider: ffmpeg
        codec: libx264
        frame_rate: 12
    """
    And I load virtual screen definitions
    And no exception is raised
    When I request a virtual screen
    And a virtual screen is created
    Then the current screen video settings are:
      | provider | codec   | frame_rate |
      | ffmpeg   | libx264 | 12         |
    And the current screen video is not recording


  @test#2
  Scenario Outline: Video start automatically with video mode options set
    Given I set the "QAT_WEB_VIDEO_MODE" environment variable with value "<video_mode>"
    And I have a "browsers" YAML file with content:
    """
    video_browser:
      browser: firefox
      screen: video_recording
    """
    And I load drivers from the "browsers.yml" file
    And I have a "screens" YAML file with content:
    """
    video_recording:
      resolution:
        width: 800
        height: 600
      video:
        provider: ffmpeg
        codec: libx264
        frame_rate: 12
    """
    And I load virtual screen definitions
    And no exception is raised
    When I ask for a "video_browser" driver
    And no exception is raised
    Then the current screen video settings are:
      | provider | codec   | frame_rate |
      | ffmpeg   | libx264 | 12         |
    And the current screen video is recording

    Examples:
      | video_mode |
      | always     |
      | success    |
      | failure    |


  @test#3
  Scenario Outline: Video will not start with invalid options
    Given I set the "QAT_WEB_VIDEO_MODE" environment variable with value "<video_mode>"
    And I have a "browsers" YAML file with content:
    """
    video_browser:
      browser: firefox
      screen: video_recording
    """
    And I load drivers from the "browsers.yml" file
    And I have a "screens" YAML file with content:
    """
    video_recording:
      resolution:
        width: 800
        height: 600
      video:
        provider: ffmpeg
        codec: libx264
        frame_rate: 12
    """
    And I load virtual screen definitions
    And no exception is raised
    When I ask for a "video_browser" driver
    And no exception is raised
    Then the current screen video settings are:
      | provider | codec   | frame_rate |
      | ffmpeg   | libx264 | 12         |
    And the current screen video is not recording

    Examples:
      | video_mode |
      |            |
      | yes        |


  @test#4
  Scenario: Start video on demand
    Given I unset the "QAT_WEB_VIDEO_MODE" environment variable
    And I have a "browsers" YAML file with content:
    """
    video_browser:
      browser: firefox
      screen: video_recording
    """
    And I load drivers from the "browsers.yml" file
    And I have a "screens" YAML file with content:
    """
    video_recording:
      resolution:
        width: 800
        height: 600
      video:
        provider: ffmpeg
        codec: libx264
        frame_rate: 12
    """
    And I load virtual screen definitions
    And no exception is raised
    When I ask for a "video_browser" driver
    And no exception is raised
    Then the current screen video settings are:
      | provider | codec   | frame_rate |
      | ffmpeg   | libx264 | 12         |
    And the current screen video is not recording
    When I start recording a video of the current screen
    Then the current screen video is recording


  @sinatra_mock @test#5
  Scenario: Start and save video on demand
    Given I unset the "QAT_WEB_VIDEO_MODE" environment variable
    And I have a "browsers" YAML file with content:
    """
    video_browser:
      browser: firefox
      screen: video_recording
    """
    And I load drivers from the "browsers.yml" file
    And I have a "screens" YAML file with content:
    """
    video_recording:
      resolution:
        width: 800
        height: 600
      video:
        provider: ffmpeg
        codec: libx264
        frame_rate: 12
    """
    And I load virtual screen definitions
    And no exception is raised
    When I ask for a "video_browser" driver
    And no exception is raised
    And the current screen video is not recording
    When I start recording a video of the current screen
    Then the current screen video is recording
    Given I visit "http://localhost:8090/example"
    When I save the current screen video
    Then a video file is present


  @sinatra_mock @test#6
  Scenario: Start and discard video on demand
    Given I unset the "QAT_WEB_VIDEO_MODE" environment variable
    And I have a "browsers" YAML file with content:
    """
    video_browser:
      browser: firefox
      screen: video_recording
    """
    And I load drivers from the "browsers.yml" file
    And I have a "screens" YAML file with content:
    """
    video_recording:
      resolution:
        width: 800
        height: 600
      video:
        provider: ffmpeg
        codec: libx264
        frame_rate: 12
    """
    And I load virtual screen definitions
    And no exception is raised
    When I ask for a "video_browser" driver
    And no exception is raised
    And the current screen video is not recording
    When I start recording a video of the current screen
    Then the current screen video is recording
    Given I visit "http://localhost:8090/example"
    When I discard the current screen video
    Then a video file is not present


  @sinatra_mock @test#7
  Scenario: Start and save video to specific file
    Given I unset the "QAT_WEB_VIDEO_MODE" environment variable
    And I have a "browsers" YAML file with content:
    """
    video_browser:
      browser: firefox
      screen: video_recording
    """
    And I load drivers from the "browsers.yml" file
    And I have a "screens" YAML file with content:
    """
    video_recording:
      resolution:
        width: 800
        height: 600
      video:
        provider: ffmpeg
        codec: libx264
        frame_rate: 12
    """
    And I load virtual screen definitions
    And no exception is raised
    When I ask for a "video_browser" driver
    And no exception is raised
    And the current screen video is not recording
    When I start recording a video of the current screen
    Then the current screen video is recording
    Given I visit "http://localhost:8090/example"
    When I save the current screen video to file "my_video.mkv"
    Then a video file is present


  @sinatra_mock @test#8
  Scenario Outline: Embed video in HTML Report when occurs a Capybara::CapybaraError and the correct variables are set
    Given I copy the directory named "../../resources/qat_web_project" to "project"
    And I cd to "project"
    And I set the environment variables to:
      | variable           | value        |
      | CUCUMBER_FORMAT    |              |
      | CUCUMBER_OPTS      |              |
      | QAT_WEB_VIDEO_MODE | <video_mode> |
    When I run `rake test FEATURE=features/web_failure.feature`
    Then the exit status should be 1
    And the stdout should contain "<message>"
    When I cd to "public"
    Then a file matching %r<will-fail-with-capybara-error_\d+\.mkv> <mode> exist

    Examples:
      | video_mode | message                                                        | mode       |
      | always     | QAT::Web::Screen::Wrapper: Saving video capture to             | should     |
      | success    | QAT::Web::Screen::Wrapper: Stopped and discarded video capture | should not |
      | failure    | QAT::Web::Screen::Wrapper: Saving video capture to             | should     |


  @sinatra_mock @test#9
  Scenario Outline: Embed video in HTML Report when occurs a QAT::Web::Error and the correct variables are set
    Given I copy the directory named "../../resources/qat_web_project" to "project"
    And I cd to "project"
    And I set the environment variables to:
      | variable           | value        |
      | CUCUMBER_FORMAT    |              |
      | CUCUMBER_OPTS      |              |
      | QAT_WEB_VIDEO_MODE | <video_mode> |
    When I run `rake test FEATURE=features/qat_error_failure.feature`
    Then the exit status should be 1
    And the stdout should contain "<message>"
    When I cd to "public"
    Then a file matching %r<failure-with-a-qat-web-error-exception_\d+\.mkv> <mode> exist

    Examples:
      | video_mode | message                                                        | mode       |
      | always     | QAT::Web::Screen::Wrapper: Saving video capture to             | should     |
      | success    | QAT::Web::Screen::Wrapper: Stopped and discarded video capture | should not |
      | failure    | QAT::Web::Screen::Wrapper: Saving video capture to             | should     |


  @sinatra_mock @test#10
  Scenario Outline: Embed video in HTML Report when occurs a normal error and the correct variables are set
    Given I copy the directory named "../../resources/qat_web_project" to "project"
    And I cd to "project"
    And I set the environment variables to:
      | variable           | value        |
      | CUCUMBER_FORMAT    |              |
      | CUCUMBER_OPTS      |              |
      | QAT_WEB_VIDEO_MODE | <video_mode> |
    When I run `rake test FEATURE=features/normal_failure.feature`
    Then the exit status should be 1
    And the stdout should contain "<message>"
    When I cd to "public"
    Then a file matching %r<will-fail_\d+\.mkv> <mode> exist

    Examples:
      | video_mode | message                                                        | mode       |
      | always     | QAT::Web::Screen::Wrapper: Saving video capture to             | should     |
      | success    | QAT::Web::Screen::Wrapper: Stopped and discarded video capture | should not |
      | failure    | QAT::Web::Screen::Wrapper: Stopped and discarded video capture | should not |


  @sinatra_mock @test#11
  Scenario Outline: Embed video in HTML Report when no error occurs and the correct variables are set
    Given I copy the directory named "../../resources/qat_web_project" to "project"
    And I cd to "project"
    And I set the environment variables to:
      | variable           | value        |
      | CUCUMBER_FORMAT    |              |
      | CUCUMBER_OPTS      |              |
      | QAT_WEB_VIDEO_MODE | <video_mode> |
    When I run `rake test FEATURE=features/success.feature`
    Then the exit status should be 0
    And the stdout should contain "<message>"
    When I cd to "public"
    Then a file matching %r<will-succeed_\d+\.mkv> <mode> exist

    Examples:
      | video_mode | message                                                        | mode       |
      | always     | QAT::Web::Screen::Wrapper: Saving video capture to             | should     |
      | success    | QAT::Web::Screen::Wrapper: Saving video capture to             | should     |
      | failure    | QAT::Web::Screen::Wrapper: Stopped and discarded video capture | should not |


  @selenium_headless @test#12
  Scenario Outline: Video start without headless mode on
    Given I set the "QAT_WEB_VIDEO_MODE" environment variable with value "<video_mode>"
    And I set the "QAT_DISPLAY" environment variable with value "none"
    And I have a "browsers" YAML file with content:
    """
    video_browser:
      browser: firefox
      screen: video_recording
    """
    And I load drivers from the "browsers.yml" file
    And I have a "screens" YAML file with content:
    """
    video_recording:
      resolution:
        width: 800
        height: 600
      video:
        provider: ffmpeg
        codec: libx264
        frame_rate: 12
    """
    And I load virtual screen definitions
    And no exception is raised
    When I ask for a "video_browser" driver
    And no exception is raised

    Examples:
      | video_mode |
      | always     |
      | success    |
      | failure    |


  @sinatra_mock @test#13
  Scenario: Multiple tests generate multiple video files
    Given I copy the directory named "../../resources/qat_web_project" to "project"
    And I cd to "project"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    When I run `rake test FEATURE=features/multiple_tests.feature QAT_WEB_VIDEO_MODE=always`
    Then the exit status should be 0
    When I cd to "public"
    Then a file matching %r<first-scenario_\d+\.mkv> should exist
    Then a file matching %r<second-scenario_\d+\.mkv> should exist


  @sinatra_mock @test#14
  Scenario: Multiple tests with video off should not generate video files
    Given I copy the directory named "../../resources/qat_web_project" to "project"
    And I cd to "project"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    When I run `rake test FEATURE=features/multiple_tests.feature QAT_WEB_VIDEO_MODE=never`
    Then the exit status should be 0
    And I cd to "public"
    And a file matching %r<first-scenario_\d+\.mkv> should not exist
    And a file matching %r<second-scenario_\d+\.mkv> should not exist


  @sinatra_mock @bug#31 @test#15
  Scenario Outline: Video configuration missing should launch a custom exception when recording is asked
    Given I copy the directory named "../../resources/qat_web_project" to "project"
    And I cd to "project"
    And I set the environment variables to:
      | variable        | value                |
      | CUCUMBER_FORMAT |                      |
      | CUCUMBER_OPTS   |                      |
      | QAT_CONFIG_ENV  | missing_video_config |
    When I run `rake test FEATURE=features/success.feature QAT_WEB_VIDEO_MODE=<mode>`
    Then the exit status should be 2
    And the stderr should contain "Video recording configuration is missing! (QAT::Web::Screen::Wrapper::VideoRecordingConfigError)"
    And I cd to "public"
    And a file matching %r<first-scenario_\d+\.mkv> should not exist

    Examples:
      | mode    |
      | always  |
      | failure |
      | success |


  @sinatra_mock @bug#31 @test#16
  Scenario: Video configuration missing should not launch a Headless exception when recording is not asked
    Given I copy the directory named "../../resources/qat_web_project" to "project"
    And I cd to "project"
    And I set the environment variables to:
      | variable        | value                |
      | CUCUMBER_FORMAT |                      |
      | CUCUMBER_OPTS   |                      |
      | QAT_CONFIG_ENV  | missing_video_config |
    When I run `rake test FEATURE=features/success.feature QAT_WEB_VIDEO_MODE=never`
    Then the exit status should be 0
    And I cd to "public"
    And a file matching %r<first-scenario_\d+\.mkv> should not exist
