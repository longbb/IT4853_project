class CrawlerController < ApplicationController
  def start
    @un_crawl = Array.new
    un_crawl_product = EbayProduct.where(status: "un_crawl")
    concat_array @un_crawl, un_crawl_product
    @un_crawl.each do |product|
      crawl product.link
      un_crawl_product = EbayProduct.where(status: "un_crawl")
      concat_array @un_crawl, un_crawl_product
    end
  end

  def crawl link
    begin
      product_will_crawl = EbayProduct.where(status: "un_crawl", link: link)
      if product_will_crawl.present?
        url = link
        html = Faraday.new.get(url).body
        doc = Nokogiri::HTML(html)
        title = doc.css("h1#itemTitle").children[1].text
        itemCondition = doc.css("div[itemprop='itemCondition']").text

        description = doc.css("div[class='itemAttr']").css("table")[0].to_html

        item_categories = Array.new
        list_categories = doc.css("a[itemprop='item']").css("span")
        list_categories.each do |category|
          item_categories.push category.text
        end

        item_info = doc.to_s.split("$rwidgets(")[1].split(");new")[0]
        item_info = "[" + item_info + "]"
        item_info = item_info.gsub("null", "nil")
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

            variant = {
              price: item_price,
              quantity_sold: item_sold,
              inventory: item_inventory,
              image_url: image_array.first[:big_pic]
            }
            variants.push variant
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
          itemCategories: item_categories,
          itemCondition: itemCondition,
          description: description,
          link_product: url,
          source: "Ebay",
          options: options,
          images: image_array,
          supplier: supplier,
          variants: variants
        }

        other_products = doc.css("a[class='mfe-reco-link']")
        other_products.each do |product|
          product_exist = EbayProduct.find_by(link: product["href"])
          unless  product_exist.present?
            EbayProduct.create(link: product["href"], status: "un_crawl")
          end
        end

        solr_url = "http://localhost:8983/solr/ebay_production/update/json/docs"
        response = post_https_request solr_url, item.to_json

        product_will_crawl.update(status: "crawled")

        sleep 2
      end
    rescue Exception => e
      puts ("Has an exception")
    end
  end
end
