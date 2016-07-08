require 'logger'
require 'sanitizer'

module Desanitizer
  class DesanitizeExecutor
    def self.execute(manifest_path, secrets_path, logger = Logger.new(STDERR))

      manifest = YAML.load_file(manifest_path)

      # if given a secrets directory, choose appropriate secrets file
      if File.directory?(secrets_path)
        secrets_path = File.join(
          File.expand_path(secrets_path),
          "/secrets-#{File.basename(manifest_path, '.yml')}.json"
        )
      end

      if File.exist?(secrets_path)
        secrets = JSON.parse(File.read(secrets_path))
      else
        logger.warn "Secrets file not present for YAML file #{manifest_path} skipping it"
        return
      end
      interpolator = Desanitizer::MustacheInterpolator.new(manifest, secrets, logger)
      Sanitizer::YamlTraverser.traverse(manifest) do |k, v, h|
        interpolator.interpolate(k, v, h)
      end

      File.open(manifest_path, 'w') do |file|
        file.write interpolator.manifest_yaml
      end
    end
  end
end
