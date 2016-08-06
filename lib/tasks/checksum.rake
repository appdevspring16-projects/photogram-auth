require "digest"

namespace :checksum do
  desc "Produces a checksum of files that shouldn't be tampered with"
  task spec: :environment do
    md5 = Digest::MD5.new

    spec_folder = Rails.root.join("spec")
    spec_files = Dir["#{spec_folder}/**/*"].reject{|f| File.directory?(f)}
    spec_files.each { |f| md5 << File.read(f) }

    md5 << File.read(Rails.root.join("lib", "tasks", "grade.rake"))

    md5 << File.read(Rails.root.join(".firstdraft_project.yml"))

    puts md5.hexdigest
  end
end
