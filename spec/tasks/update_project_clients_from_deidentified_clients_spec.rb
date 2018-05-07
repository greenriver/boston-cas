require "rails_helper"

describe "rake cas:update_project_clients_from_deidentified_clients", type: :task do
  let!(:warehouse_data_source) { create :data_source, :warehouse}
  let!(:deidentified_data_source) { create :data_source, :deidentified}
  
  let!(:deidentified_client_john) { create :deidentified_client, client_identifier: "john", active_cohort_ids: ["1", "5", "7"] }
  let!(:deidentified_client_mary) { create :deidentified_client, client_identifier: "mary", active_cohort_ids: ["4", "9"] }

  let!(:project_client_alice)  { create :project_client, data_source: warehouse_data_source, first_name: "alice" }
  let!(:project_client_arnold)  { create :project_client, data_source: deidentified_data_source, first_name: "arnold" }
  let!(:project_client_linda)  { create :project_client, data_source: deidentified_data_source, first_name: "linda" }
  
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end
  
  it "creates missing project clients" do 
    expect{ task.execute }.to change{ ProjectClient.count }.by(2)
  end 
    
  describe "when one project client exists" do
    let!(:project_client_john)  do
      create :project_client, 
        data_source: deidentified_data_source, 
        first_name: deidentified_client_john.first_name, 
        id_in_data_source: deidentified_client_john.id
    end
    
    it "creates missing project clients" do 
      expect{ task.execute }.to change{ ProjectClient.count }.by(1)
    end
    
    it "updates existing project clients" do
      task.execute
      expect(        
        project_client_john.reload.active_cohort_ids
      ).to eq(deidentified_client_john.active_cohort_ids)
    end
    
    it "removes unused ProjectClients" do 
      task.execute
      expected_ids = [
        deidentified_client_mary.id,
        deidentified_client_john.id,
      ]
      expect(ProjectClient.in_data_source(deidentified_data_source).pluck(:id_in_data_source).compact.sort).to eq(expected_ids.sort)
    end
    
    it "doesn't interfere with project clients that come from a different data source" do    
      expect{ task.execute }.to_not change{ project_client_alice } 
    end
  end
end
