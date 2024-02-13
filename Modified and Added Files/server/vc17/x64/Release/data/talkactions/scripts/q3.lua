-- Configuration
local ASSERT_PARTY_LEADERSHIP = true



-- Remove member with memberName name from player with id playerId party
function removeMemberFromPlayerParty(playerId, memberName)
    -- Get player by ID
    local player = Player(playerId)

    -- If player not found, nothing to do
    if player == nil then
        return
    end

	-- Get the player's party
    local party = player:getParty()

    -- If not in party, nothing to do
    if party == nil then
	    local message = 'You are not in a party'

		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, message)

        return
    end

    -- Get party's leader
    local partyLeader = party:getLeader()

    -- If should assert party's leadership player is not the party's leader,
    -- nothing to do
    if ASSERT_PARTY_LEADERSHIP and partyLeader ~= player then
	    local message = 'Only the party leader can use this command'

		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, message)

        return
    end

    -- Get target member by name
    local targetMember = Player(memberName)

    -- If target member not found, nothing to do
    if targetMember == nil then
	    local message = 'Target player not found'

	    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, message)

        return
    end

    -- A player can't remove itself (design decision)
    if targetMember == player then
	    local message = 'You can\'t remove yourself from party with this command'

		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, message)

        return
    end

    -- Can't remove the party's leader (will only have effect if the ASSERT_PARTY_LEADERSHIP
    -- is false, otherwise it would have already failed in the previous check, since
    -- player == partyLeader at this point when ASSERT_PARTY_LEADERSHIP is true)
    if targetMember == partyLeader then
	    local message = 'You can\'t remove the party leader'

	    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, message)

        return
    end

    -- Check if target member is in party and, if it is, remove it
    for _, partyMember in pairs(party:getMembers()) do
        if partyMember == targetMember then
            party:removeMember(targetMember)

            return
        end
    end

    -- This will only execute if the target member is a valid player in the server
    -- but is not in the party of the command issuer
    local message = 'Target player is not in your party'

    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, message)
end

-- Process !q3 <member name> command
-- Always returns false to not echo the command back to the player
function onSay(player, words, param)
    -- Check if the command has the needed argument
    if #param == 0 then
        local message = 'Usage: !q3 <member name>'

        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, message)

        return false
    end

    -- Get the ID of the issuing player
    local playerId = player:getId()

    -- Get the player object for the player that has name equals to the
    -- command's argument
    local targetMember = Player(param)

    -- Check if player exists
    if targetMember == nil then
        local message = 'Target player not found'

        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, message)

        return false
    end

    -- Get the member name from the player's object
    local memberName = targetMember:getName()

    -- Try to remove the member from party
    removeMemberFromPlayerParty(playerId, memberName)

    return false
end
