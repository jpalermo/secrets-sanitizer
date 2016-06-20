require 'spec_helper'
require 'yaml'
require 'json'

describe Sanitizer do
  before :each do
    @work_dir = File.dirname(__FILE__)
    @tmp_dir=`mktemp -d`.strip
    `cp -rf #{@work_dir}/fixture/* #{@tmp_dir}/`

    manifest = YAML.load_file("#{@tmp_dir}/manifest_1.yml")
    secret_node = manifest['bla']['foo']['bar_secret_key']
    expect(secret_node).to eq("bar_secret_value")
    not_secret_node = manifest['bla']['foo']['bar_not_secret_key']
    expect(not_secret_node).to eq("bar_not_secret_value")
    expect(File).not_to exist("#{@tmp_dir}/secrets-manifest_1.json")

  end

  after :each do
   `rm -rf #{@tmp_dir}`
  end

  it 'has a version number' do
    expect(Sanitizer::VERSION).not_to be nil
  end

  it 'extracts secrets to another file and replaces with mustache style syntax' do
    puts `#{@work_dir}/../bin/sanitize -m #{@tmp_dir}/manifest_1.yml -s #{@tmp_dir} -p #{@tmp_dir}/config_1`

    manifest_post_sanitize = YAML.load_file("#{@tmp_dir}/manifest_1.yml")
    secret_node = manifest_post_sanitize['bla']['foo']['bar_secret_key']
    expect(secret_node).to eq("'{{bla_foo_bar_secret_key}}'")
    not_secret_node = manifest_post_sanitize['bla']['foo']['bar_not_secret_key']
    expect(not_secret_node).to eq("bar_not_secret_value")
    expect(File).to exist("#{@tmp_dir}/secrets-manifest_1.json")
    secretsFile = File.read("#{@tmp_dir}/secrets-manifest_1.json")
    secrets = JSON.parse(secretsFile)
    expect(secrets['bla_foo_bar_secret_key']).to eq("bar_secret_value")
    expect(secrets.length).to eq(1)
  end

  it 'works with multiple match' do
    puts `#{@work_dir}/../bin/sanitize -m #{@tmp_dir}/manifest_1.yml -s #{@tmp_dir} -p #{@tmp_dir}/config_2`

    manifest_post_sanitize = YAML.load_file("#{@tmp_dir}/manifest_1.yml")
    secret_node = manifest_post_sanitize['bla']['foo']['bar_secret_key']
    expect(secret_node).to eq("'{{bla_foo_bar_secret_key}}'")
    another_secret_node = manifest_post_sanitize['bla']['foo']['bar_not_secret_key']
    expect(another_secret_node).to eq("'{{bla_foo_bar_not_secret_key}}'")
    expect(File).to exist("#{@tmp_dir}/secrets-manifest_1.json")
    secretsFile = File.read("#{@tmp_dir}/secrets-manifest_1.json")
    secrets = JSON.parse(secretsFile)
    expect(secrets['bla_foo_bar_secret_key']).to eq("bar_secret_value")
    expect(secrets['bla_foo_bar_not_secret_key']).to eq("bar_not_secret_value")
    expect(secrets.length).to eq(2)
  end
end
