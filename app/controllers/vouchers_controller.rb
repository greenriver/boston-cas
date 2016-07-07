class VouchersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_dnd_staff!
  before_action :set_voucher, only: [:update, :destroy]
  before_action :set_sub_program, only: [:create, :index, :bulk_update]
  before_action :set_program, only: [:index, :bulk_update]

  def index
    @vouchers = @subprogram.vouchers.preload(:status_match).order(:id)
  end  

  def create
    new_vouchers = []
    vouchers_to_create = voucher_params[:add_vouchers].to_i.times do 
      new_vouchers << Voucher.create(sub_program: @subprogram)
    end
    if vouchers_to_create == new_vouchers.length
      flash[:notice] = "#{vouchers_to_create} vouchers added"
      redirect_to action: :index
    else
      flash[:error] = "Please review the form problems below."
      redirect_to action: :index
    end
  end

  def update
  end

  def bulk_update
    @vouchers = []
    voucher_params[:vouchers_attributes].each do |i,v|
      voucher = @subprogram.vouchers.preload(:status_match).detect {|subp_voucher| subp_voucher.id == v[:id].to_i}
      raise ActiveRecord::NotFound unless voucher
      voucher.assign_attributes(v)
      @vouchers << voucher
    end

    if @vouchers.all?(&:valid?)
      run_match_engine = false
      @vouchers.each do |voucher|
        # check this before we save the voucher
        changed_to_available = voucher.changing_to_available?
        save_success = voucher.save
        if save_success && voucher.available?
          voucher.opportunity || voucher.create_opportunity!(available: true, available_candidate: true)
        end
        
        if save_success && changed_to_available
          run_match_engine = true
        end
      end
      Matching::RunEngineJob.perform_later if run_match_engine
      # update the sub_program to reflect changes 
      @subprogram.update_summary!
      flash[:notice] = "Vouchers updated"
      redirect_to action: :index
    else # some voucher is invalid
      flash[:alert] = 'Vouchers could not be updated.  Please correct the errors below.'
      render :index
    end
  end

  def destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_voucher
    @voucher = Voucher.find(params[:id])
  end
  def set_sub_program
    @subprogram = SubProgram.find(params[:sub_program_id])
  end
  def set_program
    @program = Program.find(params[:program_id])
  end
  # Only allow a trusted parameter "white list" through.
  def voucher_params
    params.require(:sub_program).
      permit(
        :sub_program_id,
        :add_vouchers,
        vouchers_attributes: [:id, :available, :unit_id, :date_available],
      )
  end
end
