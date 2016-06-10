require 'yaml'

# Make sure we're running from the directory the Rakefile lives in since
# many things (ie: docker build, config reading) use relative paths.
Dir.chdir(File.dirname(__FILE__))

BUNDLE_CONFIG = YAML.load(File.read("config.yaml"))
BUNDLE_IMAGE = "#{BUNDLE_CONFIG['docker']['image']}:#{BUNDLE_CONFIG['docker']['tag']}"

task :image do |t|
  args = [ "build", "-t", BUNDLE_IMAGE, "." ]
  sh "docker", *args
end

task :push => [:image] do |t|
  args = [ "push", BUNDLE_IMAGE ]
  sh "docker", *args
end
