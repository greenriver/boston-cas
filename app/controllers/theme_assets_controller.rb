###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

# Serves theme logo and favicon blobs without authentication.
# Inherits from ActionController::Base (not ApplicationController) so no
# authenticate_user! or session-timeout checks apply.
# Blob bytes are cached in memory on Theme for CACHE_TTL to avoid hitting S3
# on every page load.
class ThemeAssetsController < ActionController::Base
  CACHE_TTL = 1.day

  def logo
    serve_attachment(Theme.logo)
  end

  def favicon_32
    serve_attachment(Theme.favicon_32)
  end

  def favicon_16
    serve_attachment(Theme.favicon_16)
  end

  def favicon_ico
    serve_attachment(Theme.favicon_ico)
  end

  private

  def serve_attachment(attachment)
    unless attachment.attached?
      head :not_found
      return
    end

    blob = attachment.blob
    entry = Theme.blob_cache[blob.id]

    if entry.nil? || entry[:cached_at] < CACHE_TTL.ago
      Theme.blob_cache[blob.id] = {
        data: blob.download,
        content_type: blob.content_type,
        filename: blob.filename.to_s,
        cached_at: Time.current,
      }
      entry = Theme.blob_cache[blob.id]
    end

    expires_in CACHE_TTL, public: true
    send_data entry[:data], type: entry[:content_type], filename: entry[:filename], disposition: 'inline'
  end
end
