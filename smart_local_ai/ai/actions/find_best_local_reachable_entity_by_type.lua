local Entity = _radiant.om.Entity
local FindBestLocalReachableEntityByType = radiant.class()

FindBestLocalReachableEntityByType.name = 'find best local reachable entity by type'
FindBestLocalReachableEntityByType.does = 'smart_local_ai:find_best_local_reachable_entity_by_type'
FindBestLocalReachableEntityByType.args = {
   filter_fn = 'function',
   rating_fn = {
      type = 'function',
      default = stonehearth.ai.NIL,
   },
   description = 'string',
   ignore_leases = {
      default = false,
      type = 'boolean'
   },
   max_items_to_examine = {
      default = 200,
      type = 'number'
   },
   owner_player_id = {
      type = 'string',
      default = stonehearth.ai.NIL,
   },
}
FindBestLocalReachableEntityByType.think_output = {
   item = Entity,
   rating = 'number',
}
FindBestLocalReachableEntityByType.priority = {0, 1}

local log = radiant.log.create_logger('smart_local_ai')

local DEFAULT_SETTINGS = {
   local_radius = 32,
   expanded_radius = 64,
   global_fallback = true,
   debug_enabled = false,
   enable_for_hauling = true,
   enable_for_fetching = true,
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

local function _build_stages(settings)
   if not settings.enable_for_hauling and not settings.enable_for_fetching then
      return {
         { label = 'fallback', max_distance = nil }
      }
   end

   local stages = {}
   local local_radius = tonumber(settings.local_radius)
   local expanded_radius = tonumber(settings.expanded_radius)

   if local_radius and local_radius > 0 then
      table.insert(stages, {
         label = 'local',
         max_distance = local_radius,
      })
   end

   if expanded_radius and expanded_radius > 0 and expanded_radius ~= local_radius then
      table.insert(stages, {
         label = 'expanded',
         max_distance = expanded_radius,
      })
   end

   if settings.global_fallback or #stages == 0 then
      table.insert(stages, {
         label = 'fallback',
         max_distance = nil,
      })
   end

   return stages
end

function FindBestLocalReachableEntityByType:start_thinking(ai, entity, args)
   assert(args.filter_fn)

   self._ai = ai
   self._description = args.description
   self._log = log
   self._ready = false
   self._result = nil
   self._started = false
   self._location = ai.CURRENT.location
   self._items_examined = 0
   self._settings = _load_settings()
   self._stages = _build_stages(self._settings)
   self._stage_index = 0
   self._if = nil
   self._delay_start_timer = nil
   self._best_item = nil
   self._best_rating = 0

   if not self._location then
      ai:set_debug_progress('entity has no location')
      return
   end

   self:_start_next_stage(entity, args)
end

function FindBestLocalReachableEntityByType:_start_next_stage(entity, args)
   self._stage_index = self._stage_index + 1
   local stage = self._stages[self._stage_index]

   if not stage then
      self._ai:set_debug_progress('exhausted with no results')
      return
   end

   self._best_item = nil
   self._best_rating = 0

   if self._settings.debug_enabled then
      self._log:debug('%s starting %s search (%s)', tostring(entity), stage.label, tostring(stage.max_distance))
   end

   local exhausted = function()
      if self._if then
         self._if:destroy()
         self._if = nil
      end

      if self._best_item then
         self:_set_result(self._best_item, self._best_rating, args)
      else
         self:_start_next_stage(entity, args)
      end
   end

   local consider = function(item)
      if not self._ai.CURRENT or self._ai.CURRENT.self_reserved[item:get_id()] then
         return false
      end

      self._items_examined = self._items_examined + 1
      if self._items_examined > args.max_items_to_examine then
         exhausted()
         return true
      end

      local rating = args.rating_fn and math.min(1.0, args.rating_fn(item, entity)) or 1
      if not self._best_item or rating > self._best_rating then
         self._best_item = item
         self._best_rating = rating
         if rating == 1.0 then
            self:_set_result(item, rating, args)
            return true
         end
      end

      return false
   end

   self._delay_start_timer = radiant.on_game_loop_once('SmartLocalAI start local reachable search', function()
         local options = {
            description = string.format('%s (%s)', self._description, stage.label),
            ignore_leases = args.ignore_leases,
            exhausted_cb = exhausted,
            reappraise_cb = consider,
            owner_player_id = args.owner_player_id,
            should_sort = false,
         }

         if stage.max_distance then
            options.max_distance = stage.max_distance
         end

         self._if = entity:add_component('stonehearth:item_finder'):find_reachable_entity_type(
               self._location,
               args.filter_fn,
               consider,
               options)
      end)
end

function FindBestLocalReachableEntityByType:start(ai, entity, args)
   if not radiant.entities.exists(self._result) or not args.filter_fn(self._result) then
      ai:abort(string.format('destination %s is no longer valid at start. filter description: %s', tostring(self._result), tostring(self._description)))
   end

   if not radiant.entities.exists_in_world(self._result) then
      ai:abort(string.format('destination %s is no longer in world.', tostring(self._result)))
   end

   self._started = true
end

function FindBestLocalReachableEntityByType:stop_thinking(ai, entity, args)
   if self._delay_start_timer then
      self._delay_start_timer:destroy()
      self._delay_start_timer = nil
   end

   if self._if then
      self._if:destroy()
      self._if = nil
   end
end

function FindBestLocalReachableEntityByType:stop(ai, entity, args)
   self:stop_thinking(ai, entity, args)
end

function FindBestLocalReachableEntityByType:_set_result(item, rating, args)
   if self._started then
      return
   end

   self._result = item
   self._ready = true
   self._ai:set_think_output({ item = item, rating = rating })
   if args.rating_fn then
      self._ai:set_utility(rating)
   end

   if self._settings.debug_enabled then
      self._log:debug('selected %s rating=%s', tostring(item), tostring(rating))
   end
end

return FindBestLocalReachableEntityByType
