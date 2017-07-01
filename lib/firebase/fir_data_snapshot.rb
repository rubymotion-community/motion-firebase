class FIRDataSnapshot

  def inspect
    "#<#{self.class}:0x#{self.object_id.to_s(16)} value=#{self.value.inspect} ref=#{self.ref.inspect}>"
  end

  def to_s
    self.value.to_s
  end

  def to_bool
    if self.value == 0 || self.value == false
      false
    else
      true
    end
  end

  def value?
    to_bool
  end

end
