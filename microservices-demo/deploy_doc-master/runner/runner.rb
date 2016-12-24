require 'json'
require 'open3'
$stdout.sync = true
$stderr.sync = true

class StepFailed < RuntimeError
  def initialize(phase, location)
    super("on lines #{location} in phase #{phase}")
  end
end

all_steps = JSON.load(File.read(ARGV.first))

def report_error(e)
  puts
  puts red { "#{e.class}: #{e}" }
  puts
  $all_passed = false
end

def run_phase(all_steps, name)
  puts(bold { underline { name}})
  steps = all_steps[name]
  if steps.empty?
    puts yellow { '  - No steps in this phase'}
  else
    steps.each do |step|
      puts blue { "  + Running step #{step["line_span"]}" }

      shellcode = "set +e\n" + step["shell"]
      begin
        Open3.popen2e(shellcode) do |stdin, stdout_stderr, wait_exit_code_of_child|
          $current_io_thread = wait_exit_code_of_child
          buffer = ""

          loop do
            begin
              read = stdout_stderr.read_nonblock(1024)
            rescue IO::EAGAINWaitReadable
              IO.select([stdout_stderr])
              retry
            rescue EOFError
              if buffer.length > 0
                lines = buffer.split("\n")
                lines.each do |line|
                  print_line(line)
                end
              end
              break
            end
            buffer += read
            line, new_buffer = buffer.split("\n", 2)
            if new_buffer != nil
              print_line(line)
              buffer = new_buffer
            end
          end

          if wait_exit_code_of_child.value != 0
            raise StepFailed.new(name, step["line_span"])
          end
        end
      ensure
        $current_io_thread = nil
      end
    end
  end
ensure
  puts
end

def print_line(line)
  puts((blue { "  | "}) + line)
end

def bold
  "\033[1m" + yield + "\033[0m"
end

def underline
  "\033[4m" + yield + "\033[0m"
end

def red
  "\033[31m" + yield + "\033[0m"
end

def yellow
  "\033[33m" + yield + "\033[0m"
end

def blue
  "\033[34m" + yield + "\033[0m"
end

begin
  begin
    run_phase(all_steps, "pre-install")
  rescue StepFailed => e
    report_error(e)
    exit 1
  end

  all_passed = true
  begin
    begin
      run_phase(all_steps, "create-infrastructure")
      run_phase(all_steps, "run-tests")
    rescue Exception => e
      report_error(e)
      puts "Skipping next steps, jump to cleaning up\n"
      all_passed = false
    end

    begin
      run_phase(all_steps, "destroy-infrastructure")
    rescue Exception => e
      report_error(e)
      puts "    " + bold { red { "#" * 46 } }
      puts "    " + bold { red { "#   " } } + bold { red { underline { "Failed to clean up the infrastructure!" } } } + bold { red { "   #"}}
      puts "    " + bold { red { "#" * 46 } }
      exit 2
    end
  end

  if all_passed
    exit 0
  else
    exit 1
  end
rescue Interrupt
  puts bold { red { "Interrupted!" } }
  if $current_io_thread
    puts "Killing child process #{$current_io_thread.pid}"
    begin
     Process.kill("KILL",$current_io_thread.pid)
    rescue
      # Don't care if the PID doesn't exist anymore.
      # All bets are off in any case.
    end
  end
  exit 3
end
