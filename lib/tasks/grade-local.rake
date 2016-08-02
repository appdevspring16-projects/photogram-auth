desc "Run tests locally"
task :glocal, [:arg1] do |t, args|
  puts "* You are running tests locally."
  puts
  puts "Notes:"
  puts "1. TO SUBMIT FOR GRADING, RUN rake grade."
  puts "2. TO SEE DETAILED RESULTS, RUN rake glocal[descriptive] or rake glocal[d]."
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
