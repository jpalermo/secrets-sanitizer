require 'logger'
require 'sanitizer'

module Desanitizer
  class DesanitizeExecutor
    def self.execute(manifest, sec_dir, logger = Logger.new(STDOUT))

      yaml = YAML.load_file(manifest)
      yaml_secret_file_path = File.join(
        File.expand_path(sec_dir),
        "/secrets-#{File.basename(manifest, '.yml')}.json"
      )
      if File.exist?(yaml_secret_file_path)
        secrets = JSON.parse(File.read(yaml_secret_file_path))
      else 
        puts "Secrets file not present for YAML file #{manifest} skipping it"
        return
      end
      interpolator = Desanitizer::MustacheInterpolator.new(yaml, secrets, logger)
      Sanitizer::YamlTraverser.traverse(yaml) do |k, v, h|
        interpolator.interpolate(k, v, h)
      end

      File.open(manifest, 'w') do |file|
        file.write interpolator.manifest_yaml
      end
    end
  end
end
