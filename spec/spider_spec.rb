require 'spider'

require 'spec_helper'
require 'settings/proxy_examples'
require 'settings/timeouts_examples'
require 'settings/user_agent_examples'

describe Spider do
  it "should have a VERSION constant" do
    expect(subject.const_defined?('VERSION')).to eq(true)
  end

  it_should_behave_like "includes Spider::Settings::Proxy"
  it_should_behave_like "includes Spider::Settings::Timeouts"
  it_should_behave_like "includes Spider::Settings::UserAgent"
end