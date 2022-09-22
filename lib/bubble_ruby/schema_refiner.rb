# frozen_string_literal: true

require_relative 'query_builder'
require 'byebug'

module BubbleRuby
  # class SchemaRefiner is responsible to update the postgre db schema from the schema generated by the db_schema_builder (using the swagger documentation)
  class SchemaRefiner
    include BubbleRuby::QueryBuilder
    def initialize(schema)
      @schema = schema
    end

    def call
      puts 'Checking tables'
      pg_table_names = execute_query(build_check_table_names_query).column_values(0)
      @schema.each do |table|
        puts "Checking #{table[:name]} exists in Postgre"
        return create_table(table) unless pg_table_names.include?(table[:name])

        puts "#{table[:name]} exists!"
        puts 'Check if columns are updated!'
        verify_table_columns(table)
      end
    end

    private

    def create_table(table)
      puts "Creating #{table[:name]} table!"
      execute_query(build_add_table_query(table))
    end

    def add_column(table_name, column, type)
      puts "Adding #{column} column to #{table_name}"
      execute_query(build_add_column_query(table_name, column, type))
    end

    def verify_table_columns(table)
      pg_columns = execute_query(build_check_column_names_query(table[:name])).column_values(3)
      table[:body].each do |column, type|
        puts "Checking if column #{column} exists inside #{table[:name]}"
        add_column(table[:name], column, type) unless pg_columns.include?(column)
      end
    end
  end
end