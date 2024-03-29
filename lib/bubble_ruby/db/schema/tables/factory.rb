# frozen_string_literal: true

module BubbleRuby
  require_relative '../table'
  require_relative '../table/column'
  class DB::Schema::Tables
    class Factory
      attr_reader :response

      def initialize(response)
        response.is_a?(Response) or raise TypeError
        self.response = response
      end

      def call
        response.tables_response.map do |table_name, table_body|
          create_table(table_name, table_body)
        end
      end

      private

      attr_writer :response

      def create_table(table_name, table_body)
        table = DB::Schema::Table.new(name: table_name)
        table_body['properties'].each do |column_name, column_type|
          column = DB::Schema::Table::Column.new(
            table_name: table.name,
            name: column_name,
            type: column_type
          )
          table.body << column
        end
        table
      end
    end
  end
end
