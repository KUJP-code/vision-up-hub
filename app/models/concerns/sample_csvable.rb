# frozen_string_literal: true

module SampleCsvable
  extend ActiveSupport::Concern
  require 'csv'

  included do
    def sample_csv(headers)
      CSV.generate(headers:, write_headers: true) do |csv|
        csv.rewind
        csv.read
      end
    end
  end
end
