// Add item by ID to player by name
void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
    // Get player by name
    Player* player = g_game.getPlayerByName(recipient);

    // If can't find the player, try to load it from database
    if (!player) {
        player = new Player(nullptr);

        if (!IOLoginData::loadPlayerByName(player, recipient)) {
            delete player;

            return;
        }
    }

    // Create item by ID
    Item* item = Item::CreateItem(itemId);

    if (!item) {
        delete player;

        return;
    }

    // Send item to player's inbox
    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

    // If player is offline, save it
    if (player->isOffline()) {
        IOLoginData::savePlayer(player);
    }

    // Clean up
    delete item;
    delete player;
}
