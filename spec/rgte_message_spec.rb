require File.join(File.dirname(__FILE__), '..', 'lib', 'rgte')

describe RGTE::Message, '- a new message' do
  before(:each) do
    @message = RGTE::Message.new('body')
  end
  
  it 'should not be marked saved' do
    @message.saved?.should be_false
  end

  it '#matched? should return true' do
    @message.matched?.should be_true
  end

  it '#halt should raise RGTE::HaltFilter' do
    lambda { @message.halt }.should raise_error(RGTE::HaltFilter)
  end

  it '#read should mark the message read' do
    @message.read?.should be_false
    @message.read
    @message.read?.should be_true
  end

  it '#save markes the mailbox as saved' do
    @message.saved?.should be_false
    @message.save('inbox')
    @message.saved?.should be_true
  end

  it 'should not write the message to disk if it has not been saved' do
    FileUtils.should_not_receive(:mkdir_p)
    File.should_not_receive(:open)

    @message.write
  end

  it 'should not be marked saved if save is passed nil' do
    @message.save(nil)
    @message.saved?.should be_false
  end
  
end

describe RGTE::Message, '- when writing the message to disk' do
  before(:each) do
    RGTE::Config[:maildir_root] = '/foo'
      
    @message = RGTE::Message.new('body')

    @file = mock('file')
    @file.stub!(:write)

    FileUtils.stub!(:mkdir_p)
    File.stub!(:open)
  end

  def save_message(mailbox)
    @message.save(mailbox)
  end
  
  it 'should create the mailbox directory' do
    save_message('inbox')
    FileUtils.should_receive(:mkdir_p).with('/foo/cur')

    @message.write
  end

  it 'should open the file on disk' do
    save_message('inbox')
    File.should_receive(:open)

    @message.write
  end

  it 'should write to the file on disk' do
    save_message('inbox')
    @file.should_receive(:write).with('body')
    File.stub!(:open).and_yield(@file)

    @message.write
  end

  it 'should create the mailbox directory for non inbox' do
    save_message('lists/dtrace')
    FileUtils.should_receive(:mkdir_p).with('/foo/.lists.dtrace/cur')

    @message.write
  end
end
