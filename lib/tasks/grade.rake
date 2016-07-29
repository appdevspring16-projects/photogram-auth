# desc "Grade project"
# task grade: :environment do
#   puts `bundle exec rspec --order default --format documentation --format j --out test_output.json --format html --out test_output.html`
# end

require 'json'
require 'yaml'

namespace :grade do

  desc "Run tests locally"
  task :local, [:arg1] do |t, args|
    puts "* You are running tests locally."
    puts
    puts "Notes:"
    # puts "1. TO UPDATE TESTS, RUN rake grade:update_tests."
    puts "1. TO SUBMIT FOR GRADING, RUN rake grade:submit."
    puts "2. TO SEE DETAILED RESULTS, RUN rake grade:local[descriptive] or rake grade:local[d]."
    puts
    puts "Test results:"

    if args[:arg1] == "descriptive" || args[:arg1] == "d"
      # sh "rspec"
      rspec_output_string_doc = `bundle exec rspec --order default --format documentation --color --tty --format html --out test_output.html` # "--require spec_helper"?
      puts rspec_output_string_doc
    else
      rspec_output_string_json = `bundle exec rspec --order default --format json`
      rspec_output_json = JSON.parse(rspec_output_string_json)
      puts "WARNING: UNKNOWN ARGUMENT \"#{args[:arg1]}\"" if args[:arg1]
      puts rspec_output_json["summary_line"]
      # puts JSON.pretty_generate(rspec_output_json)
    end
  end

  desc "Submit test results"
  task :submit do

    begin
      config_file_name = Rails.root.join(".firstdraft_project.yml")
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

    # FUTURE ITERATION: store personal access token in ~/firstdraft.yml or a Windows equivalent so that students don't have to re-enter it for each project
    student_token_filename_base = ".firstdraft_student.yml"
    personal_access_token_filename = Rails.root.join(student_token_filename_base)
    if File.file?(personal_access_token_filename)
      student_config = YAML.load_file(personal_access_token_filename)
      personal_access_token = student_config["personal_access_token"]
    else
      student_config = {}
      personal_access_token = nil
      gitignore_filename = Rails.root.join(".gitignore")
      File.open(gitignore_filename, "a+") do |file|
        file.puts "/#{student_token_filename_base}"
      end
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
    puts
    puts "A. PERSONAL/PROJECT TOKENS"
    puts "- Personal access token: #{personal_access_token}"
    puts "- Project token: #{project_token}"
    puts "- Note: You can change the personal access token in #{personal_access_token_filename}"
    puts "- Note: You shouldn't need to, but you can change the project token in #{config_file_name}"

    puts
    puts "B. TEST RESULTS"
    rspec_output_string_json = `bundle exec rspec --order default --format json`
    rspec_output_json = JSON.parse(rspec_output_string_json)
    puts "- #{rspec_output_json["summary_line"]}"

    puts
    puts "C. SUBMITTING RESULTS"
    data = {
      project_token: project_token,
      access_token: personal_access_token,
      payload: rspec_output_json
    }
    uri = URI(submission_url)
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = data.to_json
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    puts "- submitted: personal_access_token = #{JSON.parse(res.body)["access_token"]}"
    puts "- submitted: project_token = #{JSON.parse(res.body)["project_token"]}"
    puts "- submitted: #{JSON.parse(res.body)["payload"]["summary_line"]}"

    puts
    puts "D. DETAILED TEST RESULTS"
    # FUTURE ITERATION: Inefficient. Can combine rspec calls later.
    rspec_output_string_doc = `bundle exec rspec --order default --format documentation --color --tty` # "--require spec_helper"?
    puts rspec_output_string_doc

  end

end
