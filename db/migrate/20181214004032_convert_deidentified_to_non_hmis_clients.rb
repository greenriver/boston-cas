class ConvertDeidentifiedToNonHmisClients < ActiveRecord::Migration
  def up
    if NonHmisClient.any?
      NonHmisClient.all.each do | client |
        if client.identified
          client.update_columns(type: :IdentifiedClient)
        else
          client.update_columns(type: :DeidentifiedClient)
        end
      end
    end
  end
end
