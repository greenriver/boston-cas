class ProjectClient < ActiveRecord::Base

  has_one :client, required: false
  has_one :unit, foreign_key: :id_in_data_source, primary_key: :last_homeless_night_roomid
  has_one :building, foreign_key: :id_in_data_source, primary_key: :last_homeless_night_programid

  belongs_to :data_source, required: false

  # Is this client available for matching?
  # 1. If we had a bed night on the last night recorded, we are available
  # 2. If our most-recent project_exit_destination falls into one of the following, 
  # we are available:
    # Emergency shelter, including hotel or motel paid for with emergency shelter voucher
    # Hotel or motel paid for without emergency shelter voucher
    # No exit interview completed
    # Client Doesn't Know
    # Client refused
    # Client Refused
    # Client doesn't know
    # Other
    # Place not meant for habitation (e.g., a vehicle, an abandoned building, bus/train/subway station/airport or anywhere outside)
    # Data not collected
    # Safe Haven
  # 3. If our most recent project_exit_destination falls into one of the following, 
  # we are NOT available:
    # Deceased
    # Permanent housing for formerly homeless persons (such as: CoC project; or HUD legacy programs; or HOPWA PH)
    # Staying or living with family, temporary tenure (e.g., room, apartment or house)
    # Staying or living with family, permanent tenure
    # Moved from one HOPWA funded project to HOPWA PH
    # Owned by client, with ongoing housing subsidy
    # Rental by client, with VASH housing subsidy
    # Rental by client, with other ongoing housing subsidy
    # Rental by client, with GPD TIP housing subsidy
    # Residential project or halfway house with no homeless criteria
    # Long-term care facility or nursing home
    # Staying or living with friends, permanent tenure
    # Staying or living with friends, temporary tenure (e.g., room apartment or house)
    # Owned by client, no ongoing housing subsidy
    # Foster care home or foster care group home
    # Transitional housing for homeless persons (including homeless youth)
    # Rental by client, no ongoing housing subsidy
    # Hospital or other residential non-psychiatric medical facility
    # Psychiatric hospital or other psychiatric facility
    # Substance abuse treatment facility or detox center
    # Jail, prison or juvenile detention facility
  # 4. If our most recent project_exit_destination_generic falls into one of the following, we ae available:
    # Client refused
    # Client doesn't know
    # Client became homeless – moving to a shelter or other place unfit for human habitation
    # Data not collected
  def available?
    newest_bed_night = ProjectClient.where.not(calculated_last_homeless_night: nil).order(calculated_last_homeless_night: :desc).first.calculated_last_homeless_night
    if calculated_last_homeless_night != nil && calculated_last_homeless_night >= newest_bed_night
      return true
    end
    # there are fewer entries for the generic exit, but also fewer checks, so check those first
    case project_exit_destination_generic
    when 'Client refused', 
      "Client doesn't know", 
      /Client became homeless.*/, 
      'Data not collected'
      #puts "available based on project_exit_destination_generic: #{project_exit_destination_generic}"
      return true
    when nil
      case project_exit_destination
      when /.*refused.*/i,
       /.*emergency.*/i, 
       /no exit interview.*/i, 
       /client doesn't know/i,
       /other/i, 
       /.*not meant for habitation.*/i,
       /safe haven/i,
       nil
        #puts "available based on project_exit_destination: #{project_exit_destination}"
        return true
      end
    end
    return false
  end

  def substance_abuse?
    case substance_abuse_problem
      when /.*refused.*/i,
      /client doesn't know/i,
      /no/i,
      /data not collected/i,
      nil
        return false
    end
    return true
  end

  private

end
