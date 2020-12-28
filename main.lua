local bonfire = require("mmm-2020-main\\bonfire\\main")

local function unbrokenWall()
    tes3.getReference("AA_CellBrick0").disabled = true
    tes3.getReference("AA_CellBrick1").disabled = true
    tes3.getReference("AA_CellBrick2").disabled = true
    tes3.getReference("AA_CellBrick3").disabled = true
    tes3.getReference("AA_CellBrick4").disabled = true
end

local function brokenWall()
    tes3.getReference("AA_CellBrick0").disabled = false
    tes3.getReference("AA_CellBrick1").disabled = false
    tes3.getReference("AA_CellBrick2").disabled = false
    tes3.getReference("AA_CellBrick3").disabled = false
    tes3.getReference("AA_CellBrick4").disabled = false

    tes3.getReference("AA_PlaneWall").disabled = true
    tes3.setGlobal("AA_Escarpe", 2)
end


local function sabotageBalista(ref)
    local balistasSabotaged = tes3.getGlobal("AA_balistasSabotaged")
    if (balistasSabotaged) then
        tes3.setGlobal("AA_balistasSabotaged", balistasSabotaged + 1)
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
        print(item.object.id)
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
