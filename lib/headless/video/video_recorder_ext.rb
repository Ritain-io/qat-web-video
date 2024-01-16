# Monkey Patch Description:
#
# This monkey patch modifies the behavior of the `stop_and_save` within the `VideoRecorder`
# from the 'headless' gem. It is applied to address a specific issue or add custom
# functionality required for our project.
#
# Original method behavior:
# - File.exists? was removed in Ruby 3.2.0 (deprecated in 2.2)
# https://bugs.ruby-lang.org/issues/17391
# https://github.com/ruby/ruby/commit/bf97415c02b11a8949f715431aca9eeb6311add2
# Sadly the gem Headless is currently outdated thus this patch
#
# Changes Made:
# - Change `File.exists?` to `File.exist?`
#
# Note: This patch should be reviewed and updated as needed with future gem updates.
#
# Author: Bruno Penedo

require 'headless'

class Headless
  class VideoRecorder
    def stop_and_save(path)
      CliUtil.kill_process(@pid_file_path, :wait => true)
      if File.exist? @tmp_file_path
        begin
          FileUtils.mv(@tmp_file_path, path)
        rescue Errno::EINVAL
          nil
        end
      end
    end
  end
end
