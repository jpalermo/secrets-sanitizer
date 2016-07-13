require 'spec_helper'

describe Sanitizer::YamlTraverser do
  let (:hash_fixture) {
    YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../spec/fixture', 'yaml_traverser_manifest_1.yml'))
  }

  it 'traverses the yaml and run the callback for each leaf node' do
    traversed_nodes = {}
    Sanitizer::YamlTraverser.traverse(hash_fixture) do |k, v|
      traversed_nodes[k] = v
    end

    expect(traversed_nodes.keys).not_to include('test2')
    expect(traversed_nodes.keys).not_to include('foo2')
    expect(traversed_nodes.keys).to include('bar2')

    expect(traversed_nodes.keys).not_to include('test1')
    expect(traversed_nodes.keys).not_to include('bla1')
    expect(traversed_nodes.keys).to include('SECRET_KEY')
    expect(traversed_nodes.keys).to include('foo1')

  end

  it 'prints out lines that contain secrets and the key heirarchy separated by _' do
    traversed_hierarchy = {}
    Sanitizer::YamlTraverser.traverse(hash_fixture) do |k, v, h|
      traversed_hierarchy[k] = h.join('_')
    end

    expect(traversed_hierarchy.keys).to include('bar2')
    expect(traversed_hierarchy['bar2']).to eql('test2_foo2_bar2')
    expect(traversed_hierarchy.keys).to include('foo1')
    expect(traversed_hierarchy['foo1']).to eql('test1_foo1')
    expect(traversed_hierarchy.keys).to include('SECRET_KEY')
    expect(traversed_hierarchy['SECRET_KEY']).to eql('test1_bla1_0_SECRET_KEY')
    expect(traversed_hierarchy.keys).to include('in_nested1')
    expect(traversed_hierarchy['in_nested1']).to eql('test1_nested1_in_nested1')

  end

end
