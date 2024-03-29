# frozen_string_literal: true

module BubbleRuby
  class DB::Schema
    class Table::Column
      require_relative 'column/create_query'
      require_relative 'column/check_query'

      Type = lambda do |value|
        value.is_a?(Hash) or raise TypeError, 'Não é um hash'
        return 'JSON'        if value.keys.include?('$ref')
        return 'TIMESTAMPTZ' if value.keys.include?('format') && value['format'] == 'date-time'
        return 'TEXT'        if value['type'] == 'string' || value['type'] == 'option set'
        return 'FLOAT8'      if value['type'] == 'number'
        return 'BOOLEAN'     if value['type'] == 'boolean'
        return 'TEXT ARRAY'  if value['type'] == 'array'
      end

      attr_reader :name, :type, :table_name

      def initialize(table_name:, name:, type:)
        self.table_name = table_name
        self.name       = name
        self.type = Type[type]
      end

      def create_query
        CreateQuery.call(self)
      end

      private

      attr_writer :name, :type, :table_name
    end
  end
end
