class ItemsController < ApplicationController
  def new
    if params[:item_id]
      item_info = @gearlist_api.get_raw_item_details(params[:item_id])
      @item = Item.new(
        name:       item_info['name'],
        category:   item_info['category'],
        weight:     gms_to_oz(item_info['weight']),
        list_id:    params[:list_id],
      )
    else
      @item = Item.new
    end
    @list_id = params[:list_id]
    @sections = @gearlist_api.get_sections
    render :new
  end

  def create
    list_id = params["list_id"]
    item = params["item"]
    url = ApplicationController::BASE_URI + '/lists/'+ list_id + '/items'
    body_contents = {
      item: {
        name: item["name"],
        weight: oz_to_gms(item["weight"]),
        category: item["category"]
      },
      section: item["section"],
      quantity: item["quantity"],
      list_id: list_id
    }
    response = HTTParty.post(
      url, 
      body: body_contents,
      headers: auth_header
    )

    redirect_to list_path(list_id)
  end

  def edit
    list_info = @gearlist_api.get_list_details(params[:list_id])
    unless list_info['user_id'].to_s == @current_user_id
      flash[:errors] = ApplicationController::MESSAGES[:not_yo_list]
      redirect_to root_path
    else
      item_info = @gearlist_api.get_item_details(params[:id])
      @sections = @gearlist_api.get_sections
      @item = Item.new(
        name:       item_info['name'],
        category:   item_info['category'],
        weight:     gms_to_oz(item_info['weight']),
        quantity:   item_info['quantity'],
        list_id:    params[:list_id],
        section:    item_info['section'],
        id:         params[:id]
      )
    end
  end

  def update
    url = ApplicationController::BASE_URI + '/items/' + item_params[:id]

    body_contents = {
      item: {
        id: item_params['id'],
        name: item_params['name'],
        weight: oz_to_gms(item_params['weight']),
        category: item_params['category']
      },
      section: item_params['section'],
      quantity: item_params['quantity'],
    }
    response = HTTParty.put(
      url, 
      body: body_contents,
      headers: auth_header
    )

    redirect_to list_path(params[:list_id])
  end

  def destroy
    list_info = @gearlist_api.get_list_details(params[:list_id])
    unless list_info['user_id'].to_s == @current_user_id
      flash[:errors] = ApplicationController::MESSAGES[:not_yo_list]
    else
      item_id = params[:id]
      url = ApplicationController::BASE_URI + '/items/' + params[:id]

      response = HTTParty.delete(
        url,
        body: { list_section_item_id: item_id },
        headers: auth_header
      )

      contents = response.parsed_response
      flash[:errors] = contents[:failure] if contents[:failure]  
    end

    redirect_to list_path(params[:list_id])
  end

  def search
    url = ApplicationController::BASE_URI + '/items/search?q=' + params[:search]
    response = HTTParty.get(url, headers: auth_header)

    @items = response.parsed_response
    if @items.length == 0
      flash[:errors] = ApplicationController::MESSAGES[:items_search_failure]
      redirect_to new_list_item_path(params[:list_id])
    else
      render :search
    end
  end

  private

  def oz_to_gms(weight)
    (weight.to_f * 28.3495).to_i
  end

  def gms_to_oz(weight)
    (weight * 0.035274).round(1)
  end

  def item_params
    params.require(:item).permit(:id, :section, :category, :name, :quantity, :weight, :list_id)
  end
end
