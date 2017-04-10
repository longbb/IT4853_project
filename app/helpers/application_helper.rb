module ApplicationHelper
  def concat_array array1, array2
    array2.each do |element|
      array1.push element
    end
    return array2
  end
end
