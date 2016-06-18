class Hash
  def method_missing(sym,*)
    fetch(sym){fetch(sym.to_s){super}}
  end
end