// Special Infected constants (for spawning)
#define SI_SMOKER		0
#define SI_BOOMER		1
#define SI_HUNTER		2
#define SI_SPITTER		3
#define SI_JOCKEY		4
#define SI_CHARGER		5

#define UNINITIALISED -1

// Settings upon load
new Handle:hSILimitServerCap;
new Handle:hSILimit;
new Handle:hSpawnWeights[NUM_TYPES_INFECTED], Handle:hScaleWeights;
new Handle:hSpawnLimits[NUM_TYPES_INFECTED];
new Handle:hSpawnSize;

// Customised settings; cache
new SILimitCache = UNINITIALISED;
new SpawnWeightsCache[NUM_TYPES_INFECTED] = { UNINITIALISED, UNINITIALISED, UNINITIALISED, UNINITIALISED, UNINITIALISED, UNINITIALISED };
new SpawnLimitsCache[NUM_TYPES_INFECTED] = { UNINITIALISED, UNINITIALISED, UNINITIALISED, UNINITIALISED, UNINITIALISED, UNINITIALISED };
new SpawnSizeCache = UNINITIALISED;

public SpawnCustomisation_OnModuleStart() {
	// Server SI max (marked FCVAR_CHEAT; admin only)
	hSILimitServerCap = CreateConVar("ss_server_si_limit", "12", "The max amount of special infected at once", FCVAR_CHEAT, true, 1.0);
	// Spawn limits
	hSILimit = CreateConVar("ss_si_limit", "8", "The max amount of special infected at once", FCVAR_PLUGIN, true, 1.0, true, float(GetConVarInt(hSILimitServerCap)) );
	HookConVarChange(hSILimit, ConVarChanged:CalculateSpawnTimes);
	hSpawnSize = CreateConVar("ss_spawn_size", "3", "The amount of special infected spawned at each spawn interval", FCVAR_PLUGIN, true, 1.0, true, float(GetConVarInt(hSILimitServerCap)) );
	hSpawnLimits[SI_SMOKER]		= CreateConVar("ss_smoker_limit",	"1", "The max amount of smokers present at once", FCVAR_PLUGIN, true, 0.0, true, 14.0);
	hSpawnLimits[SI_BOOMER]		= CreateConVar("ss_boomer_limit",	"1", "The max amount of boomers present at once", FCVAR_PLUGIN, true, 0.0, true, 14.0);
	hSpawnLimits[SI_HUNTER]		= CreateConVar("ss_hunter_limit",	"1", "The max amount of hunters present at once", FCVAR_PLUGIN, true, 0.0, true, 14.0);
	hSpawnLimits[SI_SPITTER]	= CreateConVar("ss_spitter_limit",	"1", "The max amount of spitters present at once", FCVAR_PLUGIN, true, 0.0, true, 14.0);
	hSpawnLimits[SI_JOCKEY]		= CreateConVar("ss_jockey_limit",	"1", "The max amount of jockeys present at once", FCVAR_PLUGIN, true, 0.0, true, 14.0);
	hSpawnLimits[SI_CHARGER]	= CreateConVar("ss_charger_limit",	"1", "The max amount of chargers present at once", FCVAR_PLUGIN, true, 0.0, true, 14.0);
	// Weights
	hSpawnWeights[SI_SMOKER]	= CreateConVar("ss_smoker_weight",	"100", "The weight for a smoker spawning", FCVAR_PLUGIN, true, 0.0);
	hSpawnWeights[SI_BOOMER]	= CreateConVar("ss_boomer_weight",	"100", "The weight for a boomer spawning", FCVAR_PLUGIN, true, 0.0);
	hSpawnWeights[SI_HUNTER]	= CreateConVar("ss_hunter_weight",	"100", "The weight for a hunter spawning", FCVAR_PLUGIN, true, 0.0);
	hSpawnWeights[SI_SPITTER]	= CreateConVar("ss_spitter_weight", "100", "The weight for a spitter spawning", FCVAR_PLUGIN, true, 0.0);
	hSpawnWeights[SI_JOCKEY]	= CreateConVar("ss_jockey_weight",	"100", "The weight for a jockey spawning", FCVAR_PLUGIN, true, 0.0);
	hSpawnWeights[SI_CHARGER]	= CreateConVar("ss_charger_weight", "100", "The weight for a charger spawning", FCVAR_PLUGIN, true, 0.0);
	hScaleWeights = CreateConVar("ss_scale_weights", "0",	"[ 0 = OFF | 1 = ON ] Scale spawn weights with the limits of corresponding SI", FCVAR_PLUGIN, true, 0.0, true, 1.0);
}


/***********************************************************************************************************************************************************************************

                                                                       LIMIT/WEIGHT UTILITY
                                                                    
***********************************************************************************************************************************************************************************/

LoadCacheSpawnLimits() {
	if( SILimitCache != UNINITIALISED ) SetConVarInt( hSILimit, SILimitCache );
	if( SpawnSizeCache != UNINITIALISED ) SetConVarInt( hSpawnSize, SpawnSizeCache );
	for( new i = 0; i < NUM_TYPES_INFECTED; i++ ) {		
		if( SpawnLimitsCache[i] != UNINITIALISED ) {
			SetConVarInt( hSpawnLimits[i], SpawnLimitsCache[i] );
		}
	}
}

LoadCacheSpawnWeights() {
	for( new i = 0; i < NUM_TYPES_INFECTED; i++ ) {		
		if( SpawnWeightsCache[i] != UNINITIALISED ) {
			SetConVarInt( hSpawnWeights[i], SpawnWeightsCache[i] );
		}
	}
}

ResetWeights() {
	for (new i = 0; i < NUM_TYPES_INFECTED; i++) {
		ResetConVar(hSpawnWeights[i]);
	}
}
