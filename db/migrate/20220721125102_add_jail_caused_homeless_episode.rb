class AddJailCausedHomelessEpisode < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :jail_caused_episode, :boolean, default: :false
    add_column :non_hmis_assessments, :income_caused_episode, :boolean, default: :false
    add_column :non_hmis_assessments, :ipv_caused_episode, :boolean, default: :false
    add_column :non_hmis_assessments, :violence_caused_episode, :boolean, default: :false
    add_column :non_hmis_assessments, :chronic_health_caused_episode, :boolean, default: :false
    add_column :non_hmis_assessments, :acute_health_caused_episode, :boolean, default: :false
    add_column :non_hmis_assessments, :idd_caused_episode, :boolean, default: :false
    add_column :non_hmis_assessments, :pregnant, :boolean, default: :false
    add_column :non_hmis_assessments, :pregnant_under_28_weeks, :boolean, default: :false
  end
end
