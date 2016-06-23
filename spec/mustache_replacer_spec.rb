require 'spec_helper'
describe Sanitizer::MustacheReplacer do
  let (:patterns) {
    'key'
  }

  let (:sanitize_hash) {
    {
      "some_key" => 'some_value'
    }
  }

  let (:spiff_yaml_hash) {
    {
      "spiff_key" => '(( spiff_value ))'
    }
  }

  let (:mustache_yaml_hash) {
    {
      "mustache_key" => "{{ mustache_value }}"
    }
  }

  it 'replace the value need to be sanitized' do
    replacer = Sanitizer::MustacheReplacer.new(patterns, sanitize_hash, {}, Logger.new(nil))
    replacer.replace('some_key', 'some_value', ['some_key'])
    expect(replacer.manifest_yaml).to eql("---\nsome_key: \"{{some_key}}\"\n")
  end

  it 'ignores values already in mustache syntax' do
    replacer = Sanitizer::MustacheReplacer.new(patterns, mustache_yaml_hash, {}, Logger.new(nil))
    replacer.replace('mustache_key', '(( mustache_value ))', ['mustache_key'])
    expect(replacer.manifest_yaml).to eql("---\nmustache_key: \"{{ mustache_value }}\"\n")
  end

  it 'ignores values already in spiff syntax' do
    replacer = Sanitizer::MustacheReplacer.new(patterns, spiff_yaml_hash, {}, Logger.new(nil))
    replacer.replace('spiff_key', '(( spiff_value ))', ['spiff_key'])
    expect(replacer.manifest_yaml).to eql("---\nspiff_key: \"(( spiff_value ))\"\n")

  end
end
