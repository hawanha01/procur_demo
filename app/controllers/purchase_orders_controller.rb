require "xmlrpc/client"
class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: %i[ show edit update destroy ]

  # GET /purchase_orders or /purchase_orders.json
  def index
    @purchase_orders = PurchaseOrder.all
  end

  # GET /purchase_orders/1 or /purchase_orders/1.json
  def show
  end

  # GET /purchase_orders/new
  def new
    @purchase_order = PurchaseOrder.new
  end

  # GET /purchase_orders/1/edit
  def edit
  end

  # POST /purchase_orders or /purchase_orders.json
  def create
    @purchase_order = PurchaseOrder.new(purchase_order_params)

    # url_1 = 'http://localhost:8069/'
    # db_1 = 'odoo1'
    # username_1 = admin
    # password_1 = 123456

    url = 'http://localhost:8069'
    db = 'odoodb'
    username = 'admin'
    password = '123456'
    common = XMLRPC::Client.new2("#{url}/xmlrpc/2/common")
    uid = common.call('authenticate', db, username, password, {})
    
    models = XMLRPC::Client.new2("#{url}/xmlrpc/2/object")

    # partner_id = 7
    # vendor_name = models.call('execute_kw', db, uid, password, 'res.partner', 'read', [[partner_id]], {'fields': ['name']})[0]['name']
    # product_id = 1
    # product_name = models.call('execute_kw', db, uid, password, 'product.template', 'read', [[product_id]], {'fields': ['name']})[0]['name']

    vendor_name = 'Lubmer inc'
    vendor_id = models.call('execute_kw', db, uid, password, 'res.partner', 'search', [[['name', '=', vendor_name]]])[0]
    puts "vendor_id: #{vendor_id}"
    product_name = 'cheese burger'
    product_id = models.call('execute_kw', db, uid, password, 'product.product', 'search', [[['name', '=', product_name]]])[0]
    puts "product_id: #{product_id}"
    date_order = Time.current.strftime('%m/%d/%Y %H:%M:%S')
    
    # purchase_order_data = {
    #   partner_id: "#{vendor_id}",
    #   date_order: date_order,
    #   order_line:[
    #     {
    #       product_id: product_id,
    #       product_qty: 10,
    #       price_unit: 1000.0,
    #     },
    #   ]
    # }
    # puts "purchase_order before: #{purchase_order_data}"
    # purchase_order_data = remove_unhashable_values(purchase_order_data)
    # puts "purchase_order: #{purchase_order_data}"

    purchase_order_id = models.call(
      'execute_kw', 
      db, 
      uid, 
      password, 
      'purchase.order', 
      'create', 
      [{ 
        'partner_id': vendor_id, 
        'order_line': [
          [0, 0, {'product_id': product_id, 'product_qty': 10, 'price_unit': 100.00}],
          [0, 0, {'product_id': product_id, 'product_qty': 20, 'price_unit': 100.00}]]
        }
      ]
    )
  
    # puts "New Purchase Order created with ID: #{purchase_order_id}"
    # info = XMLRPC::Client.new2('https://demo.odoo.com/start').call('start')
    # url, db, username, password = info['host'], info['database'], info['user'], info['password']
    # common = XMLRPC::Client.new2("#{url}/xmlrpc/2/common")
    # common.call('version')
    # uid = common.call('authenticate', db, username, password, {})
    # models = XMLRPC::Client.new2("#{url}/xmlrpc/2/object").proxy
    # puts "exeption #{models.call('execute_kw', db, uid, password, 'res.partner', 'check_access_rights', ['read'], {raise_exception: false})}"
    # puts "password #{password}"
    # puts "results #{models.call('execute_kw', db, uid, password, 'res.partner', 'search_read', [[['is_company', '=', true]]], {fields: %w(name country_id comment phone), limit: 5})}"
    # id = models.call('execute_kw', db, uid, password, 'res.partner', 'create', [{name: "New Partner"}])
    # puts "write #{models.call('execute_kw', db, uid, password, 'res.partner', 'write', [[id], {name: "Newer partner"}])}"
    # puts "result #{models.call('execute_kw', db, uid, password, 'res.partner', 'name_get', [[id]])}"

    respond_to do |format|
      if @purchase_order.save
        format.html { redirect_to purchase_order_url(@purchase_order), notice: "Purchase order was successfully created." }
        format.json { render :show, status: :created, location: @purchase_order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_orders/1 or /purchase_orders/1.json
  def update
    respond_to do |format|
      if @purchase_order.update(purchase_order_params)
        format.html { redirect_to purchase_order_url(@purchase_order), notice: "Purchase order was successfully updated." }
        format.json { render :show, status: :ok, location: @purchase_order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_orders/1 or /purchase_orders/1.json
  def destroy
    @purchase_order.destroy

    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: "Purchase order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def purchase_order_params
      params.require(:purchase_order).permit(:vendor, :product)
    end

    def remove_unhashable_values(hash)
      return hash unless hash.is_a?(Hash)
      hash.reject { |_, value| !value.respond_to?(:to_h) }
          .transform_values { |value| remove_unhashable_values(value) }
    end    
end
