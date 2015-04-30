describe 'MotionFirebase utilities' do
  describe 'convert_event_type' do
    [
      [[:child_added, :added], FEventTypeChildAdded],
      [[:child_moved, :moved], FEventTypeChildMoved],
      [[:child_changed, :changed], FEventTypeChildChanged],
      [[:child_removed, :removed], FEventTypeChildRemoved],
      [[:value], FEventTypeValue],
    ].each do |symbols, actual|
      symbols.each do |sym|
        it("should convert #{sym.inspect}") do
          Firebase.convert_event_type(sym).should == actual
        end
      end
    end
  end
end
