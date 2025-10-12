local addonName, addonTable = ...
local LSM = LibStub("LibSharedMedia-3.0")

-- Media types
local SOUND = LSM.MediaType.SOUND
local FONT = LSM.MediaType.FONT

-- Register fonts
LSM:Register(FONT, "Naowh", [[Interface\AddOns\MattSimpleTweaks\Media\Fonts\Naowh.ttf]])

-- Register sounds
-- LSM:Register(SOUND, "MST Alert", [[Interface\AddOns\MattSimpleTweaks\Media\Sounds\Alert.ogg]])

