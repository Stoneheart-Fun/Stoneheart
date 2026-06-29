local SmartLocalAiRestockDirectorPatch = require 'monkey_patches.smart_local_ai_restock_director'
local RestockDirector = radiant.mods.require('stonehearth.services.server.inventory.restock_director')
local settings = radiant.resources.load_json('smart_local_ai:data:settings', true, false) or {}

SmartLocalAiRestockDirectorPatch._ace_old__get_max_errands = RestockDirector._get_max_errands
radiant.mixin(RestockDirector, SmartLocalAiRestockDirectorPatch)

local mode = settings.disable_restock_errands and 'restock disabled' or 'restock throttle active'
radiant.log.write_('smart_local_ai', 0, 'Smart Local AI server patch loaded: ' .. mode)
