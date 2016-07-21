desc "Grade project"
task grade: :environment do
  puts `bundle exec rspec --order default --format documentation --format j --out test_output.json --format html --out test_output.html`
end
