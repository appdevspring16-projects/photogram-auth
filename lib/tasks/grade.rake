# POTENTIAL IMPROVEMENTS
# 1. Store personal token in ~/firstdraft.yml or Windows/Nitrous equivalent
# 2. Task to update tests
# 3. Associate pull request / commit to each submission
# 4. Make 'descriptive' option more efficient
# 5. Time stamp html file names or create a local index page containing prior test results?

# TESTING NEEDED
# A. SSL & 'open' & 'rspec' commands on Windows, Nitrous

desc "Grade project"
task :grade do # if needed in the future, add => :environment

  options = {}
  OptionParser.new do |opts|
    opts.on("-v", "--verbose", "Show detailed test results") do |v|
      options[:verbose] = v
    end
  end.parse!

  begin
    config_file_name_base = ".firstdraft_project.yml"
    config_file_name = Rails.root.join(config_file_name_base)
    config = YAML.load_file(config_file_name)
    project_token = config["project_token"]
    submission_url = config["submission_url"]
  rescue
    abort("ERROR: Does the file .firstdraft.yml exist?")
  end
  if !project_token
    abort("ERROR: Is project_token set in .firstdraft.yml?")
  end
  if !submission_url
    abort("ERROR: Is submission_url set in .firstdraft.yml?")
  end

  student_token_filename_base = ".firstdraft_student.yml"
  gitignore_filename = Rails.root.join(".gitignore")
  if File.readlines(gitignore_filename).grep(/^\/.firstdraft_student.yml$/).size == 0
    File.open(gitignore_filename, "a+") do |file|
      file.puts "/#{student_token_filename_base}"
    end
  end
  personal_access_token_filename = Rails.root.join(student_token_filename_base)
  if File.file?(personal_access_token_filename)
    student_config = YAML.load_file(personal_access_token_filename)
    personal_access_token = student_config["personal_access_token"]
  else
    student_config = {}
    personal_access_token = nil
  end
  if !personal_access_token
    puts "Enter your personal access token"
    new_personal_access_token = ""
    while new_personal_access_token == "" do
      print "> "
      new_personal_access_token = $stdin.gets.chomp.strip
      if new_personal_access_token != ""
        personal_access_token = new_personal_access_token
        student_config["personal_access_token"] = personal_access_token
        File.write(personal_access_token_filename, YAML.dump(student_config))
      end
    end
  end

  puts "* You are running tests and submitting the results."
  puts "* WITH DETAILED RESULTS" if options[:verbose]
  puts "* IGNORING ARGUMENTS #{ARGV[1..-1]}" if ARGV.length > 1

  puts
  puts "A. READ PERSONAL/PROJECT SETTINGS".header_format
  puts "- Personal access token: #{personal_access_token} [#{student_token_filename_base}]"
  puts "- Project token: #{project_token} [#{config_file_name_base}]"
  puts "- Submission URL: #{submission_url} [#{config_file_name_base}]"

  puts
  puts "B. RUN TESTS".header_format
  rspec_output_string_json = `bundle exec rspec --order default --format json`
  rspec_output_json = JSON.parse(rspec_output_string_json)
  puts "- #{rspec_output_json["summary_line"]}".result_format
  puts "- For detailed results: run 'rake grade --verbose' or 'rake grade -v' or 'rspec'" if !options[:verbose]

  puts
  puts "C. SUBMIT RESULTS".header_format
  data = {
    project_token: project_token,
    access_token: personal_access_token,
    test_output: rspec_output_json
  }
  uri = URI(submission_url)
  use_ssl = uri.scheme == "https" ? true : false
  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = data.to_json
  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: use_ssl) do |http|
    http.request(req)
  end
  if res.kind_of? Net::HTTPCreated
    results_url = submission_url + "/" + JSON.parse(res.body)["id"]
    puts "- Done! Results URL: ".result_format + "#{results_url}".link_format.result_format
    puts
    if options[:verbose]
      puts "D. DETAILED TEST RESULTS".header_format
      rspec_output_string_doc = `bundle exec rspec --order default --format documentation --color --tty` # "--require spec_helper"?
      puts rspec_output_string_doc
    else
      `open #{results_url}`
    end
  else
    puts "- ERROR: #{res.inspect}, #{res.body}"
    puts
  end

end

# Taken from: http://stackoverflow.com/questions/1489183/colorized-ruby-output
class String
  def black;          "\e[30m#{self}\e[0m"      end
  def red;            "\e[31m#{self}\e[0m"      end
  def green;          "\e[32m#{self}\e[0m"      end
  def brown;          "\e[33m#{self}\e[0m"      end
  def blue;           "\e[34m#{self}\e[0m"      end
  def magenta;        "\e[35m#{self}\e[0m"      end
  def cyan;           "\e[36m#{self}\e[0m"      end
  def gray;           "\e[37m#{self}\e[0m"      end

  def bg_black;       "\e[40m#{self}\e[0m"      end
  def bg_red;         "\e[41m#{self}\e[0m"      end
  def bg_green;       "\e[42m#{self}\e[0m"      end
  def bg_brown;       "\e[43m#{self}\e[0m"      end
  def bg_blue;        "\e[44m#{self}\e[0m"      end
  def bg_magenta;     "\e[45m#{self}\e[0m"      end
  def bg_cyan;        "\e[46m#{self}\e[0m"      end
  def bg_gray;        "\e[47m#{self}\e[0m"      end

  def bold;           "\e[1m#{self}\e[22m"      end
  def italic;         "\e[3m#{self}\e[23m"      end
  def underline;      "\e[4m#{self}\e[24m"      end
  def blink;          "\e[5m#{self}\e[25m"      end
  def reverse_color;  "\e[7m#{self}\e[27m"      end

  def no_colors;      self.gsub /\e\[\d+m/, ""  end

  # Specific formatting for 'rake grade'
  def header_format;  self.underline            end
  def result_format; self.bold                  end
  def link_format;    self                      end
end
