class PrePopulateMadeAvailable < ActiveRecord::Migration
  def up
    Voucher.where(made_available_at: nil).find_each do |voucher|
      if voucher.available?
        changed_to_available_at = voucher.versions.
          where("object like '%\navailable: false\n%'").
          order(created_at: :desc).limit(1).
          pluck(:created_at)&.last
        voucher.update(made_available_at: changed_to_available_at)
      else
        last_available = voucher.versions.
          where("object like '%\navailable: true\n%'")&.last
        if last_available
          changed_to_available_at = last_available.previous&.created_at
          voucher.update(made_available_at: changed_to_available_at)
        end
      end
    end

  end
end
