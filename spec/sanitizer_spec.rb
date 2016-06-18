require 'spec_helper'

describe Sanitizer do
  it 'has a version number' do
    expect(Sanitizer::VERSION).not_to be nil
  end

  it 'prints out lines that contain secrets' do
    work_dir = File.dirname(__FILE__)
    output = `#{work_dir}/../bin/sanitize -m #{work_dir}/fixture/manifest_1.yml`
    expect(output).to include('bar_secret_key: {{bla_foo_bar_secret_key}}')
    expect(output).to include('bla_foo_bar_secret_key: bar_secret_value')
    expect(output).to_not include('bar_not_secret')
  end
end
