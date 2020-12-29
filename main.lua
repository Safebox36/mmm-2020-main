local bonfire = require("mmm-2020-main\\bonfire\\main")

local function freePrisonersFadeIn()
    local captive1 = tes3.getReference("AA_hostage01")
    local captive2 = tes3.getReference("AA_hostage02")
    local captive3 = tes3.getReference("AA_hostage03")
    local warden = tes3.getReference("AA_warden")
    local player = tes3.player
    captive1.position = captive1.position + captive1.sceneNode.rotation:transpose().y * 128
    captive2.position = captive2.position + captive2.sceneNode.rotation:transpose().y * 128
    captive3.position = captive3.position + captive3.sceneNode.rotation:transpose().y * 128
    warden.position = warden.position + warden.sceneNode.rotation:transpose().y * 128
    player.position = player.position - player.sceneNode.rotation:transpose().y * 128
    tes3.fadeIn {duration = 1.0}
    tes3.updateJournal {id = 'AA_Stormwatch_Hostages', index = 7, showMessage = false}
end

local function freePrisonersFadeOut()
    tes3.fadeOut {duration = 1.0}
    tes3.updateJournal {id = 'AA_Stormwatch_Hostages', index = 6, showMessage = false}
    timer.start {type = timer.simulate, iterations = 1, duration = 1, callback = freePrisonersFadeIn}
end

local function unbrokenWall()
    tes3.getReference("AA_CellBrick0"):disable()
    tes3.getReference("AA_CellBrick1"):disable()
    tes3.getReference("AA_CellBrick2"):disable()
    tes3.getReference("AA_CellBrick3"):disable()
    tes3.getReference("AA_CellBrick4"):disable()
end

local function brokenWall()
    tes3.getReference("AA_CellBrick0"):enable()
    tes3.getReference("AA_CellBrick1"):enable()
    tes3.getReference("AA_CellBrick2"):enable()
    tes3.getReference("AA_CellBrick3"):enable()
    tes3.getReference("AA_CellBrick4"):enable()

    tes3.getReference("AA_PlaneWall"):disable()
    tes3.setGlobal("AA_Escarpe", 2)
end

local function sabotageBalista(ref)
    local balistasSabotaged = tes3.getGlobal("AA_balistasSabotaged")
    if (balistasSabotaged) then
        tes3.setGlobal("AA_balistasSabotaged", balistasSabotaged + 1)
        balistasSabotaged = tes3.getGlobal("AA_balistasSabotaged")
    end
    if (balistasSabotaged < 10) then
        tes3.messageBox{
            message = "You have sabotaged a ballista, there are still " .. tostring(10 - tes3.getGlobal("AA_balistasSabotaged")) .. " to go."
        }
    else
        tes3.messageBox{
            message = "You have sabotaged all the ballistas."
        }
        tes3.updateJournal{id = 'AA_Stormwatch_Defenses', index = 5, showMessage = true}
    end
    if (ref.data.aa_sabotaged == nil) then
        ref.data.aa_sabotaged = true
    end
end

local function removePlayerInventory()
    local inv = tes3.player.object.inventory
    for item in tes3.iterate(inv) do
		tes3.transferItem({
			from = tes3.player,
			to = tes3.getReference("AA_GuardChest"),
			item = item.object,
			playSound = false,
			count = math.abs(item.count),
			updateGUI = false,
		})
	end
    tes3.updateJournal {id = 'AA_Stormwatch_Cult', index = 6, showMessage = false}
end

local function removeAgentFadeIn()
    local o = tes3.getReference('AA_agent')
    if (string.startswith(o.id, 'AA_agent')) then
        mwscript.positionCell {reference = o, cell = 'Toddtest'}
        tes3.fadeIn {duration = 1.0}
        tes3.updateJournal {id = 'AA_StormWatch', index = 12, showMessage = false}
    end
end

local function removeAgentFadeOut()
    tes3.fadeOut {duration = 1.0}
    tes3.updateJournal {id = 'AA_StormWatch', index = 11, showMessage = false}
    timer.start {type = timer.simulate, iterations = 1, duration = 1, callback = removeAgentFadeIn}
end

local function dispActivate(e)
    if (e.activator == tes3.player) then
        if (e.target.baseObject.id == "TS_RM_Ballister" and tes3.getJournalIndex {id = 'AA_Stormwatch_Defenses'} < 5) then
            if (e.target.data.aa_sabotaged == nil) then
                sabotageBalista(e.target)
            else
                tes3.messageBox{
                    message = "You have already sabotaged this ballista, there are still " .. tostring(10 - tes3.getGlobal("AA_balistasSabotaged")) .. " to go."
                }
            end
        end
        if (e.target.baseObject.id == "TS_dr_dung_cage_03" and tes3.getJournalIndex {id = 'AA_Stormwatch_Hostages'} == 5) then
            freePrisonersFadeOut()
        end
        if (e.target.baseObject.id == "AA_Lever") then
            local gate = tes3.getReference("TS_ex_gg_portcullis_1")
            print(e.target.orientation.x)
            print(math.abs(e.target.orientation.x))
            print(math.rad(45) - e.target.orientation.x)
            print(math.rad(-45) - e.target.orientation.x)
            if (math.rad(45) - e.target.orientation.x < 1) then
                gate.position = {gate.position.x, gate.position.y, 992.527}
                e.target.orientation = {math.rad(-45), e.target.orientation.y, e.target.orientation.z}
            elseif (math.rad(-45) - e.target.orientation.x < 1) then
                gate.position = {gate.position.x, gate.position.y, 992.527 + 300}
                e.target.orientation = {math.rad(45), e.target.orientation.y, e.target.orientation.z}
            end
        end
    end
end

local function dispUpdate(e)
    -- print(tes3.getJournalIndex {id = 'AA_StormWatch'})
    if (tes3.getPlayerCell().id == 'Balmora, Caius Cosades\' House' and tes3.getJournalIndex {id = 'AA_StormWatch'} == 10) then
        -- print('test')
        removeAgentFadeOut()
    end
    if (tes3.getPlayerCell().id == 'A8_Fort Stormwatch, Basement' and tes3.getJournalIndex {id = 'AA_Stormwatch_Cult'} == 5) then
        -- print('test')
        removePlayerInventory()
    end
    if (tes3.getPlayerCell().id == "A8_Fort Stormwatch, Basement") then
        if (tes3.getGlobal("AA_Escarpe") == 0) then
            unbrokenWall()
        elseif (tes3.getGlobal("AA_Escarpe") == 1) then
            brokenWall()
        elseif (tes3.getGlobal("AA_Escarpe") == 2) then
            if (tes3.getGlobal("AA_chest") == 1 and tes3.getJournalIndex {id = 'AA_Stormwatch_Cult'} == 5) then
                tes3.updateJournal {id = 'AA_Stormwatch_Cult', index = 10, showMessage = true}
            end
        end
    end
end

local function init()
    print('===========')
    print('AA MAIN BEGIN...')
    event.register('activate', dispActivate)
    event.register('simulate', dispUpdate)
    print('AA MAIN SUCCESS')
    print('==========')

    bonfire.init()
end

event.register('initialized', init)
