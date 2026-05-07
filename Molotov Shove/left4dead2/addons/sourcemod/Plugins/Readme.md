[L4D & L4D2] Molotov Shove FIXED
Versión: 1.11-fixed
Autor: Shadow L4d2
Descripción: Los infectados se encienden al ser empujados por jugadores con molotovs. Compatible con Left 4 Dead y Left 4 Dead 2.

--------------------------------------------------
CARACTERÍSTICAS
--------------------------------------------------
- Enciende a los infectados y brujas al ser empujados por molotovs.
- Configurable mediante ConVars: límites por jugador, teclas necesarias, modos de juego y temporizadores.
- Reinicio automático de contadores al finalizar la ronda.
- Precarga de modelos y sonidos para mejor rendimiento.
- Compatible con entidades específicas: "infected" y "witch".

--------------------------------------------------
REQUISITOS
--------------------------------------------------
- SourceMod y MetaMod 1.12 para funcionalidades avanzadas.

--------------------------------------------------
INSTALACIÓN
--------------------------------------------------
1. Copia el archivo .smx en:
   addons/sourcemod/plugins/
2. Reinicia el servidor o recarga el plugin:
   sm plugins reload <nombre_del_plugin>
3. Ajusta las ConVars según tus preferencias (opcional).

--------------------------------------------------
CONVARS PRINCIPALES
--------------------------------------------------
ConVar                            Default     Descripción
--------------------------------------------------------------------
l4d_molotov_shove_allow            1           Activa/desactiva el plugin
l4d_molotov_shove_modes            ""          Modos de juego permitidos
l4d_molotov_shove_modes_off        ""          Modos de juego desactivados
l4d_molotov_shove_modes_tog        0           Alternar modos
l4d_molotov_shove_remove           2           Controla eliminación de armas tras uso
l4d_molotov_shove_timed            256         Duración del efecto
l4d_molotov_shove_timeout          10.0        Tiempo de espera entre empujones
l4d_molotov_shove_version          1.11-fixed Versión (solo lectura)
l4d_molotov_shove_infected         511         Tipos de infectados afectados
l4d_molotov_shove_keys             1           Tecla especial necesaria para empujar
l4d_molotov_shove_limited          2           Máximo de veces que un arma activa el efecto
l4d_molotov_shove_limit            0           Límite de empujones por jugador (0 = ilimitado)

--------------------------------------------------
EVENTOS DEL PLUGIN
--------------------------------------------------
- OnMapStart: Precarga modelos y sonidos, engancha eventos.
- OnMapEnd / Event_RoundEnd: Reinicia contadores y estados.
- Event_EntityShoved: Daño a "infected" y "witch" al empujar.
- Event_PlayerShoved: Daño a jugadores infectados.
- LimitedFunc: Controla límite de uso por arma y emite sonido de rotura.

--------------------------------------------------
FUNCIONES PRINCIPALES
--------------------------------------------------
- CheckWeapon(client): Comprueba si el jugador tiene un molotov activo.
- HurtPlayer(target, client): Aplica daño de quemadura.
- ResetPlugin(): Reinicia todos los contadores.
- GetCvars(): Obtiene valores actuales de ConVars.
- LimitedFunc(client): Gestiona límites de uso por arma.

--------------------------------------------------
NOTAS
--------------------------------------------------
- Optimizado para servidores cooperativos de L4D y L4D2.
- Compatible con la mayoría de mods que no alteren eventos de empujón.
- Mantén SourceMod y MetaMod 1.12 actualizados para evitar errores.
