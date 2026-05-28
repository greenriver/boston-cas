###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileContentValidator do
  # CSV validation is tested through ImportedClientsCsv which calls:
  #   super(file_content, claimed_content_type, ['text/plain', 'text/csv', ...], '.csv')
  #
  # XLSX validation is tested through DeidentifiedClientsXlsx which calls:
  #   super(file_content, claimed_content_type, ['application/vnd.openxmlformats-...', ...], '.xlsx')

  let(:valid_csv) { "name,email\nfoo,bar@example.com\n" }

  # Real XLSX files are ZIP archives. Marcel detects them as 'application/zip'.
  # The code normalizes application/zip + .xlsx extension → XLSX MIME type.
  let(:xlsx_zip_magic) { [80, 75, 3, 4].pack('C*') + ("\x00" * 100) }

  # ELF binary – Marcel detects this as application/x-executable, not a CSV type.
  let(:elf_binary) { "\x7fELF\x02\x01\x01\x00" + ("\x00" * 100) }

  # Random bytes with no recognizable magic signature → Marcel returns
  # application/octet-stream → falls through to the magic-bytes fallback.
  let(:random_binary) { ("\x00\x01\x02\x03\x04\x05" * 50).b }

  describe 'CSV validation via ImportedClientsCsv' do
    def validate(content, claimed_type = nil)
      ImportedClientsCsv.validate_file_content(content, claimed_type)
    end

    context 'when content is nil' do
      it 'is invalid' do
        result = validate(nil)
        expect(result[:valid]).to be false
        expect(result[:error]).to eq('No file content provided')
      end
    end

    context 'when content is blank' do
      it 'is invalid' do
        result = validate('')
        expect(result[:valid]).to be false
        expect(result[:error]).to eq('No file content provided')
      end
    end

    context 'when file exceeds 25 MB' do
      it 'is invalid with a size error' do
        # 26 MB of ASCII text
        oversized = ('a' * (26 * 1024 * 1024))
        result = validate(oversized)
        expect(result[:valid]).to be false
        expect(result[:error]).to include('too large')
        expect(result[:error]).to include('25 MB')
      end
    end

    context 'when content is a binary executable disguised as CSV' do
      it 'is invalid' do
        result = validate(elf_binary)
        expect(result[:valid]).to be false
        expect(result[:error]).to include('CSV')
      end
    end

    context 'when content is random binary (Marcel returns application/octet-stream)' do
      it 'is invalid because magic bytes check fails (no commas or newlines)' do
        result = validate(random_binary)
        expect(result[:valid]).to be false
      end
    end

    context 'when content is valid CSV' do
      it 'is valid' do
        result = validate(valid_csv)
        expect(result[:valid]).to be true
      end
    end

    context 'when content is valid but claimed_content_type is not a CSV type' do
      it 'is invalid' do
        result = validate(valid_csv, 'application/pdf')
        expect(result[:valid]).to be false
        expect(result[:error]).to include('application/pdf')
        expect(result[:error]).to include('not supported')
      end
    end

    context 'when claimed_content_type matches an allowed CSV type' do
      it 'is valid' do
        result = validate(valid_csv, 'text/csv')
        expect(result[:valid]).to be true
      end
    end
  end

  describe 'XLSX validation via DeidentifiedClientsXlsx' do
    def validate(content, claimed_type = nil)
      DeidentifiedClientsXlsx.validate_file_content(content, claimed_type)
    end

    context 'when content is nil' do
      it 'is invalid' do
        result = validate(nil)
        expect(result[:valid]).to be false
        expect(result[:error]).to eq('No file content provided')
      end
    end

    context 'when file exceeds 25 MB' do
      it 'is invalid with a size error' do
        oversized = ('a' * (26 * 1024 * 1024))
        result = validate(oversized)
        expect(result[:valid]).to be false
        expect(result[:error]).to include('too large')
      end
    end

    context 'when content is a real XLSX file (ZIP magic bytes)' do
      # This is the critical normalization path: Marcel detects ZIP magic bytes
      # and returns 'application/zip'. The code must normalize this to the XLSX
      # MIME type rather than rejecting it, since XLSX files are ZIP archives.
      it 'is valid after normalizing application/zip to the XLSX MIME type' do
        result = validate(xlsx_zip_magic)
        expect(result[:valid]).to be true
        expect(result[:detected_type]).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      end
    end

    context 'when content is a CSV file uploaded to the XLSX validator' do
      it 'is invalid' do
        result = validate(valid_csv)
        expect(result[:valid]).to be false
        expect(result[:error]).to include('XLSX')
      end
    end

    context 'when content is valid XLSX but claimed_content_type is wrong' do
      it 'is invalid' do
        result = validate(xlsx_zip_magic, 'text/csv')
        expect(result[:valid]).to be false
        expect(result[:error]).to include('text/csv')
        expect(result[:error]).to include('not supported')
      end
    end
  end

  describe 'magic byte fallback (application/octet-stream path)' do
    # When Marcel cannot identify the content type it returns application/octet-stream.
    # The validator then inspects the raw bytes to decide whether to accept or reject.

    context 'with .csv extension' do
      it 'accepts content containing commas and newlines' do
        # A file Marcel cannot fingerprint but that has CSV-shaped bytes
        ambiguous_csv = "col1,col2\nval1,val2\n"
        result = ImportedClientsCsv.validate_file_content(ambiguous_csv, nil)
        expect(result[:valid]).to be true
      end

      it 'rejects random binary that lacks commas and newlines' do
        result = ImportedClientsCsv.validate_file_content(random_binary, nil)
        expect(result[:valid]).to be false
      end
    end

    context 'with .xlsx extension' do
      it 'accepts content starting with PK ZIP magic bytes' do
        # Build the minimal magic bytes Marcel cannot distinguish from a partial
        # ZIP – but the code's own magic check should still pass it through
        pk_content = [80, 75, 3, 4].pack('C*') + ("\x00" * 30)
        result = DeidentifiedClientsXlsx.validate_file_content(pk_content, nil)
        expect(result[:valid]).to be true
      end
    end
  end
end
