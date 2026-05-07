#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.3-clean"

ConVar g_hAllow;
bool g_bAllow;

public Plugin myinfo =
{
    name = "[L4D2] Vomitjar Shove Enhanced",
    author = "Shadow L4d2",
    description = "Vomit effect with glow, screen fade, sound & splash, clean compile",
    version = PLUGIN_VERSION
};

// =======================
// INIT
// =======================
public void OnPluginStart()
{
    g_hAllow = CreateConVar("l4d2_vomitjar_shove_allow", "1");

    HookEvent("entity_shoved", Event_Shoved);
    HookEvent("player_shoved", Event_PlayerShoved);
}

public void OnConfigsExecuted()
{
    g_bAllow = g_hAllow.BoolValue;
}

// =======================
// SCREEN FADE
// =======================
void ScreenFade(int client, int r, int g, int b, int a, float duration)
{
    Handle msg = StartMessageOne("Fade", client);
    if (msg == null)
        return;

    int dur  = RoundToNearest(duration * 1024.0);
    int hold = RoundToNearest(duration * 1024.0);

    BfWriteShort(msg, dur);
    BfWriteShort(msg, hold);
    BfWriteShort(msg, 0x0001); // FFADE_IN
    BfWriteByte(msg, r);
    BfWriteByte(msg, g);
    BfWriteByte(msg, b);
    BfWriteByte(msg, a);
    EndMessage();
}

// =======================
// EFECTO DE VÓMITO SIN WARNINGS
// =======================
void VomitScreenEffect(int client)
{
    if (client <= 0 || !IsClientInGame(client)) return;

    float durations[3] = {0.5, 0.3, 0.2};

    // Inicialización segura de colores
    int r[3]; int g[3]; int b[3];
    r[0] = 50;  r[1] = 100; r[2] = 50;
    g[0] = 200; g[1] = 255; g[2] = 150;
    b[0] = 0;   b[1] = 50;  b[2] = 0;

    for (int i = 0; i < 3; i++)
    {
        CreateTimer(durations[i], TimerFadeCallback, client, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action TimerFadeCallback(Handle timer, int client)
{
    if (client > 0 && IsClientInGame(client))
    {
        ScreenFade(client, 50, 200, 0, 180, 0.3);
    }
    return Plugin_Stop;
}

// =======================
// DETECTAR VOMITJAR
// =======================
bool IsVomitJar(int client)
{
    int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

    if (weapon <= 0 || !IsValidEntity(weapon))
        return false;

    char name[32];
    GetEntityClassname(weapon, name, sizeof(name));

    return (StrContains(name, "vomitjar", false) != -1);
}

// =======================
// EFECTO DE VÓMITO
// =======================
void ApplyVomit(int target)
{
    if (target <= 0 || !IsClientInGame(target)) return;

    // Glow temporal
    SetEntProp(target, Prop_Send, "m_iGlowType", 3);
    CreateTimer(8.0, RemoveGlow, target);

    // Fade dinámico
    VomitScreenEffect(target);

    // Mensaje y sonido
    PrintHintText(target, "¡Has sido cubierto de vómito!");
    EmitSoundToClient(target, "vomit_splash.wav", target, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    // Salpicadura a jugadores cercanos
    int maxClients = MaxClients;
    float origin[3];
    GetClientAbsOrigin(target, origin);

    for (int i = 1; i <= maxClients; i++)
    {
        if (i != target && IsClientInGame(i))
        {
            float pos[3];
            GetClientAbsOrigin(i, pos);

            if (GetVectorDistance(origin, pos) <= 150.0)
            {
                VomitScreenEffect(i);
                PrintHintText(i, "¡Salpicado por el vómito!");
            }
        }
    }
}

// =======================
// REMOVER GLOW
// =======================
public Action RemoveGlow(Handle timer, int client)
{
    if (client > 0 && IsClientInGame(client))
    {
        SetEntProp(client, Prop_Send, "m_iGlowType", 0);
    }
    return Plugin_Stop;
}

// =======================
// EVENTOS
// =======================
public void Event_PlayerShoved(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bAllow) return;

    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int target   = GetClientOfUserId(event.GetInt("userid"));

    if (attacker <= 0 || target <= 0) return;
    if (!IsVomitJar(attacker)) return;

    if (GetClientTeam(target) == 3)
    {
        ApplyVomit(target);
    }
}

public void Event_Shoved(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bAllow) return;

    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    if (attacker <= 0 || !IsVomitJar(attacker)) return;

    int entity = event.GetInt("entityid");
    if (entity > 0 && IsValidEntity(entity))
    {
        char classname[32];
        GetEntityClassname(entity, classname, sizeof(classname));

        if (StrEqual(classname, "infected"))
        {
            IgniteEntity(entity, 2.0);
        }
    }
}