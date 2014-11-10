describe 'Firebase query methods' do

  before do
    @firebase = Firebase.alloc.initWithUrl(MOTION_FIREBASE_SPEC)
  end

  [
    { order_by_key: true },
    { order_by_priority: true },
    { order_by: 'key' },
    { first: 5 },
    { last: 5 },
    { starting_at: 'foo' },
    { starting_at: 'foo', key: 'key' },
    { ending_at: 'bar' },
    { ending_at: 'bar', key: 'key' },
    { equal_to: 'baz' },
    { equal_to: 'baz', key: 'key' },
    { first: 5, starting_at: 'foo' },
  ].each do |opts|
    it "should accept #{opts.inspect}" do
      query = @firebase.query(opts)
      query.should.be.kind_of(FQuery)
    end
  end

end
