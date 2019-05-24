require "rails_helper"

describe "rake cas:update_clients", type: :task do
  let!(:warehouse_data_source) { create :data_source, :warehouse}
  let!(:deidentified_data_source) { create :data_source, :deidentified}
  
  let!(:deidentified_client_john) { create :deidentified_client, client_identifier: "john" }
  let!(:deidentified_client_mary) { create :deidentified_client, client_identifier: "mary" }

  let!(:existing_client) {create :client, first_name: 'joe' }

  let!(:project_client_alice)  { create :project_client, data_source: warehouse_data_source, first_name: "alice" }
  let!(:project_client_arnold)  { create :project_client, data_source: deidentified_data_source, first_name: "arnold" }
  let!(:project_client_linda)  { create :project_client, data_source: deidentified_data_source, first_name: "linda" }
  let!(:project_client_linda)  { create :project_client, data_source: deidentified_data_source, first_name: "joe", client_id: existing_client.id }


  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it 'does not throw an error' do
    expect { task.execute }.not_to raise_error
  end
  
end
