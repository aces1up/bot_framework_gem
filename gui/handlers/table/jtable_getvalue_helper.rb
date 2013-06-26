

module GetValueAtHelperModule

  def col_to_sym(column)
      column.downcase.gsub(' ','_').to_sym
  end

  def sym_to_col(column)
      column.to_s.gsub('_',' ').cap_words
  end

end
