module RailsCom::I18n
  extend ActiveSupport::Concern

  included do
    before_update :update_i18n_column
  end

  def update_i18n_column
    str = []
    self.changes.slice(*i18n_attributes).each do |key, _|
      value = self.public_send("#{key}_before_type_cast")
      str << "#{key} = #{key}::jsonb || '#{value.to_json}'::jsonb"
    end
    s = str.join(' AND ')
    self.class.connection.execute "UPDATE #{self.class.table_name} SET #{s} WHERE id = #{self.id}"
  end

end

module RailsCom::Translation

  # name
  # * store as jsonb in database;
  # * read with i18n scope
  def has_translations(*columns)
    mattr_accessor :i18n_attributes
    self.i18n_attributes = columns.map(&:to_s)
    include RailsCom::I18n
    columns.each do |column|
      attribute column, :i18n

      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1

        def #{column}=(value)
          if value.is_a?(String)
            super(::I18n.locale.to_s => value)
          else
            super
          end
        end

      RUBY_EVAL
    end

  end

  def _update_record(values, constraints)
    values.except!(*i18n_attributes)
    super
  end

  def _insert_record(values)
    values.slice(*i18n_attributes).each do |key, v|
      values[key] = v
    end
    super
  end

end

ActiveSupport.on_load :active_record do
  extend RailsCom::Translation
end
