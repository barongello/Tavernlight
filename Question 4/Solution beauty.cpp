// Add item by ID to player by name
void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
    // Get player by name
    std::unique_ptr<Player> pPlayer = std::unique_ptr<Player>(g_game.getPlayerByName(recipient));

    // If can't find the player, try to load it from database
    if (!pPlayer) {
        pPlayer = std::make_unique<Player>(nullptr);

        if (!IOLoginData::loadPlayerByName(pPlayer.get(), recipient)) {
            return;
        }
    }

    // Create item by ID
    std::unique_ptr<Item> pItem = std::unique_ptr<Item>(Item::CreateItem(itemId));

    if (!pItem) {
        return;
    }

    // Send item to player's inbox
    g_game.internalAddItem(pPlayer->getInbox(), pItem.get(), INDEX_WHEREEVER, FLAG_NOLIMIT);

    // If player is offline, save it
    if (pPlayer->isOffline()) {
        IOLoginData::savePlayer(pPlayer.get());
    }
}
