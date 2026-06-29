local RestWhenInjured = radiant.class()
RestWhenInjured.name = 'rest when injured'
RestWhenInjured.does = 'stonehearth:rest_when_injured'
RestWhenInjured.args = {}
RestWhenInjured.priority = {0, 1}

local function _get_injured_percentage(entity)
   local job = entity:get_component('stonehearth:job')
   local job_info = job and job:get_job_info()
   if job_info and job_info:is_combat_job() then
      return stonehearth.constants.health.COMBAT_REST_WHEN_INJURED_PERCENTAGE
   end

   return stonehearth.constants.health.REST_WHEN_INJURED_PERCENTAGE
end

function RestWhenInjured:start_thinking(ai, entity, args)
   local injured_percentage = _get_injured_percentage(entity)
   self._injured_percentage = injured_percentage
   ai:set_think_output({
      injured_percentage = injured_percentage
   })
end

function RestWhenInjured:compose_utility(entity, self_utility, child_utilities, current_activity)
   local injured_percentage = self._injured_percentage or _get_injured_percentage(entity)
   if not injured_percentage or injured_percentage <= 0 then
      injured_percentage = stonehearth.constants.health.REST_WHEN_INJURED_PERCENTAGE
   end

   return 1.0 - child_utilities:get(0) / injured_percentage
end

local ai = stonehearth.ai
return ai:create_compound_action(RestWhenInjured)
            :execute('stonehearth:abort_on_event_triggered', {
               source = ai.ENTITY,
               event_name = 'stonehearth:job_changed',
            })
            :execute('stonehearth:wait_for_expendable_resource_below_percentage', {
                  resource_name = 'health',
                  percentage = ai.BACK(2).injured_percentage
               })
            :execute('stonehearth:rest_from_injuries')
