require File.join(File.dirname(__FILE__), '..', 'lib', 'rgte')

describe RGTE::BlankMessage, '- blank message ops' do
  it '#matched? should return false' do
    RGTE::BlankMessage.matched?.should be_false
  end

  it 'should respond to any method other than matched? and return itself' do
    RGTE::BlankMessage.some_random_method.should == RGTE::BlankMessage
  end
end
