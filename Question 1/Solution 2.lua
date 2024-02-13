-- If we want to reuse the `releaseStorage` function, then:


-- Release storageId for the given player
-- If storageId is negative here, it will be wrapped in C++ because it is handled as uint32_t. So, let's avoid it
function releaseStorage(player, storageId)
    -- Validate arguments
    if type(player) ~= 'userdata' or type(storageId) ~= 'number' then
        return
    end

    if storageId < 0 then
        return
    end

    -- Release storage's slot
    player:setStorageValue(storageId, -1)
end

function onLogout(player)
    -- If storage 1000 is set to 1, release it
    if player:getStorageValue(1000) == 1 then
        releaseStorage(player, 1000)
    end

    return true
end
