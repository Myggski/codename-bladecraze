local function manager(super)
    local obj = {
      event_callbacks = {},
    }

    obj.__index = obj
    setmetatable(obj, super)

    function obj.create(...)
        if obj._instance then
            return obj._instance
        end

        local instance = setmetatable({}, obj)
        if instance.ctor then
            instance:ctor(...)
        end

        obj._instance = instance
        return obj._instance
    end

    function obj:add_listener(game_event_type, callback)
      self.event_callbacks[game_event_type] = self.event_callbacks[game_event_type] or {}
      table.insert(self.event_callbacks[game_event_type], callback)
    end

    function obj:remove_listener(game_event_type, callback)
      local event_callback = self.event_callbacks[game_event_type]
      local index = table.index_of(event_callback, callback)

      if (index) then
        table.remove(event_callback, index)
      end
    end

    function obj:invoke(game_event_type, ...)
      local event_callback = self.event_callbacks[game_event_type]
      
      if (event_callback and #event_callback) then
        for index = 1, #event_callback do
          event_callback[index](...)
        end
      end
    end

    return obj
end

return manager().create()
