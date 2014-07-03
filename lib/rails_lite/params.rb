require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = {}
    @permitted_keys = []

    if req.query_string
      @params.merge!(parse_www_encoded_form(req.query_string))
    end
    if req.body
      @params.merge!(parse_www_encoded_form(req.body))
    end
    @params.merge!(route_params)
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    # @selected = @params.select { |key, val| keys.include?(key) }
    @permitted_keys += keys
  end

  def require(key)
    raise AttributeNotFoundError.new unless @params.keys.include?(key)
  end

  def permitted?(key)
    # @selected.keys.include?(key)
    @permitted_keys.include?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    key_val_pairs = URI.decode_www_form(www_encoded_form)
    main_hash = {}
    key_val_pairs.each do |pair|
      array_of_keys = parse_key(pair[0])
      current_hash = main_hash
      array_of_keys.each_with_index do |key, index|
        if index == array_of_keys.length - 1
          current_hash[key] = pair[1]
        else
          current_hash[key] ||= {}
          current_hash = current_hash[key]
        end
      end
    end

    main_hash
  end


  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.gsub("]", "").split("[")
  end
end
