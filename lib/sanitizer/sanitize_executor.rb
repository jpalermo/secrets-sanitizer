require 'logger'

module Sanitizer
  class SanitizeExecutor
    def self.execute(manifest, pattern_file, sec_dir, logger = Logger.new(STDERR))

      yaml = YAML.load_file(manifest)
      json_secret_file_path = File.join(
        File.expand_path(sec_dir),
        "/secrets-#{File.basename(manifest, '.yml')}.json"
      )
      existing_secrets = {}
      if File.exist?(json_secret_file_path)
        existing_secrets = JSON.parse(File.read(json_secret_file_path))
      end
      config_pattern = File.read(pattern_file)

      replacer = Sanitizer::MustacheReplacer.new(config_pattern, yaml, existing_secrets, logger)

      Sanitizer::YamlTraverser.traverse(yaml) do |k, v, h|
        replacer.replace(k, v, h)
      end

      File.open(manifest, 'w') do |file|
        file.write replacer.manifest_yaml
      end

      unless replacer.secrets_json.nil?
        File.open(json_secret_file_path, 'w') do |file|
          file.write replacer.secrets_json
        end
      end
    end
  end
end

