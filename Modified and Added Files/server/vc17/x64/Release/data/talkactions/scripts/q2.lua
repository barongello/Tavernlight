-- Suppose the following tables:
--
-- rd_players
--     id   AUTO INCREMENT
--     name VARCHAR(45)
--
-- rd_guilds
--     id   AUTO INCREMENT
--     name VARCHAR(45)
--
-- rd_players_guilds
--     player_id    INT
--     guild_id     INT
--     fk_player_id ON  player_id = rd_players.id
--     fk_guild_id  ON  guild_id  = rd_guilds.id



-- Configuration
-- If true, it will also returns guild with 0 players in it
local ACCEPT_EMPTY_GUILDS = true



-- Accepts a number as maxMembersCount argument
-- Returns a table with all guilds' name and member count that have less or
-- equal maxMembersCount
function getSmallGuildNames(maxMembersCount)
    -- If we do not want guilds with 0 players (which is probably impossible to
    -- have), it will use INNER JOIN, otherwise it will use LEFT JOIN
    local selectGuildsQuery = [[
        SELECT
           `g`.`name`               AS `guild_name`,
            COUNT(`pg`.`player_id`) AS `members_count`
        FROM
            `rd_guilds` AS `g`
            %s JOIN
                `rd_players_guilds` AS `pg`
            ON
                `pg`.`guild_id` = `g`.`id`
        GROUP BY
            `g`.`id`
        HAVING
            `members_count` <= %d
        ORDER BY
            `members_count` ASC,
            `guild_name`    ASC;
    ]]

    -- Format the query and execute
    local selectGuildsPreparedQuery = string.format(selectGuildsQuery, ACCEPT_EMPTY_GUILDS and 'LEFT' or 'INNER', maxMembersCount)
    local selectGuildsResultId      = db.storeQuery(selectGuildsPreparedQuery)

    -- If empty, return empty
    if selectGuildsResultId == false then
        return {}
    end

    local guildsEntries = {}

    -- Iterate over results and simply push them into returning array
    repeat
        guildName    = result.getString(selectGuildsResultId, 'guild_name')
        membersCount = result.getNumber(selectGuildsResultId, 'members_count')

        local guildEntry = string.format(
            '%s (%d member%s)',
            guildName,
            membersCount,
            membersCount ~= 1 and 's' or ''
        )

        table.insert(guildsEntries, guildEntry)
    until not result.next(selectGuildsResultId)

    -- Free the query results
    result.free(selectGuildsResultId)

    -- Return found guilds
    return guildsEntries
end

-- Process !q2 <max members count> command
-- Always returns false to not echo the command back to the player
function onSay(player, words, param)
    -- Validate param
    if #param == 0 then
        local message = 'Usage: !q2 <max members count>'

        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, message)

        return false
    end

    local maxMembersCount = tonumber(param)

    if maxMembersCount == nil then
        local message = 'The max members count should be a number'

        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, message)

        return false
    end

    local minAcceptedMembersCount = ACCEPT_EMPTY_GUILDS and 0 or 1

    if maxMembersCount < minAcceptedMembersCount then
        local message = string.format(
            'The max members count should be greater or equal than %d',
            minAcceptedMembersCount
        )

        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, message)

        return false
    end

    -- Retrieve all guilds with <= maxMembersCount
    local guildsEntries = getSmallGuildNames(maxMembersCount)

    -- If no results, inform player
    if #guildsEntries == 0 then
        local message = 'No guilds were found'

        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, message)

        return false
    end

    -- Format the response to the player and send it
    local messageTitle = string.format(
        'There %s %d guild%s with %d member%s or less:\n',
        #guildsEntries ~= 1 and 'are' or 'is',
        #guildsEntries,
        #guildsEntries ~= 1 and 's' or '',
        maxMembersCount,
        maxMembersCount ~= 1 and 's' or ''
    )

    local messageBody = table.concat(guildsEntries, '\n')
    local message = messageTitle .. messageBody

    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, message)

    return false
end
