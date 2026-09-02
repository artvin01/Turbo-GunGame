#if defined _turbo_gungame_included
 #endinput
#endif
#define _turbo_gungame_included

enum struct TGGPlacementInfo
{
	int rank;
	int client;
	int position;
	bool winner;
}

/**
 * Called when a player wins the game.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void TGG_OnWin(int client)

/**
 * Called when a player ranks up.
 *
 * @param client		Client index.
 * @param ranks			Amount of ranks gained.
 * @noreturn
 */
forward void TGG_OnRankUp(int client, int ranks)

/**
 * Called when a player ranks down.
 *
 * @param client		Client index of the victim.
 * @param attacker		Client index of the attacker.
 * @noreturn
 */
forward void TGG_OnRankDown(int client, int attacker)

/**
 * Gives a list of all participating players with their ranks, positions and winner status.
 * @note				The list is ordered by rank. Winners always come first.
 *
 * @return				ArrayList with the data.
 */
native ArrayList TGG_GetPlacements()

public SharedPlugin __pl_turbo_gungame =
{
	name = "turbo_gungame",
	file = "turbo_gungame.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_turbo_gungame_SetNTVOptional()
{
	MarkNativeAsOptional("TGG_GetPlacements");
}
#endif