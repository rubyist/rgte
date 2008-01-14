require File.join(File.dirname(__FILE__), '..', 'lib', 'rgte')

describe RGTE, 'rgte module' do
  it '.application should create a new RGTE::Application' do
    RGTE::Application.should_receive(:new)

    RGTE.application
  end
end
