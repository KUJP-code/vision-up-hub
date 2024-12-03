class InvoicesController < ApplicationController
  def index
    @invoices = policy_scope(Invoice)
  end

  def show
    @invoice = authorize Invoice.find(params[:id])
  end

  def edit
    @invoice = authorize Invoice.find(params[:id])
  end

  def create
    @invoice = authorize Invoice.new(invoice_params)
    if @invoice.save
      redirect_to @invoice, notice: 'Invoice was successfully created.'
    else
      render :new
    end
  end

  def update
    @invoice = authorize Invoice.find(params[:id])
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: 'Invoice was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @invoice = authorize Invoice.find(params[:id])
    @invoice.destroy
    redirect_to invoices_path, notice: 'Invoice was successfully deleted.'
  end

  private

  def invoice_params
    params.require(:invoice).permit(:organisation_id, :number_of_kids, :payment_option)
  end
end
