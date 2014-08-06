describe 'Firebase Dispatch::Queue' do
  before do
    @queue = Dispatch::Queue.new('com.motion-firebase.specs')
    Firebase.dispatch_queue = @queue
    @firebase = Firebase.alloc.initWithUrl(MOTION_FIREBASE_SPEC).childByAppendingPath('specs')
  end

  after do
    Firebase.dispatch_queue = Dispatch::Queue.main
    @queue = nil
  end

  it 'should work fine' do
    @firebase.setValue('specs')
    wait 0.1 do
      @firebase.removeValue
      wait 0.1 do
        observer = @firebase.observeEventType(FEventTypeValue, withBlock: lambda do |snapshot|
          Dispatch::Queue.current.to_s.should == @queue.to_s
        end)
        wait 0.1 do
          @firebase.removeObserverWithHandle(observer)
        end
      end
    end
  end

end
