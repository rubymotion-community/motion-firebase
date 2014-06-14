describe 'SimpleAuth' do
  before do
    @firebase_ref = Firebase.alloc.initWithUrl(MOTION_FIREBASE_SPEC).childByAppendingPath('specs')
    @auth         = FirebaseSimpleLogin.new(@fire_ref)
  end

  it "is wired up right" do
    @firebase_ref.should.is_a?(Firebase)
    @auth.should.is_a?(FirebaseSimpleLogin)
  end

  it "calls the original unauth method on logout" do
    class Firebase
      attr_reader :old_unauth_called

      def initialize
        @old_unauth_called = false
      end

      def old_unauth
        @old_unauth_called = true
      end

      @auth.logout.should.change{@old_unauth_called}
    end
  end
end
