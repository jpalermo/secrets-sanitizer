# Copyright (C) 2016-Present Pivotal Software, Inc. All rights reserved.
#
# This program and the accompanying materials are made available under
# the terms of the under the Apache License, Version 2.0 (the "License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.Copyright (C) 2016-Present Pivotal Software, Inc. # All rights reserved.
#
# This program and the accompanying materials are made available under
# the terms of the under the Apache License, Version 2.0 (the "License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'


describe "error handling" do
	let(:work_dir) { File.dirname(__FILE__) }
  let(:tmp_dir) { Dir.mktmpdir }
  let(:desanitizer_executable) { "#{work_dir}/../bin/desanitize" }
  let(:fake_dir) { Dir.mktmpdir }

  before do
    FileUtils.cp_r Dir.glob("#{work_dir}/fixture/*"), tmp_dir
  end

  after do
    FileUtils.rm_r tmp_dir
    FileUtils.rm_r fake_dir
  end

	it 'Throws an error when secrets exist in a manifest, but there is no corresponding secrets file' do
		expect(system("#{desanitizer_executable} -s #{fake_dir} -i #{tmp_dir}/manifest_5.yml 2>/dev/null")).to be_falsy
	end

end