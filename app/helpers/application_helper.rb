module ApplicationHelper
  def concat_array array1, array2
    if array2.present?
      array2.each do |element|
        array1.push element
      end
    end
    return array1
  end
end
