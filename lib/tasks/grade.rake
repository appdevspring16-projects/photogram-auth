# POTENTIAL IMPROVEMENTS
# 1. Store personal token in ~/firstdraft.yml or Windows/Nitrous equivalent
# 2. Task to update tests
# 3. Associate pull request / commit to each submission
# 4. Make 'descriptive' option more efficient
# 5. Time stamp html file names or create a local index page containing prior test results?

# TESTING NEEDED
# A. SSL & 'open' & 'rspec' commands on Windows, Nitrous

desc "Grade project"
task :grade, [:arg1] do |t, args| # if needed in the future, add => :environment
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
  if File.readlines(".gitignore").grep(/^\/.firstdraft_student.yml$/).size == 0
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
  if args[:arg1] == "descriptive" || args[:arg1] == "d"
    puts "* WITH DETAILED RESULTS."
  else
    puts "WARNING: UNKNOWN ARGUMENT \"#{args[:arg1]}\"" if args[:arg1]
  end

  puts
  puts "A. READ PERSONAL/PROJECT SETTINGS"
  puts "- Personal access token: #{personal_access_token} [#{student_token_filename_base}]"
  puts "- Project token: #{project_token} [#{config_file_name_base}]"
  puts "- Submission URL: #{submission_url} [#{config_file_name_base}]"

  puts
  puts "B. RUNNING TESTS"
  results_html_file_name_base = "public/test_output.html"
  results_html_file_name = Rails.root.join(results_html_file_name_base)
  rspec_output_string_json = `bundle exec rspec --order default --format json --format html --out #{results_html_file_name}`
  rspec_output_json = JSON.parse(rspec_output_string_json)
  puts "- #{rspec_output_json["summary_line"]}"
  puts "- detailed results in browser: run 'open #{results_html_file_name}' or, if your server is running, go to http://localhost:3000/#{results_html_file_name_base.split('public/').last}"
  puts "- detailed results inline: run 'rspec' or 'rake grade[descriptive]' or 'rake grade[d]'"

  puts
  puts "C. SUBMITTING RESULTS"
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
  if res.body == "true"
    puts "- submitted successfully to #{submission_url}"
    puts "- submission URL: TBD"
  else
    puts "- ERROR: NOT SUBMITTED. Full info: #{res.inspect}, #{res.body}"
  end
  puts

  if args[:arg1] == "descriptive" || args[:arg1] == "d"
    puts "D. DETAILED TEST RESULTS"
    rspec_output_string_doc = `bundle exec rspec --order default --format documentation --color --tty` # "--require spec_helper"?
    puts rspec_output_string_doc
  else
    `open #{results_html_file_name}`
  end
end
