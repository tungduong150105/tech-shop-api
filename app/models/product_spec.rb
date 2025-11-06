class ProductSpec < ApplicationRecord
  def self.ensure_label_exists(label, category_id)
    existing = find_by(label: label, category_id: category_id)
    return existing if existing
    create(label: label, category_id: category_id, value: [])
  end

  def self.add_value_to_label(label, category_id, value_data)
    spec = ensure_label_exists(label, category_id)
    current_value = spec.value || []
    new_value = value_data.is_a?(Hash) ? value_data : { "value" => value_data }
    return if current_value.include?(value_data)
    spec.update!(value: current_value + [value_data])
  end
end
