local FillBackpackFromItems = radiant.class()

FillBackpackFromItems.name = 'fill backpack from items'
FillBackpackFromItems.does = 'stonehearth:fill_backpack_from_items'
FillBackpackFromItems.args = {
   candidates = 'table',
   range = {
      type = 'number',
      default = 32,
   },
   storage = _radiant.om.Entity,
   owner_player_id = {
      type = 'string',
      default = stonehearth.ai.NIL,
   },
   reserve_space = {
      type = 'boolean',
      default = true,
   },
   max_items = {
      type = 'number',
      default = stonehearth.ai.NIL,
   },
   filter_fn = {
      type = 'function',
      default = stonehearth.ai.NIL,
   },
}
FillBackpackFromItems.priority = 0

local DEFAULT_SETTINGS = {
   local_radius = 32,
   enable_for_restocking = true,
}

local function _load_settings()
   local settings = radiant.resources.load_json('smart_local_ai:data:settings', true, false) or {}
   local merged = {}
   for key, value in pairs(DEFAULT_SETTINGS) do
      merged[key] = settings[key]
      if merged[key] == nil then
         merged[key] = value
      end
   end
   return merged
end

function FillBackpackFromItems:start_thinking(ai, entity, args)
end

local function _get_effective_range(range)
   local settings = _load_settings()
   if settings.enable_for_restocking then
      local local_radius = tonumber(settings.local_radius)
      if local_radius and local_radius > 0 then
         range = math.min(range, local_radius)
      end
   end
   return range
end

local ai = stonehearth.ai
local action = ai:create_compound_action(FillBackpackFromItems)

for i = 1, stonehearth.constants.backpack.MAX_CAPACITY - 1 do
   action:execute('stonehearth:put_another_restockable_item_into_backpack', {
         range = ai.CALL(_get_effective_range, ai.ARGS.range),
         candidates = ai.ARGS.candidates,
         storage = ai.ARGS.storage,
         owner_player_id = ai.ARGS.owner_player_id,
         reserve_space = ai.ARGS.reserve_space,
         max_items = ai.ARGS.max_items,
         filter_fn = ai.ARGS.filter_fn
      })
end

return action
