require 'rails_helper'

RSpec.describe ImportedClientsCsv, type: :model do
  it 'refuses to load an invalid file header' do
    csv = read 'invalid_header.csv'
    expect(csv.import).to be false
    expect(ImportedClient.count).to eq 0
  end

  it 'skips invalid rows' do
    csv = read 'invalid_row.csv'
    expect(csv.import).to be true
    expect(ImportedClient.count).to eq 4
    expect(ImportedClient.all.map{ |c| c.email }).not_to include('test@test.com')
    expect(ImportedClient.all.map{ |c| c.email }).to include('test2@test.com', 'test3@test.com','test4@test.com','test5@test.com')
  end

  it 'doesn\'t duplicate rows' do
    csv = read 'duplicated_row.csv'
    expect(csv.import).to be true
    expect(ImportedClient.count).to eq 1
  end

  it 'handles existing clients' do
    csv = read 'first.csv'
    expect(csv.import).to be true
    expect(ImportedClient.count).to eq 5
    expect(ImportedClient.all.map{ |c| c.email }).to include('test@test.com', 'test2@test.com', 'test3@test.com','test4@test.com','test5@test.com')

    csv = read 'second.csv'
    expect(csv.import).to be true
    expect(ImportedClient.count).to eq 8
    expect(ImportedClient.all.map{ |c| c.first_name }).to include('TestX')
    expect(ImportedClient.all.map{ |c| c.last_name }).to include('McTest2')
    expect(ImportedClient.all.map{ |c| c.email }).to include('test6@test.com')
  end

  def read file
    content = File.read('spec/fixtures/imported_clients_csv/' + file)
    ImportedClientsCsv.new(content: content)
  end
end