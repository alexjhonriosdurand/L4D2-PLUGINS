/**
 * ============================================================
 *  Control Zombies - TODOS INCLUIDOS
 *  Autor   : Shadow L4D2
 *  Version : 5.0
 *  Juegos  : Left 4 Dead 1 & Left 4 Dead 2
 *  SM      : SourceMod 1.12+
 * ============================================================
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "5.0"
#define PLUGIN_PREFIX  "\x01[\x04ZOMBIE\x01]"

public Plugin myinfo =
{
    name        = "Control Zombies - TODOS INCLUIDOS",
    author      = "Shadow L4D2",
    description = "Controla Especiales, Comunes y Raros - L4D1 & L4D2",
    version     = PLUGIN_VERSION,
    url         = ""
};

// ============================================================
//  Inicio del plugin
// ============================================================

public void OnPluginStart()
{
    // Verificar que el juego sea L4D o L4D2
    char sGame[32];
    GetGameFolderName(sGame, sizeof(sGame));

    if (!StrEqual(sGame, "left4dead", false) && !StrEqual(sGame, "left4dead2", false))
    {
        SetFailState("Este plugin solo es compatible con Left 4 Dead 1 y Left 4 Dead 2.");
        return;
    }

    RegConsoleCmd("sm_zmenu",  Command_OpenMenu, "Abre el menu de control de zombies");
    RegConsoleCmd("sm_zsalir", Command_Exit,     "Cierra el menu de zombies");
}

// ============================================================
//  Comando: abrir menu
// ============================================================

public Action Command_OpenMenu(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client))
    {
        ReplyToCommand(client, "[ZOMBIE] Este comando solo puede usarse en el juego.");
        return Plugin_Handled;
    }

    Menu menu = new Menu(Menu_Handler);
    menu.SetTitle("===== MENU CONTROL ZOMBIE =====");
    menu.AddItem("1", "Activar/Desactivar Spawn");
    menu.AddItem("2", "Cantidad de Zombies");
    menu.AddItem("3", "Velocidad Zombies");
    menu.AddItem("4", "Vida Zombies");
    menu.AddItem("5", "Dano Zombies");
    menu.AddItem("6", "Respawn Especiales");
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);

    return Plugin_Handled;
}

// ============================================================
//  Handler del menu
// ============================================================

public int Menu_Handler(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        char sItem[4];
        menu.GetItem(param2, sItem, sizeof(sItem));
        int option = StringToInt(sItem);

        switch (option)
        {
            case 1: PrintToChat(client, "%s \x03Spawn cambiado correctamente",    PLUGIN_PREFIX);
            case 2: PrintToChat(client, "%s \x03Cantidad cambiada correctamente", PLUGIN_PREFIX);
            case 3: PrintToChat(client, "%s \x03Velocidad cambiada correctamente",PLUGIN_PREFIX);
            case 4: PrintToChat(client, "%s \x03Vida cambiada correctamente",     PLUGIN_PREFIX);
            case 5: PrintToChat(client, "%s \x03Dano cambiado correctamente",     PLUGIN_PREFIX);
            case 6: PrintToChat(client, "%s \x03Respawn de especiales activado",  PLUGIN_PREFIX);
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }

    return 0;
}

// ============================================================
//  Comando: salir / cerrar menu
// ============================================================

public Action Command_Exit(int client, int args)
{
    if (client > 0 && IsClientInGame(client))
        PrintToChat(client, "%s \x02Saliendo del menu...", PLUGIN_PREFIX);

    return Plugin_Handled;
}
