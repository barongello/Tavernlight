-- Configurations
local EFFECT_DURATION = 5000



-- References
local q5Button = nil



-- Events
local toggleEvent = nil



-- Run on game start
function online()
    -- If can find the toggle button, show it
    if qButton ~= nil then
        q5Button:show()
    end
end

-- Run on game end
function offline()
    resetEffect()
end

-- Module initialization on load
function init()
    -- Connect the signals/callbacks
    connect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })

    -- Create the trigger button, get its reference and set it as not toggled
    q5Button = modules.client_topmenu.addRightGameToggleButton('q5Button', tr('Q5'), '/images/topbuttons/q5', toggle)

    -- If can find the toggle button, set it to off
    if q5Button ~= nil then
        q5Button:setOn(false)
    end

    -- If initialized after game started, call the callback manually
    if g_game.isOnline() then
        online()
    end
end

-- Module termination on unload
function terminate()
    -- Remove the signals/callbacks
    disconnect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })

    -- Reset the effect
    resetEffect()

    -- If can find the toggle button, destroy it
    if q5Button ~= nil then
        q5Button:destroy()

        q5Button = nil
    end
end

-- Toggle function of the trigger button
function toggle()
    -- If q5Button is not found, this should not have been called
    if q5Button == nil then
        return
    end

    -- If the toggle state is on, reset the effect. Otherwise, start it
    if q5Button:isOn() then
        resetEffect()
    else
        startEffect()
    end
end

-- Start effect and toggle button on
function startEffect()
    -- If can't find the map, nothing to do
    local map = modules.game_interface.getMapPanel()

    if map == nil then
        return
    end

    -- Set map shader
    map:setShader('Map - Question 5')

    -- Schedule an event to stop the effect
    toggleEvent = scheduleEvent(resetEffect, EFFECT_DURATION)

    -- If can find the toggle button, toggle it on
    if q5Button ~= nil then
        q5Button:setOn(true)
    end
end

-- Stop effect and toggle button off
function resetEffect()
    -- If there is a scheduled event, remove it
    if toggleEvent ~= nil then
        removeEvent(toggleEvent)

        toggleEvent = nil
    end

    -- If can find map, reset map shader
    local map = modules.game_interface.getMapPanel()

    if map ~= nil then
        map:setShader('Map - Default')
    end

    -- If can find toggle button, set it off
    if q5Button ~= nil then
        q5Button:setOn(false)
    end
end
