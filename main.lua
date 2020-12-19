local bonfire = require("mmm-2020-main\\bonfire\\main")

local function disp11()
    local o = tes3.getReference('AA_agent')
    if (string.startswith(o.id, 'AA_agent')) then
        mwscript.positionCell {reference = o, cell = 'Toddtest'}
        tes3.fadeIn {duration = 1.0}
        tes3.updateJournal {id = 'AA_StormWatch', index = 12, showMessage = false}
    end
end

local function disp10()
    tes3.fadeOut {duration = 1.0}
    tes3.updateJournal {id = 'AA_StormWatch', index = 11, showMessage = false}
    timer.start {type = timer.simulate, iterations = 1, duration = 1, callback = disp11}
end

local function dispCellChange(e)
    -- print(e.previousCell)
    -- print(e.cell)
    -- if (e.previousCell) then
    --     print(tes3.getJournalIndex {id = 'AA_StormWatch'})
    --     if (e.previousCell.id == 'AA_EK lab' and tes3.getJournalIndex {id = 'AA_StormWatch'} == 10) then
    --         print('test')
    --         disp10(e.cell)
    --     end
    -- end
end

local function dispUpdate(e)
    print(tes3.getJournalIndex {id = 'AA_StormWatch'})
    if (tes3.getPlayerCell().id == 'AA_EK lab' and tes3.getJournalIndex {id = 'AA_StormWatch'} == 10) then
        print('test')
        disp10()
    end
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
