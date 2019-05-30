require 'rails_helper'

RSpec.describe ImportedClientsCsv, type: :model do
  it 'refuses to load an invalid file header' do
    csv = load 'invalid_header.csv'
    expect(csv.import).to be false
    expect(ImportedClient.count).to eq 0
  end

  it 'skips invalid rows' do
    csv = load 'invalid_row.csv'
    expect(csv.import).to be true
    expect(ImportedClient.count).to eq 1
  end

  it 'doesn\'t duplicate rows' do
    csv = load 'duplicated_row.csv'
    expect(csv.import).to be true
    expect(ImportedClient.count).to eq 1
  end

  def load file
    content = File.read('spec/fixtures/imported_clients_csv/' + file)
    ImportedClientsCsv.new(content: content)
  end
end