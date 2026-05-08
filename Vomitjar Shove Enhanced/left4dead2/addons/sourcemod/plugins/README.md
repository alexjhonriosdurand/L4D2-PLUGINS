# 🔥 Molotov Shove Enhanced

> **[L4D & L4D2]** Incendia infectados al empujarlos con un Molotov en mano — con efectos visuales, sonido y salpicadura de fuego a jugadores cercanos.

![SourceMod](https://img.shields.io/badge/SourceMod-1.12%2B-orange?style=flat-square)
![Game](https://img.shields.io/badge/Game-L4D%20%7C%20L4D2-red?style=flat-square)
![Version](https://img.shields.io/badge/Version-1.12--enhanced-brightgreen?style=flat-square)
![Author](https://img.shields.io/badge/Author-Shadow%20L4D2-blue?style=flat-square)

---

## 📋 Descripción

**Molotov Shove Enhanced** transforma el empujón de un Molotov en algo realmente peligroso. Si un superviviente empuja a un infectado (o a otro jugador) mientras sostiene un Molotov, el objetivo recibe daño de fuego, un efecto visual de pantalla naranja y un glow temporal. Además, los jugadores cercanos a la explosión reciben salpicadura de fuego.

---

## ✨ Características

- 🔥 **Daño de fuego** al empujar infectados (`infected`, `witch`) con un Molotov en mano
- 💥 **Efecto visual** de pantalla naranja-fuego para el objetivo
- 🌊 **Salpicadura** — jugadores a menos de 150 unidades también reciben el efecto visual
- 💡 **Glow temporal** (6 segundos) sobre el objetivo incendiado
- 🔊 **Sonido de detonación** de Molotov al impacto
- 📢 **HUD hint** notificando al objetivo
- ⚙️ **ConVar** para habilitar/deshabilitar el plugin en caliente

---

## 🛠️ Requisitos

| Requisito | Versión mínima |
|-----------|----------------|
| SourceMod | 1.12 o superior |
| SDKTools  | Incluido en SM  |
| SDKHooks  | Incluido en SM  |
| Left 4 Dead / L4D2 | Cualquier versión |

---

## 📦 Instalación

1. Descarga `l4d_Molotov_Shove_Enhanced.smx`
2. Cópialo en:
   ```
   addons/sourcemod/plugins/
   ```
3. Reinicia el servidor o escribe en consola:
   ```
   sm plugins load l4d_Molotov_Shove_Enhanced
   ```

---

## ⚙️ ConVars

| ConVar | Valor por defecto | Descripción |
|--------|:-----------------:|-------------|
| `l4d_molotov_shove_allow` | `1` | Activa (`1`) o desactiva (`0`) el plugin |

---

## 🎮 Comportamiento en juego

### Empujar un infectado o witch
- El infectado recibe **30 daño de fuego**
- El atacante escucha el sonido de detonación como feedback

### Empujar a un superviviente (equipo 2)
- Recibe **10 daño de fuego**
- Efecto visual de fuego en pantalla
- Glow naranja durante 6 segundos
- Mensaje en HUD
- Jugadores a ≤ 150 unidades reciben salpicadura visual

---

## 📁 Estructura de archivos

```
addons/
└── sourcemod/
    └── plugins/
        └── l4d_Molotov_Shove_Enhanced.smx
```

---

## 🔧 Compilación

Compila con el compilador online de SourceMod:

🔗 [https://www.sourcemod.net/compiler.php](https://www.sourcemod.net/compiler.php)

Requiere los includes estándar: `sourcemod`, `sdktools`, `sdkhooks`.

---

## 📝 Changelog

| Versión | Cambios |
|---------|---------|
| `1.12-enhanced` | Refactorización completa. Separación de lógica cliente/entidad. Corrección del equipo superviviente (team 2). Reemplazo de `ScreenFade` por sistema de mensajes nativo. Salpicadura de fuego añadida. |

---

## 👤 Autor

**Shadow L4D2** — Servidor cooperativo L4D2  
📂 [GitHub: L4D2-PLUGINS](https://github.com/ShadowL4D2/L4D2-PLUGINS)

---

## 📄 Licencia

Plugin de uso libre para servidores de Left 4 Dead y Left 4 Dead 2.  
Si lo modificas o redistribuyes, por favor da crédito al autor original.
