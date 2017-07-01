describe 'MotionFirebase utilities' do
  describe 'convert_event_type' do
    [
      [[:child_added, :added], FIRDataEventTypeChildAdded],
      [[:child_moved, :moved], FIRDataEventTypeChildMoved],
      [[:child_changed, :changed], FIRDataEventTypeChildChanged],
      [[:child_removed, :removed], FIRDataEventTypeChildRemoved],
      [[:value], FIRDataEventTypeValue],
    ].each do |symbols, actual|
      symbols.each do |sym|
        it("should convert #{sym.inspect}") do
          Firebase.convert_event_type(sym).should == actual
        end
      end
    end
  end
end
