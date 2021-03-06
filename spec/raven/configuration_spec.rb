require File::expand_path('../../spec_helper', __FILE__)
require 'raven'

describe Raven::Configuration do
  before do
    # Make sure we reset the env in case something leaks in
    ENV.delete('SENTRY_DSN')
    ENV.delete('RAILS_ENV')
    ENV.delete('RACK_ENV')
  end

  shared_examples 'a complete configuration' do


    it 'should have a server' do
      subject[:server].should == 'http://sentry.localdomain/sentry'
    end

    it 'should have a scheme' do
      subject[:scheme].should == 'http'
    end

    it 'should have a public key' do
      subject[:public_key].should == '12345'
    end

    it 'should have a secret key' do
      subject[:secret_key].should == '67890'
    end

    it 'should have a host' do
      subject[:host].should == 'sentry.localdomain'
    end

    it 'should have a port' do
      subject[:port].should == 80
    end

    it 'should have a path' do
      subject[:path].should == '/sentry'
    end

    it 'should have a project ID' do
      subject[:project_id].should == '42'
    end
  end

  context 'being initialized with a server string' do
    before do
      subject.server = 'http://12345:67890@sentry.localdomain/sentry/42'
    end
    it_should_behave_like 'a complete configuration'
  end

  context 'being initialized with a DSN string' do
    before do
      subject.dsn = 'http://12345:67890@sentry.localdomain/sentry/42'
    end
    it_should_behave_like 'a complete configuration'
  end

  context 'being initialized with options' do
    before do
      subject.server = 'http://sentry.localdomain/sentry'
      subject.public_key = '12345'
      subject.secret_key = '67890'
      subject.project_id = '42'
    end
    it_should_behave_like 'a complete configuration'
  end

  context 'being initialized with an environment variable' do
    subject do
      ENV['SENTRY_DSN'] = 'http://12345:67890@sentry.localdomain/sentry/42'
      Raven::Configuration.new
    end
    it_should_behave_like 'a complete configuration'
  end

  context 'being initialized in a non-test environment' do
    it 'should send events' do
      subject.send_in_current_environment?.should be_true
    end
  end

  context 'being initialized in a test environment' do
    before(:each) do
      subject.current_environment = 'test'
    end

    it 'should not send events' do
      subject.send_in_current_environment?.should be_false
    end

    it 'should send events if test is whitelisted' do
      subject.environments = %w[ test ]
      subject.send_in_current_environment?.should be_true
    end
  end
end
