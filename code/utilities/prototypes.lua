local prototypes = {
  asset_category = {},
}

prototypes.asset_category.prototype = { dir = "assets/", loaded_data = {} }
prototypes.asset_category.mt = {}
prototypes.asset_category.mt.__index = prototypes.asset_category.prototype

function prototypes.asset_category.new(self, o)
  setmetatable(o, prototypes.asset_category.mt)
  return o
end
return prototypes