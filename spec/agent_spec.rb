require 'spec_helper'
require 'example_app'
require 'settings/user_agent_examples'

require 'spider/agent'

describe Agent do
    it_should_behave_like "includes Spider::Settings::UserAgent"

    describe "#initialize" do
        it "should not be running" do
          expect(subject).to_not be_running
        end
    
        it "should default :delay to 0" do
          expect(subject.delay).to be 0
        end
    
        it "should initialize #history" do
          expect(subject.history).to be_empty
        end
    
        it "should initialize #failures" do
          expect(subject.failures).to be_empty
        end
    
        it "should initialize #queue" do
          expect(subject.queue).to be_empty
        end