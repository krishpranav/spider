require 'spider/auth_store'
require 'spec_helper'

describe AuthStore do
    let(:root_uri) { URI('http://zerosum.org/') }
    let(:uri) { root_uri.merge('/course/auth') }

    before(:each) do
        @auth_store = AuthStore.new
        @auth_store.add(uri, 'admin', 'password')
    end

    after(:each) do
        @auth_store.clear!
    end

    it 'should retrive with credentials for the URL' do
        @auth_store[root_uri] = AuthCredential.new('user1', 'pass1')
        expect(@auth_store[root_uri].username).to eq('user1')
        expect(@auth_store[root_uri].password).to eq('pass1')
    end

    