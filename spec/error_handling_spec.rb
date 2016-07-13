require 'spec_helper'


describe "error handling" do

	before :each do
		@work_dir = File.dirname(__FILE__)
		@tmp_dir=`mktemp -d`.strip
		@fake_dir=`mktemp -d`.strip
		`cp -rf #{@work_dir}/fixture/* #{@tmp_dir}/`
	end

	after :each do
		`rm -rf #{@tmp_dir}`
		`rm -rf #{@fake_dir}`
	end


	it 'Throws an error when secrets exist in a manifest, but there is no corresponding secrets file' do
		expect(system("#{@work_dir}/../bin/desanitize -s #{@fake_dir} -i #{@tmp_dir}/manifest_5.yml 2>/dev/null")).to eq(false)
	end

end