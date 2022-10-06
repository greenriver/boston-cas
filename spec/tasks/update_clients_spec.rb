require "rails_helper"

describe "rake cas:update_clients", type: :task do
  let!(:warehouse_data_source) { create :data_source, :warehouse}
  let!(:deidentified_data_source) { create :data_source, :deidentified}

  let!(:deidentified_client_john) { create :deidentified_client, client_identifier: "john" }
  let!(:deidentified_client_mary) { create :deidentified_client, client_identifier: "mary" }

  let!(:identified_client) { create :identified_client, female: true, transgender: true, ethnicity: 1, asian: true, white: true }

  let!(:existing_client) {create :client, first_name: 'joe' }

  let!(:project_client_alice)  { create :project_client, data_source: warehouse_data_source, first_name: "alice", id_in_data_source: 'alice' }
  let!(:project_client_arnold)  { create :project_client, data_source: deidentified_data_source, first_name: "arnold", id_in_data_source: 'arnold' }
  let!(:project_client_linda)  { create :project_client, data_source: deidentified_data_source, first_name: "linda", id_in_data_source: 'linda' }
  let!(:project_client_linda)  { create :project_client, data_source: deidentified_data_source, first_name: "joe", id_in_data_source: 'joe', client_id: existing_client.id }


  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it 'does not throw an error' do
    expect { task.execute }.not_to raise_error
  end

  it 'creates missing ProjectClient for identified client and persists demographic data' do
    task.execute
    project_client = identified_client.project_client
    expect(project_client).not_to eq(nil)
    expect(project_client.female).to eq(true)
    expect(project_client.transgender).to eq(true)
    expect(project_client.ethnicity).to eq(1)
    expect(project_client.asian).to eq(true)
    expect(project_client.white).to eq(true)
  end
end
