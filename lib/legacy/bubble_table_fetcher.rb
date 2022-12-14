# frozen_string_literal: true

require 'byebug'

# class BubbleTableFetcher
class BubbleTableFetcher
  def initialize(bubble_api_service)
    @bubble_api = bubble_api_service
  end

  def call(name)
    types = @bubble_api.call(name, 1)['results'].first
    analyze_response_data_types(types)
  end

  private

  def analyze_response_data_types(response)
    response_data_type = {}
    response.each { |key, value| response_data_type[key] = check_data_type(value) }
    response_data_type
  end

  def check_data_type(value)
    return 'INT' if value.instance_of?(Integer)
    return 'BOOLEAN' if value.is_a?(TrueClass) || value.is_a?(FalseClass)
    return 'FLOAT8' if value.is_a?(Float)
    return 'TEXT ARRAY' if value.is_a?(Array)
    return 'JSON' if value.is_a?(Hash)
    return 'TEXT' if value.nil?
    return 'TIMESTAMPTZ' if value.match?(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z/)
    return 'TEXT' if value.match?(/\d{13}x\d{18}/) || value.instance_of?(String)
  end
end
