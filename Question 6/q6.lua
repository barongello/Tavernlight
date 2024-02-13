-- Configurations
local EFFECT_STEPS = 5



-- References
local q6Button = nil



-- Events
local toggleEvent = nil



-- Run on game start
function online()
    -- If can find the toggle button, show it
    if q6Button ~= nil then
        q6Button:show()
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
    q6Button = modules.client_topmenu.addRightGameToggleButton('q6Button', tr('Q6'), '/images/topbuttons/q6', toggle)

    -- If can find the toggle button, set it off
    if q6Button ~= nil then
        q6Button:setOn(false)
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

    -- Destroy trigger button
    if q6Button ~= nil then
        q6Button:destroy()

        q6Button = nil
    end
end

-- Toggle function of the trigger button
function toggle()
    -- If q6Button is not found, this should not have been called
    if q6Button == nil then
        return
    end

    -- If the toggle state is on, reset the effect. Otherwise, start it
    if q6Button:isOn() then
        resetEffect()
    else
        startEffect()
    end
end

-- Start effect and toggle on
function startEffect()
    -- If can't get the map, nothing to do
    local map = modules.game_interface.getMapPanel()

    if map == nil then
        return
    end

    -- If can't get the player, nothing to do
    local player = g_game:getLocalPlayer()

    if player == nil then
        return
    end

    -- Get player's actual position as target position and player direction
    local position  = player:getPosition()
    local direction = player:getDirection()

    -- Modify target position based on player's direction
    -- 0 - North
    -- 1 - East
    -- 2 - South
    -- 3 - West
    if direction == 0 then
        position.y = position.y - EFFECT_STEPS
    elseif direction == 1 then
        position.x = position.x + EFFECT_STEPS
    elseif direction == 2 then
        position.y = position.y + EFFECT_STEPS
    elseif direction == 3 then
        position.x = position.x - EFFECT_STEPS
    end

    -- Disable player walking animation
    player:setDisableWalkAnimation(true)

    -- Make player auto walk to the target position
    player:autoWalk(position)

    -- Set the dash shader for the map
    map:setShader('Map - Question 6')

    -- Set the outline shader for the player
    player:setShader('Outfit - Question 6')

    -- Get the effect duration
    local duration = player:getStepDuration(true, direction) * EFFECT_STEPS

    -- Schedule an event to stop the effect
    toggleEvent = scheduleEvent(resetEffect, duration)

    -- If can find the q6Button, toggle it on
    if q6Button ~= nil then
        q6Button:setOn(true)
    end
end

-- Toggle off and stop effect
function resetEffect()
    -- If the toggleEvent is going on, remove it
    if toggleEvent ~= nil then
        removeEvent(toggleEvent)

        toggleEvent = nil
    end

    -- If can get the map, reset the shader
    local map = modules.game_interface.getMapPanel()

    if map ~= nil then
        map:setShader('Map - Default')
    end

    -- If can get the player, reset the shader and re-enable walk animation
    local player = g_game:getLocalPlayer()

    if player ~= nil then
        player:setShader('Outfit - Default')

        player:setDisableWalkAnimation(false)
    end

    -- If can get the q6Button, set its toggle state off
    if q6Button ~= nil then
        q6Button:setOn(false)
    end
end
