desc "Grade project"
task :grade do
  `bundle exec rspec --order default --format j --out test_output.json --format html --out public/test_output.html`

  payload = JSON.parse(open(Rails.root.join("test_output.json")).read)

  firstdraft_config = YAML.load_file(Rails.root.join(".firstdraft.yml"))
  submission_url = firstdraft_config["submission_url"]
  project_token = firstdraft_config["project_token"]

  access_token_filename = Rails.root.join(".firstdraft_access_token")

  if File.file?(access_token_filename)
    access_token = File.open(access_token_filename, &:readline).chomp
  else
    puts "What is your personal access token?"
    access_token = STDIN.gets.chomp
    File.open(access_token_filename, "w") { |f| f.write(access_token) }
  end

  data = {
    project_token: project_token,
    access_token: access_token,
    payload: payload
  }

  uri = URI(submission_url)
  use_ssl = uri.scheme == "https" ? true : false
  req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
  req.body = data.to_json
  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: use_ssl) do |http|
    http.request(req)
  end
end
