class AddParkedClientsReport < ActiveRecord::Migration[6.0]
  REPORTS = {
    'Operational Reports' => [
      {
        url: 'reports/parked_clients',
        name: 'Parked Clients',
        description: 'The currently parked clients.',
        limitable: false,
      },
    ],
  }


  def up
    REPORTS.each do |group, reports|
      reports.each do |report|
        ReportDefinition.create(
          report_group: group,
          url: report[:url],
          name: report[:name],
          description: report[:description],
          limitable: report[:limitable]
        )
      end
    end
  end

  def down
    REPORTS.each do |group, reports|
      reports.each do |report|
        ReportDefinition.where(url: report[:url]).delete_all
      end
    end
  end
end
