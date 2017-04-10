class CrawlerController < ApplicationController
  require "json"

  def crawl
    product_id = "B01N7TEHOU"
    # html = open("https://www.amazon.com/dp/B01N7TEHOU")
    url = "http://www.ebay.com/itm//122434372520"
    html = Faraday.new.get(url).body
    doc = Nokogiri::HTML(html)
    title = doc.css("h1#itemTitle").children[1].text
    itemCondition = doc.css("div[itemprop='itemCondition']").text
    data = {
      title: title,
      itemCondition: itemCondition
    }
    item_info = doc.to_s.split("$rwidgets(")[1].split(");new")[0]
    item_info = "[" + item_info + "]"
    item_info = item_info.gsub("null", "nil")
    # item_info = item_info.gsub("You\"", "You'")
    # item_info = item_info.gsub(/[A-Za-z0-9]\"s/, "'s")
    item_info = eval(item_info)
    item_info_hash = Hash.new
    item_info.each do |info|
      if info.kind_of? Array
        item_info_hash[info[0]] = info
      end
    end

    image_array = Array.new

    begin
      if item_info_hash["ebay.viewItem.PicturePanel"].present?
        list_image = item_info_hash["ebay.viewItem.PicturePanel"][2][:fsImgList]

        list_image.each do |image|
          image_hash = {
            thumbnail: image[:thumbImgUrl],
            big_pic: image[:displayImgUrl]
          }
          image_array.push image_hash
        end
      end
    rescue Exception => e
      puts ("Has an exception")
    end

    variant_properties = Array.new
    options = Array.new
    variants = Array.new
    item_price = nil
    item_inventory = nil
    item_sold = nil
    begin
      if item_info_hash["com.ebay.raptor.vi.msku.ItemVariations"].present?
        list_variant_info = item_info_hash["com.ebay.raptor.vi.msku.ItemVariations"][2][:itmVarModel]
        image_variant = list_variant_info[:menuItemPictureIndexMap]

        image_variant_hash = Hash.new
        image_variant.each do |key, value|
          image_variant_hash[key] = image_array[value[0]][:big_pic]
        end

        list_variant_info[:menuModels].each do |menu|
          options.push menu[:name]
        end

        list_variant_info[:menuItemMap].each do |key, value|
          variant_property = {
            name: value[:displayName]
          }
          if image_variant_hash[key].present?
            variant_property[:image_url] = image_variant_hash[key]
          end
          variant_properties.push variant_property
        end

        list_variant_info[:itemVariationsMap].each do |key, value|
          variant = {
            ebay_variant_id: value[:variationId],
            price: value[:price],
            quantity_sold: value[:quantitySold],
            inventory: value[:quantityAvailable]
          }
          properties = Hash.new
          value[:traitValuesMap].each do |key_prop, value_prop|
            properties[key_prop] = variant_properties[value_prop][:name]
            if variant_properties[value_prop][:image_url].present?
              variant[:image_url] = variant_properties[value_prop][:image_url]
            end
          end
          unless variant[:image_url].present?
            variant[:image_url] = image_array.first[:big_pic]
          end
          variants.push variant
        end
      elsif item_info_hash["raptor.vi.ActionPanel"].present?
        item_price = item_info_hash["raptor.vi.ActionPanel"][2][:isModel][:binPrice]
        item_inventory = item_info_hash["raptor.vi.ActionPanel"][2][:isModel][:remainQty]
        item_sold = item_info_hash["raptor.vi.ActionPanel"][2][:isModel][:qtyPurchased]
      end
    rescue Exception => e
      puts ("Has an exception")
    end

    supplier = ""
    begin
      if item_info_hash["follow/widget"]
        supplier = item_info_hash["follow/widget"][2][:entityName]
      end
    rescue Exception => e
      puts ("Has an exception")
    end

    item = {
      title: title,
      itemCondition: itemCondition,
      link_product: url,
      source: "Ebay",
      options: options,
      images: image_array,
      supplier: supplier,
      variants: variants
    }
    if item_price.present?
      item[:price] = item_price
      item[:inventory] = item_inventory
      item[:quantity_sold] = item_sold
    end

    data = {
      id: 1,
      name: "test"
    }

    solr_url = "http://localhost:8983/solr/gettingstarted/update/json/docs"
    response = post_https_request solr_url, item.to_json

    render html: response.inspect
  end
end
