require 'logger'

module Sanitizer
  class SanitizeExecutor
    def self.execute(manifest_path, pattern_file, secrets_path, logger = Logger.new(STDERR))

      manifest = YAML.load_file(manifest_path)

      # if given a secrets directory, choose appropriate secrets file
      if File.directory?(secrets_path)
        secrets_file_path = File.join(
          File.expand_path(secrets_path),
          "/secrets-#{File.basename(manifest_path, '.yml')}.json"
        )
      else
        secrets_file_path = secrets_path
      end

      existing_secrets = {}
      if File.exist?(secrets_file_path)
        existing_secrets = JSON.parse(File.read(secrets_file_path))
      end

      config_pattern = File.read(pattern_file)

      replacer = Sanitizer::MustacheReplacer.new(config_pattern, manifest, existing_secrets, logger)

      Sanitizer::YamlTraverser.traverse(manifest) do |k, v, h|
        replacer.replace(k, v, h)
      end

      File.open(manifest_path, 'w') do |file|
        file.write replacer.manifest_yaml
      end

      unless replacer.secrets_json.nil?
        File.open(secrets_file_path, 'w') do |file|
          file.write replacer.secrets_json
        end
      end
    end
  end
end

