describe 'Firebase' do

  it 'can create a Firebase instance' do
    firebase = Firebase.alloc.initWithUrl(MOTION_FIREBASE_SPEC)
    firebase.should.be.kind_of Firebase
  end

  it 'can create a Firebase instance with `new`' do
    firebase = Firebase.new(MOTION_FIREBASE_SPEC)
    firebase.should.be.kind_of Firebase
  end

  describe 'setting Firebase.URL' do
    [
      MOTION_FIREBASE_APP,
      "#{MOTION_FIREBASE_APP}.firebaseio.com/",
      "https://#{MOTION_FIREBASE_APP}",
      "https://#{MOTION_FIREBASE_APP}.firebaseio.com/",
    ].each do |shorthand|
      it "GOOD: #{shorthand}" do
        Firebase.url = shorthand
        Firebase.url.should == MOTION_FIREBASE_SPEC
      end
    end

    [
      "#{MOTION_FIREBASE_APP}/bad",     # 'app/bad'  - firebaseio.com missing
      "http://#{MOTION_FIREBASE_APP}",  # bad schemes
      "http://#{MOTION_FIREBASE_APP}.firebaseio.com",
      "ftp://#{MOTION_FIREBASE_APP}.firebaseio.com",
    ].each do |shorthand|
      it "BAD: #{shorthand}" do
        -> do
          Firebase.url = shorthand
        end.should.raise
      end
    end
  end

  it 'can create a Firebase instance using default URL' do
    Firebase.url = MOTION_FIREBASE_SPEC
    Firebase.url.should == MOTION_FIREBASE_SPEC
    firebase = Firebase.new
    firebase.should.be.kind_of Firebase
  end

  describe 'Firebase methods' do
    before do
      @firebase = Firebase.alloc.initWithUrl(MOTION_FIREBASE_SPEC).childByAppendingPath('specs')
    end

    it 'should clear! values' do
      @firebase.setValue('specs')
      wait 0.1 do
        @firebase.removeValue
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
      child.should.be.kind_of Firebase
      child.key.should == 'child'
    end

    it 'should allow `name` to return the same value as `key`' do
      child = @firebase.childByAppendingPath("any-child-name-#{(rand*255).round.to_s(16)}")
      child.name.should == child.key
    end

    it 'should append child names with multiple arguments to []' do
      child = @firebase['child', '1']
      child.should.be.kind_of Firebase
      child.key.should == '1'
      child.parent.key.should == 'child'
    end

    describe 'stopping handlers with "off"' do
      before do
        @firebase_off = @firebase['off']
        @firebase_off.value = nil
      end

      it 'should stop responding after calling "off" with a handle' do
        @value1 = nil
        @value2 = nil
        handler1 = @firebase_off.on(:value) do |snapshot|
          @value1 = snapshot.value
        end
        handler2 = @firebase_off.on(:value) do |snapshot|
          @value2 = snapshot.value
        end
        @firebase_off.value = 'off'

        wait(0.1) do
          @value1.should == 'off'
          @value2.should == 'off'
          @firebase_off.off(handler1)

          @firebase_off.value = 'on!'
          wait(0.1) do
            @value1.should == 'off'
            @value2.should == 'on!'
          end
        end
      end

      it 'should stop all callbacks after calling "off"' do
        @value1 = nil
        @value2 = nil
        handler1 = @firebase_off.on(:value) do |snapshot|
          @value1 = snapshot.value
        end
        handler2 = @firebase_off.on(:value) do |snapshot|
          @value2 = snapshot.value
        end
        @firebase_off.value = 'off'

        wait(0.1) do
          @value1.should == 'off'
          @value2.should == 'off'
          @firebase_off.off

          @firebase_off.value = 'on!'
          wait(0.1) do
            @value1.should == 'off'
            @value2.should == 'off'
          end
        end
      end

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

    describe "Pushing values onto a node" do
      before do
        @firebase_push = @firebase['push']
        @value = []
        @firebase_push.on(:child_added) do |snapshot|
          @value << snapshot.value
        end
      end

      after do
        @firebase_push.off
        @firebase_push.clear!
      end

      it 'should support push' do
        @firebase_push.push 'a'
        @firebase_push.push 'b'
        @firebase_push.push 'c'
        wait(0.1) do
          @value.should == ['a', 'b', 'c']
        end
      end

      it 'should support <<' do
        @firebase_push << 'a'
        @firebase_push << 'b'
        @firebase_push << 'c'
        wait(0.1) do
          @value.should == ['a', 'b', 'c']
        end
      end

    end

    # def value=(value)
    # def priority=(value)
    # def priority(value, &and_then)
    # def set(value, priority:priority, &and_then)
    # def update(values, &and_then)
    # def cancel_disconnect(&and_then)
    # def authenticated?(options={}, &block)
    # def on_disconnect(value, &and_then)
    # def on_disconnect(value, priority:priority, &and_then)
    # def inspect
    # def once(event_type, options={}, &and_then)
    # def start_at(priority)
    # def start_at(priority, child:child)
    # def equal_to(priority)
    # def equal_to(priority, child:child)
    # def end_at(priority)
    # def end_at(priority, child:child)

    # def transaction(options={}, &transaction)
    # def auth(token, &and_then)
    # def logout(&and_then)

  end

end
