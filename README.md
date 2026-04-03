# 🧟 Control Zombies — Todos Incluidos

**Plugin para Left 4 Dead 1 & Left 4 Dead 2 | SourceMod**  
Autor: **Shadow L4D2** · Versión: **5.0**

---

## 📋 Descripción

**Control Zombies** es un plugin de SourceMod para **Left 4 Dead 1 y Left 4 Dead 2** que permite gestionar en tiempo real el comportamiento de todos los tipos de zombies del juego — comunes, especiales y raros — directamente desde un menú interactivo en el chat.

Ideal para servidores cooperativos que quieren personalizar la dificultad y la experiencia de juego sin necesidad de reiniciar el mapa ni editar archivos de configuración manualmente.

---

## ⚙️ Características

- 🔛 **Activar / Desactivar el Spawn** de zombies en tiempo real
- 🔢 **Ajustar la cantidad** de zombies que aparecen
- 💨 **Controlar la velocidad** de movimiento de los zombies
- ❤️ **Modificar la vida** de los zombies
- ⚔️ **Cambiar el daño** que infligen los zombies
- 🔁 **Gestionar el respawn** de infectados especiales
- Aplica a **todos los tipos**: comunes, especiales y raros

---

## 🛠️ Requisitos

- [SourceMod](https://www.sourcemod.net/) 1.12 o superior
- Left 4 Dead **1** o Left 4 Dead **2**

---

## 📦 Instalación

1. Descarga el archivo `l4d2_control_total_zombie.smx` (compilado) o compila el `.sp` tú mismo.
2. Copia el archivo `.smx` a la carpeta:
   ```
   addons/sourcemod/plugins/
   ```
3. Reinicia el mapa o escribe `sm plugins load l4d2_control_total_zombie` en la consola.

---

## 🎮 Comandos

| Comando | Descripción |
|---|---|
| `!zmenu` / `sm_zmenu` | Abre el menú principal de control de zombies |
| `!zsalir` / `sm_zsalir` | Cierra / sale del menú |

> Los comandos fueron renombrados a `zm*` para evitar conflictos con otros plugins que usen `sm_menu` o `sm_salir`.

---

## 📁 Estructura del repositorio

```
📂 l4d2-control-zombies/
├── scripting/
│   └── l4d2_control_total_zombie.sp   ← Código fuente
├── plugins/
│   └── l4d2_control_total_zombie.smx  ← Plugin compilado (opcional)
└── README.md
```

---

## 📝 Notas

- Este plugin fue desarrollado para el servidor cooperativo **SAFE ROOM — COOP V2**.
- Los ajustes se aplican en tiempo real sin necesidad de reiniciar el mapa.

---

## 📜 Licencia

Proyecto de código abierto. Libre para usar y modificar con crédito al autor original.

---

> Hecho con ❤️ para la comunidad L4D2 por **Shadow L4D2**
