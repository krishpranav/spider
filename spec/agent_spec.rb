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

        it "should initialize the #session_cache" do
            expect(subject.session).to be_kind_of(SessionCache)
        end

        it "should initialize the #cookie_jar" do
            expect(subject.cookies).to be_kind_of(CookieJar)
        end
        
        it "should initialize the #auth_store" do
            expect(subject.authorized).to be_kind_of(AuthStore)
        end

        describe "#history=" do
            let(:previous_history) { Set[URI('http://example.com')] }
        
            before { subject.history = previous_history }
        
            it "should be able to restore the history" do
              expect(subject.history).to eq(previous_history)
            end
        
            context "when given an Array of URIs" do
              let(:previous_history)  { [URI('http://example.com')] }
              let(:converted_history) { Set.new(previous_history) }
        
              it "should convert the Array to a Set" do
                expect(subject.history).to eq(converted_history)
              end
            end
        
            context "when given an Set of Strings" do
              let(:previous_history)  { Set['http://example.com'] }
              let(:converted_history) do
                previous_history.map { |url| URI(url) }.to_set
              end
        
              it "should convert the Strings to URIs" do
                expect(subject.history).to eq(converted_history)
              end
            end
          end
        
          describe "#failures=" do
            let(:previous_failures) { Set[URI('http://example.com')] }
        
            before { subject.failures = previous_failures }
        
            it "should be able to restore the failures" do
              expect(subject.failures).to eq(previous_failures)
            end
        
            context "when given an Array of URIs" do
              let(:previous_failures)  { [URI('http://example.com')] }
              let(:converted_failures) { Set.new(previous_failures) }
        
              it "should convert the Array to a Set" do
                expect(subject.failures).to eq(converted_failures)
              end
            end
