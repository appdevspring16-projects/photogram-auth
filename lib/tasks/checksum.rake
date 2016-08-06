require "digest"

namespace :checksum do
  desc "Produces a checksum of the spec/ folder"
  task spec: :environment do
    md5 = Digest::MD5.new

    # Add spec/ folder
    dir = Rails.root.join("spec")
    files = Dir["#{dir}/**/*"].reject{|f| File.directory?(f)}
    content = files.each { |f| md5 << File.read(f) }

    # Add grade task
    md5 << File.read(Rails.root.join("lib", "tasks", "grade.rake"))

    puts md5.hexdigest
  end
end
