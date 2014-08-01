class Fixnum
  def to_bool
    (self == 0)? false : true
  end
end