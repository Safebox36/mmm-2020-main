local bonfire = require("mmm-2020-main\\bonfire\\main")

local function courtyard1(params)
    timer.start {type = timer.simulate, iterations = 1, duration = 13, callback = courtyard1}
end

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
end

local function freePrisonersFadeOut(ref)
    tes3.fadeOut {duration = 1.0}
    tes3.playSound{sound = "Door Metal Open", reference = ref}
    tes3.setGlobal("AA_CaptivesFreed", 1)
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
        tes3.playSound{sound = "LockedChest", reference = ref}
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
    tes3.setGlobal("AA_InventoryRemoved", 1)
end

local function hideAgent()
    local o = tes3.getReference('AA_agent')
    if (string.startswith(o.id, 'AA_agent')) then
        o:disable()
    end
end

local function showAgent()
    local o = tes3.getReference('AA_agent')
    if (string.startswith(o.id, 'AA_agent')) then
        o:enable()
    end
end

local function dispActivate(e)
    if (e.activator == tes3.player) then
        if (e.target.baseObject.id == "TS_RM_Ballister" and tes3.getJournalIndex {id = 'AA_Stormwatch_Defenses'} == 1) then
            if (e.target.data.aa_sabotaged == nil) then
                sabotageBalista(e.target)
            else
                tes3.messageBox{
                    message = "You have already sabotaged this ballista, there are still " .. tostring(10 - tes3.getGlobal("AA_balistasSabotaged")) .. " to go."
                }
            end
        end
        if (e.target.baseObject.id == "TS_dr_dung_cage_03" and tes3.getJournalIndex {id = 'AA_Stormwatch_Hostages'} == 5 and tes3.getGlobal("AA_CaptivesFreed") == 0) then
            freePrisonersFadeOut(e.target)
        end
        if (e.target.baseObject.id == "AA_Lever" and tes3.getJournalIndex {id = 'AA_Stormwatch_Defenses'} == 5) then
            local gate = tes3.getReference("TS_ex_gg_portcullis_1")
            gate.position = {gate.position.x, gate.position.y, 992.527 + 300}
            e.target.orientation = {math.rad(45), e.target.orientation.y, e.target.orientation.z}
            tes3.updateJournal {id = 'AA_Stormwatch_Defenses', index = 10, showMessage = true}
        end
    end
end

local function dispUpdate(e)
    -- print(tes3.getJournalIndex {id = 'AA_StormWatch'})
    if (tes3.getPlayerCell().id == 'Balmora, Caius Cosades\' House' and tes3.getJournalIndex {id = 'A2_6_Incarnate'} < 50) then
        hideAgent()
    elseif (tes3.getPlayerCell().id == 'Balmora, Caius Cosades\' House' and tes3.getJournalIndex {id = 'A2_6_Incarnate'} >= 50) then
        showAgent()
    end
    if (tes3.getPlayerCell().id == 'A8_Fort Stormwatch, Basement' and tes3.getJournalIndex {id = 'AA_Stormwatch_Cult'} == 5 and tes3.getGlobal("AA_InventoryRemoved") == 0) then
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

local function dispDeath(e)
    if (e.reference ~= tes3.player and e.reference ~= tes3.getReference("AA_Librarian")) then
        if (tes3.getPlayerCell().id == "A5_Fort Stormwatch, Mess Hall") then
            tes3.setGlobal("AA_Enemies_MessHall", tes3.getGlobal("AA_Enemies_MessHall") + 1)
        elseif (tes3.getPlayerCell().id == "A7_Fort Stormwatch, Prison Library") then
            tes3.setGlobal("AA_Enemies_Library", tes3.getGlobal("AA_Enemies_Library") + 1)
        elseif (string.find(e.reference.id, "Supply")) then
            tes3.setGlobal("AA_Enemies_Supply", tes3.getGlobal("AA_Enemies_Supply") + 1)
        end
        if (tes3.getGlobal("AA_AreasLiberated") < 3) then
            if (tes3.getJournalIndex("AA_Stormwatch_Hostages") == 5 and tes3.getGlobal("AA_Enemies_MessHall") + tes3.getGlobal("AA_Enemies_Library") + tes3.getGlobal("AA_Enemies_Supply") == 6 + 9 + 10) then
                tes3.setGlobal("AA_AreasLiberated", 3)
            end
        end
    end
end

local function onAttack(e)
    local shrineOne = (tes3.getPlayerTarget() == tes3.getReference("aa_bloodshrine01") == true)
    local shrineTwo = (tes3.getPlayerTarget() == tes3.getReference("aa_bloodshrine02") == true)
    local shrineThree = (tes3.getPlayerTarget() == tes3.getReference("aa_bloodshrine03") == true)
    local isPlayer = e.mobile.reference == tes3.player
    if isPlayer and shrineOne then
        tes3.setGlobal("aa_bloodshrine_g01", 1)
    elseif isPlayer and shrineTwo then
        tes3.setGlobal("aa_bloodshrine_g02", 1)
    elseif isPlayer and shrineThree then
        tes3.setGlobal("aa_bloodshrine_g03", 1)
    end
    if (tes3.getGlobal("aa_bloodshrine_g01") and tes3.getGlobal("aa_bloodshrine_g02") and tes3.getGlobal("aa_bloodshrine_g03")) then
        tes3.updateJournal {id = 'AA_StormSide_OF', index = 15, showMessage = true}
    end
end

local function onMarksmanHit(e)
    if e.firingReference ~= tes3.player then return end
    if e.target.object.id == "aa_bloodshrine01" then
        tes3.setGlobal("aa_bloodshrine_g01", 1)
    elseif e.target.object.id == "aa_bloodshrine02" then
        tes3.setGlobal("aa_bloodshrine_g02", 1)
    elseif e.target.object.id == "aa_bloodshrine03" then
        tes3.setGlobal("aa_bloodshrine_g03", 1)
    end
    if (tes3.getGlobal("aa_bloodshrine_g01") and tes3.getGlobal("aa_bloodshrine_g02") and tes3.getGlobal("aa_bloodshrine_g03")) then
        tes3.updateJournal {id = 'AA_StormSide_OF', index = 15, showMessage = true}
    end
end

local function dispCellChange(e)
    if (tes3.getGlobal("AA_NoTeleport")) then
        tes3.worldController.flagTeleportingDisabled = true
    else
        tes3.worldController.flagTeleportingDisabled = false
    end
end

local function init()
    print('===========')
    print('AA MAIN BEGIN...')
    event.register('activate', dispActivate)
    event.register('simulate', dispUpdate)
    event.register('death', dispDeath)
    event.register("projectileHitObject", onMarksmanHit)
    event.register("attack", onAttack )
    event.register("cellChanged", dispCellChange)
    print('AA MAIN SUCCESS')
    print('==========')

    -- bonfire.init()
end

event.register('initialized', init)
