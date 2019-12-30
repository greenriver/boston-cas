###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class MessageJob < Struct.new(:schedule)
  def perform
    messages = Message.unsent.unseen.joins(:user).order( created_at: :desc ).preload(:user)
    messages = messages.where( User.arel_table[:email_schedule].eq schedule ) if schedule.present?
    messages.all.group_by(&:user).each do |user, messages|
      DigestMailer.with(user: user, messages: messages).digest.deliver_now
      Message.where( id: messages.map(&:id) ).update_all sent_at: DateTime.current
    end
  end
end