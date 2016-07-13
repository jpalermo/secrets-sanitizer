require 'spec_helper'
require 'desanitizer'

describe Desanitizer::DesanitizeExecutor do
  before :each do
    @work_dir = File.dirname(__FILE__)
    @tmp_dir=`mktemp -d`.strip
    `cp -rf #{@work_dir}/fixture/* #{@tmp_dir}/`
  end

  after :each do
   `rm -rf #{@tmp_dir}`
  end

  def check_desanitize_success(file_basename, keys, expect_value)
    manifest_post_desanitize = YAML.load_file("#{@tmp_dir}/#{file_basename}.yml")
    expect(File).to exist("#{@tmp_dir}/secrets-#{file_basename}.json")
    secrets_file = File.read("#{@tmp_dir}/secrets-#{file_basename}.json")
    secrets = YAML.load(secrets_file)
    secret_node = manifest_post_desanitize
    keys.each do |key|
      secret_node = secret_node.fetch(key)
    end
    desanitized_key = keys.join('_')
    expect(secret_node).to eq(secrets[desanitized_key])

    return manifest_post_desanitize
  end


  it 'replaces mustache keys with the values from secrets file' do
    Desanitizer::DesanitizeExecutor.execute("#{@tmp_dir}/sanitized_manifest_1.yml",  "#{@tmp_dir}")
    keys=['bla','foo', 'bar_secret_key']

    manifest_post_desanitize = check_desanitize_success('sanitized_manifest_1',keys, 'bar_secret_value')

    not_secret_node = manifest_post_desanitize['bla']['foo']['bar_not_secret_key']
    expect(not_secret_node).to eq("bar_not_secret_value")
    special_char_value_node = manifest_post_desanitize['bla']['foo']['special_char_value_key']
    expect(special_char_value_node).to eq("*")
  end

  it 'replaces mustache keys with the multiline values from secrets file' do
    Desanitizer::DesanitizeExecutor.execute("#{@tmp_dir}/sanitized_manifest_multiline.yml",  "#{@tmp_dir}")
    keys=['bla','foo', 'multi_line_value_key']

    manifest_post_desanitize = check_desanitize_success('sanitized_manifest_multiline',keys, 'bar_secret_value')

    not_secret_node = manifest_post_desanitize['bla']['foo']['bar_not_secret_key']
    expect(not_secret_node).to eq("bar_not_secret_value")
    special_char_value_node = manifest_post_desanitize['bla']['foo']['special_char_value_key']
    expect(special_char_value_node).to eq("*")
  end
end
