local bonfire = require("mmm-2020-main\\bonfire\\main")

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

local function dispCellChange(e)
    -- print(e.previousCell)
    -- print(e.cell)
    -- if (e.previousCell) then
    --     print(tes3.getJournalIndex {id = 'AA_StormWatch'})
    --     if (e.previousCell.id == 'AA_EK lab' and tes3.getJournalIndex {id = 'AA_StormWatch'} == 10) then
    --         print('test')
    --         removeAgentFadeOut(e.cell)
    --     end
    -- end
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
    -- removePlayerInventory()
end

local function init()
    print('===========')
    print('AA MAIN BEGIN...')
    event.register('cellChanged', dispCellChange)
    event.register('simulate', dispUpdate)
    print('AA MAIN SUCCESS')
    print('==========')

    bonfire.init()
end

event.register('initialized', init)
