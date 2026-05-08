# 🤢 Vomitjar Shove Enhanced

> **[L4D2]** Empuja a infectados y supervivientes con un Vomitjar en mano — con efecto visual de vómito, glow temporal, sonido y salpicadura a jugadores cercanos.

![SourceMod](https://img.shields.io/badge/SourceMod-1.12%2B-orange?style=flat-square)
![Game](https://img.shields.io/badge/Game-L4D2-red?style=flat-square)
![Version](https://img.shields.io/badge/Version-1.3--clean-brightgreen?style=flat-square)
![Author](https://img.shields.io/badge/Author-Shadow%20L4D2-blue?style=flat-square)

---

## 📋 Descripción

**Vomitjar Shove Enhanced** convierte el empujón con un Vomitjar en algo visualmente impactante. Si un superviviente empuja a otro jugador o infectado mientras sostiene un Vomitjar, el objetivo queda cubierto de vómito con un efecto de pantalla verde pulsante, glow temporal y sonido. Los jugadores cercanos también reciben salpicadura.

---

## ✨ Características

- 🟢 **Efecto visual pulsante** de pantalla verde-vómito en 3 oleadas
- 💡 **Glow temporal** (8 segundos) sobre el objetivo afectado
- 🌊 **Salpicadura** — jugadores a menos de 150 unidades reciben efecto visual
- 🔊 **Sonido** de salpicadura de vómito al impacto
- 📢 **HUD hint** notificando al objetivo y a los salpicados
- 🔥 **Infectados** (`infected`) son ignitados durante 2 segundos al ser empujados
- ⚙️ **ConVar** para habilitar/deshabilitar el plugin en caliente

---

## 🛠️ Requisitos

| Requisito | Versión mínima |
|-----------|----------------|
| SourceMod | 1.12 o superior |
| SDKTools  | Incluido en SM  |
| Left 4 Dead 2 | Cualquier versión |

> ⚠️ Este plugin es **exclusivo de L4D2**. El Vomitjar no existe en L4D1.

---

## 📦 Instalación

1. Descarga `vomitjar_shove_enhanced.smx`
2. Cópialo en:
   ```
   addons/sourcemod/plugins/
   ```
3. Reinicia el servidor o escribe en consola:
   ```
   sm plugins load vomitjar_shove_enhanced
   ```

---

## ⚙️ ConVars

| ConVar | Valor por defecto | Descripción |
|--------|:-----------------:|-------------|
| `l4d2_vomitjar_shove_allow` | `1` | Activa (`1`) o desactiva (`0`) el plugin |

---

## 🎮 Comportamiento en juego

### Empujar un infectado (`infected`)
- El infectado es **ignitado durante 2 segundos**

### Empujar a un superviviente (equipo 3 = infectados jugables / supervivientes empujados)
- Recibe el **efecto visual verde pulsante** en 3 oleadas
- Glow verde durante **8 segundos**
- Sonido de salpicadura de vómito
- Mensaje en HUD: *"¡Has sido cubierto de vómito!"*
- Jugadores a ≤ 150 unidades reciben **salpicadura visual** y mensaje

---

## 📁 Estructura de archivos

```
addons/
└── sourcemod/
    └── plugins/
        └── vomitjar_shove_enhanced.smx
```

---

## 🔧 Compilación

Compila con el compilador online de SourceMod:

🔗 [https://www.sourcemod.net/compiler.php](https://www.sourcemod.net/compiler.php)

Requiere los includes estándar: `sourcemod`, `sdktools`.

---

## 📝 Changelog

| Versión | Cambios |
|---------|---------|
| `1.3-clean` | Compilación limpia sin warnings. Efecto de pantalla verde pulsante en 3 oleadas con timers. Sistema de salpicadura a jugadores cercanos. Glow de 8 segundos. |

---

## 👤 Autor

**Shadow L4D2** — Servidor cooperativo L4D2  
📂 [GitHub: L4D2-PLUGINS](https://github.com/ShadowL4D2/L4D2-PLUGINS)

---

## 📄 Licencia

Plugin de uso libre para servidores de Left 4 Dead 2.  
Si lo modificas o redistribuyes, por favor da crédito al autor original.
