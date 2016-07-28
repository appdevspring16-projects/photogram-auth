desc "Grade project"
task :grade do
  `bundle exec rspec --order default --format j --out test_output.json --format html --out public/test_output.html`

  payload = JSON.parse(open(Rails.root.join("test_output.json")).read)

  firstdraft_config = YAML.load_file(Rails.root.join(".firstdraft.yml"))
  submission_url = firstdraft_config["submission_url"]
  project_token = firstdraft_config["project_token"]

  data = {
    project_token: project_token,
    access_token: "BVzWJf5dfWMLXNnUDfrS6B46",
    payload: payload
  }

  uri = URI(submission_url)
  req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
  req.body = data.to_json
  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
end
