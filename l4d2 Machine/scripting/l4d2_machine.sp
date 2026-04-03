#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin:myinfo =
{
    name = "Machine Gun - AUTO + MANUAL",
    author = "Shadow l4d2",
    description = "Torretas automaticas y manuales | Compatible L4D1/L4D2",
    version = "4.0",
    url = ""
};

new bool:g_bLimitReached = false;
new g_iMaxEntities = 1800;
new g_iModeSelected = 0;

public OnPluginStart()
{
    RegConsoleCmd("sm_machine", Command_MainMenu);
    RegConsoleCmd("sm_torreta", Command_MainMenu);
}

public Action:Command_MainMenu(client, args)
{
    if(!IsClientInGame(client) || !IsPlayerAlive(client))
    {
        return Plugin_Handled;
    }
    
    if(CountEntities() >= g_iMaxEntities)
    {
        PrintToChat(client, "\x01[\x04MACHINE\x01] \x03LIMITE ALCANZADO! No se pueden crear mas.");
        g_bLimitReached = true;
        return Plugin_Handled;
    }
    
    new Menu:menu = CreateMenu(Menu_SelectMode);
    menu.SetTitle("===== SELECCIONAR MODO =====");
    menu.AddItem("1", "MACHINE CUSTOM");
    menu.AddItem("2", "MACHINE INTELIGENTE");
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
    
    return Plugin_Handled;
}

public Menu_SelectMode(Menu:menu, client, const String:item[])
{
    if(StrEqual(item, "exit")) return;
    
    g_iModeSelected = StringToInt(item);
    
    new Menu:menu2 = CreateMenu(Menu_SelectAmmo);
    menu2.SetTitle("===== TIPO DE MUNICION =====");
    menu2.AddItem("1", "Normal");
    menu2.AddItem("2", "Explosiva");
    menu2.AddItem("3", "Incendiaria / Fuego");
    menu2.AddItem("4", "Tesla / Electrica");
    menu2.AddItem("5", "Hielo / Congela");
    menu2.AddItem("6", "Laser");
    menu2.AddItem("7", "Veneno / Nausea");
    menu2.ExitButton = true;
    menu2.Display(client, MENU_TIME_FOREVER);
}

public Menu_SelectAmmo(Menu:menu, client, const String:item[])
{
    if(StrEqual(item, "exit")) return;
    
    if(g_bLimitReached)
    {
        PrintToChat(client, "\x01[\x04MACHINE\x01] \x03No puedes crear, limite alcanzado!");
        return;
    }
    
    new type = StringToInt(item);
    SpawnMachine(client, type, g_iModeSelected);
}

stock SpawnMachine(client, type, mode)
{
    new Float:vPos[3], Float:vAng[3];
    GetClientEyePosition(client, vPos);
    GetClientEyeAngles(client, vAng);
    
    new entity = CreateEntityByName("prop_physics_override");
    
    if(entity == -1)
    {
        PrintToChat(client, "\x01[\x04MACHINE\x01] \x03ERROR al crear la torreta!");
        return;
    }
    
    DispatchKeyValue(entity, "model", "models/props_mining/industrial_crane01.mdl");
    
    if(mode == 2) // Inteligente
    {
        DispatchKeyValue(entity, "health", "9999");
    }
    else // Custom
    {
        DispatchKeyValue(entity, "health", "5000");
    }
    
    DispatchKeyValue(entity, "solid", "6");
    DispatchKeyValue(entity, "Physics", "1");
    DispatchKeyValue(entity, "Explode", "0");
    
    TeleportEntity(entity, vPos, vAng, NULL_VECTOR);
    DispatchSpawn(entity);
    
    SetEntProp(entity, Prop_Data, "m_takedamage", 2);
    SetEntProp(entity, Prop_Send, "m_usSolidFlags", 0);
    SetEntProp(entity, Prop_Send, "m_CollisionGroup", 5);
    SetEntProp(entity, Prop_Send, "m_bUseable", true);
    SetEntPropFloat(entity, Prop_Data, "m_flDamage", 50.0);
    
    // DISPARO AUTOMATICO
    SetVariantString("OnUser1 !self:FireWeapon:0:-1:1");
    AcceptEntityInput(entity, "AddOutput");
    AcceptEntityInput(entity, "FireUser1");
    
    SetMachineProperties(entity, type);
    
    new String:szMode[32];
    if(mode == 1) Format(szMode, sizeof(szMode), "CUSTOM");
    else Format(szMode, sizeof(szMode), "INTELIGENTE");
    
    new String:szNombre[32];
    GetTypeName(type, szNombre, sizeof(szNombre));
    
    PrintToChat(client, "\x01[\x04MACHINE\x01] \x04TORRETA CREADA!");
    PrintToChat(client, "\x01Modo: \x05%s \x01| Dispara SOLA y se puede USAR", szMode);
    PrintToChat(client, "\x01Tipo: \x05%s", szNombre);
}

stock SetMachineProperties(entity, type)
{
    switch(type)
    {
        case 2: // Explosiva
        {
            SetEntPropFloat(entity, Prop_Data, "m_flDamage", 120.0);
            SetEntityRenderColor(entity, 255, 100, 0, 255);
        }
        case 3: // Fuego
        {
            SetEntPropFloat(entity, Prop_Data, "m_flDamage", 60.0);
            SetEntityRenderColor(entity, 255, 40, 0, 255);
        }
        case 4: // Tesla
        {
            SetEntPropFloat(entity, Prop_Data, "m_flDamage", 90.0);
            SetEntityRenderColor(entity, 0, 180, 255, 255);
        }
        case 5: // Hielo
        {
            SetEntPropFloat(entity, Prop_Data, "m_flDamage", 50.0);
            SetEntityRenderColor(entity, 180, 255, 255, 255);
        }
        case 6: // Laser
        {
            SetEntPropFloat(entity, Prop_Data, "m_flDamage", 180.0);
            SetEntityRenderColor(entity, 255, 0, 0, 255);
        }
        case 7: // Veneno
        {
            SetEntPropFloat(entity, Prop_Data, "m_flDamage", 40.0);
            SetEntityRenderColor(entity, 0, 255, 100, 255);
        }
        default: // Normal
        {
            SetEntPropFloat(entity, Prop_Data, "m_flDamage", 35.0);
            SetEntityRenderColor(entity, 200, 200, 200, 255);
        }
    }
}

stock GetTypeName(type, String:buffer[], maxlen)
{
    switch(type)
    {
        case 1: strcopy(buffer, maxlen, "Normal");
        case 2: strcopy(buffer, maxlen, "Explosiva");
        case 3: strcopy(buffer, maxlen, "Incendiaria");
        case 4: strcopy(buffer, maxlen, "Tesla");
        case 5: strcopy(buffer, maxlen, "Hielo");
        case 6: strcopy(buffer, maxlen, "Laser");
        case 7: strcopy(buffer, maxlen, "Veneno");
        default: strcopy(buffer, maxlen, "Desconocido");
    }
}

stock CountEntities()
{
    new count = 0;
    for(new i = 0; i < 2048; i++)
    {
        if(IsValidEntity(i)) count++;
    }
    return count;
}
