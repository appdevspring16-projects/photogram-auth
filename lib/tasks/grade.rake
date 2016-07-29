# desc "Grade project"
# task grade: :environment do
#   puts `bundle exec rspec --order default --format documentation --format j --out test_output.json --format html --out test_output.html`
# end

require 'json'

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

    # FUTURE ITERATION: store personal access token in ~/firstdraft.yml or a Windows equivalent so that students don't have to re-enter it for each project

    begin
      require 'yaml'
      config_file_name = Rails.root.join(".firstdraft.yml")
      config = YAML.load_file(config_file_name)
      project_token = config["project_token"]
      personal_access_token = config["personal_access_token"]
    rescue
      abort("ERROR: Does the file .firstdraft.yml exist?")
    end

    if !project_token
      abort("ERROR: Is project_token set in .firstdraft.yml?")
    end

    if !personal_access_token
      puts "Enter your personal access token"
      new_personal_access_token = ""
      while new_personal_access_token == "" do
        print "> "
        new_personal_access_token = $stdin.gets.chomp.strip
        if new_personal_access_token != ""
          personal_access_token = new_personal_access_token
          config = YAML.load_file(config_file_name)
          config["personal_access_token"] = personal_access_token
          File.write(config_file_name, YAML.dump(config))
        end
      end
    end

    puts "* You are running tests and submitting the results."
    puts
    puts "A. PROJECT/PERSONAL TOKENS"
    puts "- Project token: #{project_token}"
    puts "- Personal access token: #{personal_access_token}"
    puts "- Note: You can change either value in #{config_file_name}"

    puts
    puts "B. TEST RESULTS"
    rspec_output_string_json = `bundle exec rspec --order default --format json`
    rspec_output_json = JSON.parse(rspec_output_string_json)
    puts "- #{rspec_output_json["summary_line"]}"

    puts
    puts "C. SUBMITTING RESULTS"

    uri = URI('http://localhost:3000/submit')
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = rspec_output_json.to_json
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    puts "- submitted: #{JSON.parse(res.body)["summary_line"]}"

    puts
    puts "D. DETAILED TEST RESULTS"
    # FUTURE ITERATION: Inefficient. Can combine rspec calls later.
    rspec_output_string_doc = `bundle exec rspec --order default --format documentation --color --tty` # "--require spec_helper"?
    puts rspec_output_string_doc

  end

end
