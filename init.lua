local request = require 'http.request'
local util = require 'http.util'
local json = require('rapidjson')

local endpoints = json.decode(require('nekos-lua-cqueues.endpoints'))

local base = 'https://nekos.life/api/v2'
local client = {}

for category, value in pairs(endpoints) do
  client[category] = {}
  for name, path in pairs(value) do
    client[category][name] = function(params)
      local encoded_params = params and ('?' .. util.dict_to_query(params)) or ''
      local req = request.new_from_uri(base..path..encoded_params)

      local headers, stream = req:go()
      if not headers then return nil, stream end

      local body, err = stream:get_body_as_string()
      if not body then return nil, err end

      if headers:get ':status' ~= '200' then return nil, json.decode(body) end

      return json.decode(body)
    end
  end
end

return client