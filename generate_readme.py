#!/usr/bin/env python3
"""
generate_readme.py — Shadow L4D2
Escanea el repositorio y regenera README.md automáticamente.
Detecta carpetas de plugins, archivos .sp y .smx.
"""

import os
import re
from datetime import datetime

# ─── Configuración ────────────────────────────────────────────
AUTHOR       = "Shadow L4D2"
REPO_NAME    = "L4D2 Plugins Collection"
REPO_DESC    = "Colección de plugins de SourceMod para Left 4 Dead 1 & Left 4 Dead 2."
SM_VERSION   = "1.12+"
GAMES        = "Left 4 Dead 1 & Left 4 Dead 2"
OUTPUT_FILE  = "README.md"
# ──────────────────────────────────────────────────────────────


def parse_sp_info(filepath):
    """Lee un .sp y extrae name, description, version del bloque myinfo."""
    info = {}
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        for field in ("name", "description", "version"):
            match = re.search(rf'{field}\s*=\s*"([^"]+)"', content)
            if match:
                info[field] = match.group(1)
    except Exception:
        pass
    return info


def scan_plugins(root="."):
    """
    Escanea el repositorio buscando plugins.
    Prioridad: carpetas con .sp adentro > .sp sueltos > .smx sueltos.
    Devuelve lista de dicts con info de cada plugin.
    """
    plugins = []
    visited_sp = set()

    # 1. Carpetas que contienen al menos un .sp
    for entry in sorted(os.scandir(root), key=lambda e: e.name.lower()):
        if not entry.is_dir() or entry.name.startswith("."):
            continue
        sp_files = [
            f for f in os.listdir(entry.path)
            if f.endswith(".sp")
        ]
        if not sp_files:
            continue
        sp_path = os.path.join(entry.path, sp_files[0])
        visited_sp.add(os.path.abspath(sp_path))
        info = parse_sp_info(sp_path)
        smx_exists = any(f.endswith(".smx") for f in os.listdir(entry.path))
        plugins.append({
            "folder":      entry.name,
            "sp":          sp_files[0],
            "smx":         smx_exists,
            "name":        info.get("name", entry.name),
            "description": info.get("description", "Sin descripción."),
            "version":     info.get("version", "—"),
        })

    # 2. .sp sueltos en la raíz (no dentro de carpetas ya procesadas)
    for entry in sorted(os.scandir(root), key=lambda e: e.name.lower()):
        if not entry.is_file() or not entry.name.endswith(".sp"):
            continue
        if os.path.abspath(entry.path) in visited_sp:
            continue
        info = parse_sp_info(entry.path)
        smx_name = entry.name.replace(".sp", ".smx")
        smx_exists = os.path.isfile(os.path.join(root, smx_name))
        plugins.append({
            "folder":      None,
            "sp":          entry.name,
            "smx":         smx_exists,
            "name":        info.get("name", entry.name.replace(".sp", "")),
            "description": info.get("description", "Sin descripción."),
            "version":     info.get("version", "—"),
        })

    # 3. .smx sueltos sin .sp correspondiente
    sp_names = {p["sp"].replace(".sp", "") for p in plugins}
    for entry in sorted(os.scandir(root), key=lambda e: e.name.lower()):
        if not entry.is_file() or not entry.name.endswith(".smx"):
            continue
        base = entry.name.replace(".smx", "")
        if base in sp_names:
            continue
        plugins.append({
            "folder":      None,
            "sp":          None,
            "smx":         True,
            "name":        base,
            "description": "Sin descripción (solo binario .smx).",
            "version":     "—",
        })

    return plugins


def build_readme(plugins):
    now = datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")

    lines = []

    # Encabezado
    lines += [
        f"# 🧟 {REPO_NAME}",
        "",
        f"**{REPO_DESC}**  ",
        f"Autor: **{AUTHOR}** · SourceMod: **{SM_VERSION}** · Juegos: **{GAMES}**",
        "",
        "---",
        "",
    ]

    # Descripción general
    lines += [
        "## 📋 Descripción",
        "",
        "Repositorio oficial de plugins desarrollados por **Shadow L4D2** para servidores cooperativos de L4D1 y L4D2.",
        "Todos los plugins están escritos en SourcePawn con sintaxis moderna (SM 1.12+), sin código duplicado y compatibles con ambos juegos.",
        "",
        "---",
        "",
    ]

    # Tabla de plugins
    lines += [
        "## 🔌 Plugins disponibles",
        "",
    ]

    if not plugins:
        lines.append("> ⚠️ No se encontraron plugins en el repositorio.")
    else:
        lines += [
            "| Plugin | Versión | Descripción | Fuente | Compilado |",
            "|--------|---------|-------------|--------|-----------|",
        ]
        for p in plugins:
            sp_badge  = "✅ `.sp`"  if p["sp"]  else "❌"
            smx_badge = "✅ `.smx`" if p["smx"] else "❌"
            folder    = f"`{p['folder']}/`" if p["folder"] else "raíz"
            lines.append(
                f"| **{p['name']}** | {p['version']} | {p['description']} | {sp_badge} | {smx_badge} |"
            )

    lines += ["", "---", ""]

    # Requisitos
    lines += [
        "## 🛠️ Requisitos",
        "",
        f"- [SourceMod](https://www.sourcemod.net/) {SM_VERSION}",
        "- Left 4 Dead **1** o Left 4 Dead **2**",
        "",
        "---",
        "",
    ]

    # Instalación
    lines += [
        "## 📦 Instalación",
        "",
        "1. Descarga el `.smx` del plugin que quieras (carpeta `plugins/`) o compila el `.sp` tú mismo.",
        "2. Copia el `.smx` a:",
        "   ```",
        "   addons/sourcemod/plugins/",
        "   ```",
        "3. Escribe `sm plugins load <nombre>` en la consola para cargarlo sin reiniciar.",
        "",
        "---",
        "",
    ]

    # Estructura
    lines += [
        "## 📁 Estructura del repositorio",
        "",
        "```",
        "📂 repositorio/",
        "├── 📂 nombre-del-plugin/",
        "│   ├── scripting/  ← código fuente .sp",
        "│   └── plugins/    ← compilado .smx",
        "├── generate_readme.py  ← genera este README automáticamente",
        "└── README.md",
        "```",
        "",
        "---",
        "",
    ]

    # Notas
    lines += [
        "## 📝 Notas",
        "",
        "- Plugins desarrollados para el servidor cooperativo **SAFE ROOM — COOP V2**.",
        "- Sintaxis SourcePawn moderna: `#pragma newdecls required`, sin código duplicado.",
        "- Compatibles con L4D1 y L4D2 (detección automática en tiempo de carga).",
        "",
        "---",
        "",
    ]

    # Licencia
    lines += [
        "## 📜 Licencia",
        "",
        "Código abierto. Libre de usar y modificar con crédito al autor original.",
        "",
        "---",
        "",
        f"> Hecho con ❤️ para la comunidad L4D2 por **{AUTHOR}**  ",
        f"> *README generado automáticamente el {now}*",
    ]

    return "\n".join(lines)


def main():
    root = os.path.dirname(os.path.abspath(__file__))
    plugins = scan_plugins(root)
    content = build_readme(plugins)

    out_path = os.path.join(root, OUTPUT_FILE)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"✅ README.md generado con {len(plugins)} plugin(s) detectado(s).")
    for p in plugins:
        print(f"   → {p['name']} v{p['version']}")


if __name__ == "__main__":
    main()
