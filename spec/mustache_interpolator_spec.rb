require 'spec_helper'
describe Desanitizer::MustacheInterpolator do

  let (:mustache_yaml_hash) {
    {
      "some_key" => '{{ some_mustache_key }}'
    }
  }

  let (:spiff_yaml_hash) {
    {
      "spiff_key" => '(( spiff_value ))'
    }
  }

  let (:boolean_hash) {
    {
      "boolean_key" => '{{some_boolean_key}}'
    }
  }

  let (:secrets_hash) {
    {
      "some_mustache_key" => "some_value",
			"some_boolean_key" => false
    }
  }

  it 'interpolates the mustache syntax with actual values' do
    interpolator = Desanitizer::MustacheInterpolator.new(mustache_yaml_hash, secrets_hash, Logger.new(nil))
    interpolator.interpolate('some_key', '{{ some_mustache_key }}', ['some_key'])
    expect(interpolator.manifest_yaml).to eql("---\nsome_key: some_value\n")
  end

  it 'ignores values in spiff syntax' do
    interpolator = Desanitizer::MustacheInterpolator.new(spiff_yaml_hash, secrets_hash, Logger.new(nil))
    interpolator.interpolate('spiff_key', '(( spiff_value ))', ['spiff_key'])
    expect(interpolator.manifest_yaml).to eql("---\nspiff_key: \"(( spiff_value ))\"\n")
  end

  it 'handle boolean values' do
    interpolator = Desanitizer::MustacheInterpolator.new(boolean_hash, secrets_hash, Logger.new(nil))
    interpolator.interpolate('boolean_key', '{{some_boolean_key}}', ['boolean_key'])
    expect(interpolator.manifest_yaml).to eql("---\nboolean_key: false\n")
  end
end
