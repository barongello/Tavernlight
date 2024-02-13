-- If we do not want to reuse the `releaseStorage` function, then:

function onLogout(player)
    -- If storage 1000 is set to 1, release it
    if player:getStorageValue(1000) == 1 then
        player:setStorageValue(1000, -1)
    end

    return true
end
