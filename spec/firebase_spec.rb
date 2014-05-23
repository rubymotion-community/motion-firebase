describe 'Firebase' do

  it 'can create a Firebase instance' do
    firebase = Firebase.alloc.initWithUrl(MOTION_FIREBASE_SPEC)
    firebase.should.is_a Firebase
  end

  describe 'Firebase instance' do

    before do
      @firebase = Firebase.alloc.initWithUrl(MOTION_FIREBASE_SPEC).childByAppendingPath('specs')
    end

    it 'should clear! values' do
      @firebase.clear!
      wait 0.1 do
        @firebase.on(:value) do |snapshot|
          @value = snapshot.value
        end
        wait 0.1 do
          @value.should == nil
        end
      end
    end

    it 'should access a child node with []' do
      child = @firebase['child']
      child.should.is_a Firebase
      child.name.should == 'child'
    end

    it 'should append child names with multiple arguments to []' do
      child = @firebase['child', '1']
      child.should.is_a Firebase
      child.name.should == '1'
      child.parent.name.should == 'child'
    end

    describe 'should assign values using []=' do
      before do
        @value = nil
        @value1 = 'value1'
        @value2 = 'value2'

        @did_run = false
        @was_value1 = false
        @was_value2 = false

        @firebase_key = @firebase['key']
        @firebase_key.on(:value) do |snapshot|
          @did_run = true
          @value = snapshot.value

          if @value == @value1
            @was_value1 = true
          end

          if @value == @value2
            @was_value2 = true
          end
        end
      end

      after do
        @firebase_key.off
      end

      it 'should run' do
        @firebase['key'] = @value1

        wait(0.1) do
          @did_run.should == true
        end
      end

      it 'should assign value1' do
        @firebase['key'] = @value1

        wait(0.1) do
          @did_run.should == true
          @value.should == @value1
          @was_value1.should == true
        end
      end

      it 'should not assign value2' do
        @firebase['key'] = @value1

        wait(0.1) do
          @did_run.should == true
          @value.should == @value1
          @was_value1.should == true
          @was_value2.should == false
        end
      end

      it 'should assign value2' do
        @firebase['key'] = @value1
        @firebase['key'] = @value2

        wait(0.1) do
          @did_run.should == true
          @value.should == @value2
          @was_value1.should == true
          @was_value2.should == true
        end
      end

    end

    # def <<(value)
    # def push(value)
    # def value=(value)
    # def set(value, &and_then)
    # def priority=(value)
    # def priority(value, &and_then)
    # def set(value, priority:priority, &and_then)
    # def update(values, &and_then)
    # def cancel_disconnect(&and_then)
    # def on_auth(options={}, &block)
    # def on_disconnect(value, &and_then)
    # def on_disconnect(value, priority:priority, &and_then)
    # def inspect
    # def on(event_type, options={}, &and_then)
    # def once(event_type, options={}, &and_then)
    # def off(handle=nil)
    # def start_at(priority)
    # def start_at(priority, child:child)
    # def end_at(priority)
    # def end_at(priority, child:child)

    # def run(options={}, &transaction)
    # def auth(credential, options={}, &and_then)
    # def auth_state

  end

end
