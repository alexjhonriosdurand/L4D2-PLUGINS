#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.1"

// ============================================================================
// Info del Plugin
// ============================================================================
public Plugin myinfo = 
{
    name        = "[L4D/L4D2] Smoker Tongue Pull Fix",
    author      = "Shadow l4d2",
    description = "Fuerza al survivor hacia la posición exacta del Smoker al ser jalado, mejorado para situaciones de pared/altura.",
    version     = "1.1",
    url         = ""
};

// ============================================================================
// Variables Globales
// ============================================================================
bool g_bL4D2;                          
bool g_bPluginEnabled;                 

int g_iSmokerUseridOfVictim[MAXPLAYERS + 1]; 
bool g_bIsBeingPulled[MAXPLAYERS + 1];       
Handle g_hPullTimer[MAXPLAYERS + 1];         

float g_fLastVictimPos[MAXPLAYERS + 1][3];   
float g_fLastSmokerPos[MAXPLAYERS + 1][3];   
int g_iStuckCounter[MAXPLAYERS + 1];         

// ============================================================================
// CVars
// ============================================================================
ConVar g_cvEnabled;        
ConVar g_cvPullForce;      
ConVar g_cvPullInterval;   
ConVar g_cvMaxDistance;    
ConVar g_cvVerticalBoost;  
ConVar g_cvStuckDetectionTolerance; 
ConVar g_cvStuckForceMultiplier;    
ConVar g_cvMaxStuckTicks;           

// ============================================================================
// AskPluginLoad2
// ============================================================================
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion ev = GetEngineVersion();
    if (ev == Engine_Left4Dead2 || ev == Engine_Left4Dead)
    {
        return APLRes_Success;
    }
    
    strcopy(error, err_max, "Solo compatible con Left 4 Dead 1 y 2.");
    return APLRes_SilentFailure;
}

// ============================================================================
// OnPluginStart
// ============================================================================
public void OnPluginStart()
{
    g_bL4D2 = (GetEngineVersion() == Engine_Left4Dead2);

    g_cvEnabled = CreateConVar(
        "sm_smoker_pull_fix",
        "1",
        "Activa el fix del jale del Smoker. (0=Desactivado, 1=Activado)",
        FCVAR_NOTIFY,
        true, 0.0,
        true, 1.0
    );

    g_cvPullForce = CreateConVar(
        "sm_smoker_pull_force",
        "380.0",
        "Fuerza con la que se empuja al survivor hacia el Smoker.",
        FCVAR_NOTIFY,
        true, 100.0,
        true, 1000.0
    );

    g_cvPullInterval = CreateConVar(
        "sm_smoker_pull_interval",
        "0.08",
        "Intervalo en segundos del timer que jala al survivor.",
        FCVAR_NOTIFY,
        true, 0.05,
        true, 0.5
    );

    g_cvMaxDistance = CreateConVar(
        "sm_smoker_pull_maxdist",
        "70.0",
        "Distancia mínima para considerar que el survivor llegó al Smoker.",
        FCVAR_NOTIFY,
        true, 30.0,
        true, 200.0
    );

    g_cvVerticalBoost = CreateConVar(
        "sm_smoker_pull_vertical_boost",
        "1.5",
        "Multiplicador extra de fuerza cuando el Smoker está más arriba que el survivor.",
        FCVAR_NOTIFY,
        true, 1.0,
        true, 3.0
    );

    g_cvStuckDetectionTolerance = CreateConVar(
        "sm_smoker_stuck_tolerance",
        "5.0",
        "Distancia minima de movimiento para no considerar atascado.",
        FCVAR_NOTIFY,
        true, 0.0,
        true, 50.0
    );

    g_cvStuckForceMultiplier = CreateConVar(
        "sm_smoker_stuck_force_multiplier",
        "1.5",
        "Multiplicador de fuerza adicional si esta atascado.",
        FCVAR_NOTIFY,
        true, 1.0,
        true, 3.0
    );
    
    g_cvMaxStuckTicks = CreateConVar(
        "sm_smoker_max_stuck_ticks",
        "5",
        "Ticks consecutivos para considerar atascado.",
        FCVAR_NOTIFY,
        true, 1.0,
        true, 20.0
    );

    g_cvEnabled.AddChangeHook(OnCvarChanged);
    g_bPluginEnabled = g_cvEnabled.BoolValue;

    HookEvents();
    AutoExecConfig(true, "smoker_tongue_pull_fix");

    char sGame[8];
    g_bL4D2 ? strcopy(sGame, sizeof(sGame), "L4D2") : strcopy(sGame, sizeof(sGame), "L4D1");
    LogMessage("[Smoker Pull Fix] Plugin iniciado correctamente en %s (v%s)", sGame, PLUGIN_VERSION);
}

// ============================================================================
// ClearSurvivorPullState
// ============================================================================
void ClearSurvivorPullState(int victim)
{
    g_iSmokerUseridOfVictim[victim] = 0;
    g_bIsBeingPulled[victim] = false;
    g_iStuckCounter[victim] = 0;
    
    g_fLastVictimPos[victim][0] = 0.0;
    g_fLastVictimPos[victim][1] = 0.0;
    g_fLastVictimPos[victim][2] = 0.0;

    if (g_hPullTimer[victim] != null)
    {
        delete g_hPullTimer[victim];
        g_hPullTimer[victim] = null;
    }
}

// ============================================================================
// OnMapStart
// ============================================================================
public void OnMapStart()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        ClearSurvivorPullState(i);
    }
}

// ============================================================================
// OnClientDisconnect
// ============================================================================
public void OnClientDisconnect(int client)
{
    ClearSurvivorPullState(client);
}

// ============================================================================
// HookEvents
// ============================================================================
void HookEvents()
{
    HookEvent("tongue_grab", Event_TongueGrab, EventHookMode_Post);
    HookEvent("tongue_release", Event_TongueRelease, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
    HookEvent("survivor_rescued", Event_SurvivorRescued, EventHookMode_Post);
}

// ============================================================================
// OnCvarChanged
// ============================================================================
public void OnCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    g_bPluginEnabled = g_cvEnabled.BoolValue;
}

// ============================================================================
// Event_TongueGrab
// ============================================================================
public void Event_TongueGrab(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bPluginEnabled) return;

    int victim = GetClientOfUserId(event.GetInt("victim"));
    int smoker = GetClientOfUserId(event.GetInt("userid"));

    if (!IsValidClient(victim) || !IsValidClient(smoker)) return;
    if (!IsPlayerAlive(victim) || !IsPlayerAlive(smoker)) return;
    if (GetClientTeam(victim) != 2 || GetClientTeam(smoker) != 3) return;
    if (GetEntProp(smoker, Prop_Send, "m_zombieClass") != 1) return;

    g_iSmokerUseridOfVictim[victim] = GetClientUserId(smoker);
    g_bIsBeingPulled[victim] = true;

    GetClientAbsOrigin(victim, g_fLastVictimPos[victim]);
    GetClientAbsOrigin(smoker, g_fLastSmokerPos[smoker]);
    g_iStuckCounter[victim] = 0;

    if (g_hPullTimer[victim] != null)
    {
        delete g_hPullTimer[victim];
    }

    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(victim));

    g_hPullTimer[victim] = CreateTimer(
        g_cvPullInterval.FloatValue,
        Timer_PullSurvivor,
        dp,
        TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE
    );
}

// ============================================================================
// Event_TongueRelease
// ============================================================================
public void Event_TongueRelease(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("victim"));
    if (IsValidClient(victim))
    {
        ClearSurvivorPullState(victim);
    }
}

// ============================================================================
// Event_PlayerDeath
// ============================================================================
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!IsValidClient(client)) return;

    int eventUserid = event.GetInt("userid");
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iSmokerUseridOfVictim[i] == eventUserid)
        {
            ClearSurvivorPullState(i);
        }
    }

    ClearSurvivorPullState(client);
}

// ============================================================================
// Event_SurvivorRescued
// ============================================================================
public void Event_SurvivorRescued(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("victim"));
    if (IsValidClient(victim))
    {
        ClearSurvivorPullState(victim);
    }
}

// ============================================================================
// Timer_PullSurvivor
// ============================================================================
public Action Timer_PullSurvivor(Handle timer, DataPack dp)
{
    dp.Reset();
    int userid = dp.ReadCell();
    int victim = GetClientOfUserId(userid);

    if (victim < 1 || !IsValidClient(victim) || !g_bIsBeingPulled[victim])
    {
        if (victim >= 1 && g_hPullTimer[victim] != null)
        {
            g_hPullTimer[victim] = null;
        }
        return Plugin_Stop;
    }

    int smoker = GetClientOfUserId(g_iSmokerUseridOfVictim[victim]);

    if (!IsValidClient(smoker) || !IsPlayerAlive(smoker))
    {
        ClearSurvivorPullState(victim);
        return Plugin_Stop;
    }

    float vVictimPos[3], vSmokerPos[3];
    GetClientAbsOrigin(victim, vVictimPos);
    GetClientAbsOrigin(smoker, vSmokerPos);

    float fDistance = GetVectorDistance(vVictimPos, vSmokerPos);

    if (fDistance <= g_cvMaxDistance.FloatValue)
    {
        ClearSurvivorPullState(victim);
        return Plugin_Stop;
    }

    // --- DETECCION DE ATASCO ---
    float fMovementDelta = GetVectorDistance(vVictimPos, g_fLastVictimPos[victim]);
    float fSmokerMoved = GetVectorDistance(vSmokerPos, g_fLastSmokerPos[smoker]);

    bool bIsStuck = false;
    if (fMovementDelta < g_cvStuckDetectionTolerance.FloatValue && fSmokerMoved < g_cvStuckDetectionTolerance.FloatValue)
    {
        g_iStuckCounter[victim]++;
        if (g_iStuckCounter[victim] >= g_cvMaxStuckTicks.IntValue)
        {
            bIsStuck = true;
        }
    }
    else
    {
        g_iStuckCounter[victim] = 0;
    }

    // Guardar posiciones para la proxima vez
    g_fLastVictimPos[victim] = vVictimPos;
    g_fLastSmokerPos[smoker] = vSmokerPos;

    // --- CALCULAR FUERZA ---
    float vDirection[3];
    SubtractVectors(vSmokerPos, vVictimPos, vDirection);
    NormalizeVector(vDirection, vDirection);

    float fPullForce = g_cvPullForce.FloatValue;

    // Aplicar multiplicador si esta atascado
    if (bIsStuck)
    {
        fPullForce *= g_cvStuckForceMultiplier.FloatValue;
    }

    // Aplicar boost vertical
    if (vSmokerPos[2] > vVictimPos[2])
    {
        float fVerticalDiff = vSmokerPos[2] - vVictimPos[2];
        float fBoostMultiplier = g_cvVerticalBoost.FloatValue;
        
        if (fVerticalDiff > 200.0)
        {
            float fBoosted = fBoostMultiplier * 1.3;
            fBoostMultiplier = (fBoosted < 2.0) ? fBoosted : 2.0;
        }

        vDirection[2] *= fBoostMultiplier;
    }

    // Aplicar velocidad
    float vVelocity[3];
    vVelocity[0] = vDirection[0] * fPullForce;
    vVelocity[1] = vDirection[1] * fPullForce;
    vVelocity[2] = vDirection[2] * fPullForce;

    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vVelocity);

    return Plugin_Continue;
}

// ============================================================================
// IsValidClient
// ============================================================================
stock bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client));
}
