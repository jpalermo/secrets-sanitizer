module Sanitizer
  class SanitizeExecutor
    def self.execute(manifest, pattern_file, sec_dir)

      yaml = YAML.load_file(manifest)

      config_pattern = File.read(pattern_file)
      replacer = Sanitizer::MustacheReplacer.new(config_pattern, yaml)

      json_secret_file = File.join(
        File.expand_path(sec_dir),
        "/secrets-#{File.basename(manifest, '.yml')}.json"
      )

      Sanitizer::YamlTraverser.traverse(yaml) do |k, v, h|
        replacer.replace(k, v, h)
      end

      File.open(manifest, 'w') do |file|
        file.write replacer.manifest_yaml
      end

      File.open(json_secret_file, 'w') do |file|
        file.write replacer.secrets_json
      end
    end
  end
end

