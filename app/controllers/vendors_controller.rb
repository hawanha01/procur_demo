class VendorsController < ApplicationController
  before_action :set_vendor, only: %i[ show edit update destroy ]
  before_action :set_config
  # GET /vendors or /vendors.json
  def index
    @vendors = Vendor.all
  end

  # GET /vendors/1 or /vendors/1.json
  def show
  end

  # GET /vendors/new
  def new
    @vendor = Vendor.new
  end

  # GET /vendors/1/edit
  def edit
  end

  # POST /vendors or /vendors.json
  def create
    @vendor = Vendor.new(vendor_params)

    respond_to do |format|
      if @vendor.save
        vendor_id = @models.call(
          'execute_kw', 
          @db, 
          @uid, 
          @password, 
          'res.partner',   
          'create', 
          [{ 'name': @vendor.name }]
        )
        @vendor.vendor_id = vendor_id
        @vendor.save!
        format.html { redirect_to vendor_url(@vendor), notice: "Vendor was successfully created." }
        format.json { render :show, status: :created, location: @vendor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vendors/1 or /vendors/1.json
  def update
    respond_to do |format|
      if @vendor.update(vendor_params)
        @models.call(
          'execute_kw', 
          @db, 
          @uid, 
          @password, 
          'res.partner',   
          'write', 
          [[@vendor.vendor_id], { 'name': @vendor.name }]
        )
        format.html { redirect_to vendor_url(@vendor), notice: "Vendor was successfully updated." }
        format.json { render :show, status: :ok, location: @vendor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vendors/1 or /vendors/1.json
  def destroy
    @models.call(
      'execute_kw', 
      @db, 
      @uid, 
      @password, 
      'res.partner',   
      'unlink', 
      [[@vendor.vendor_id]]
    )
    @vendor.destroy

    respond_to do |format|
      format.html { redirect_to vendors_url, notice: "Vendor was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_config
      @url = 'http://localhost:8069'
      @db = 'mydb'
      @username = 'admin'
      @password = 'admin'
      @common = XMLRPC::Client.new2("#{@url}/xmlrpc/2/common")
      @uid = @common.call('authenticate', @db, @username, @password, {})
      @models = XMLRPC::Client.new2("#{@url}/xmlrpc/2/object")
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_vendor
      @vendor = Vendor.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def vendor_params
      params.require(:vendor).permit(:name)
    end
end
