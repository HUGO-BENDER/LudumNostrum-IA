# LudumNostrum · IA

Framework reutilizable de desarrollo asistido por agentes de IA. Define **cómo** se trabaja en todos los proyectos de LudumNostrum: agentes, skills, memoria, flujo por issues y estándares.

```
LudumNostrum/
├── IA/            ← este repo (framework)
├── Proyecto001/   ← proyectos: repos hermanos generados desde IA/template
└── Proyecto002/
```

## Idea en 30 segundos

- Solo hablas con el **Orquestador**. Él delega en **Planificador**, **Developer**, **Explorer** y **Tester**.
- Se avanza **issue a issue**, en pasos pequeños y verificables. Nunca se planifica más allá de los próximos 3–5 issues.
- Todo lo que importa queda escrito en `.ai/` dentro de cada proyecto: es la memoria y la fuente de verdad compartida por todos los agentes.

## Contenido

| Ruta | Qué es |
|---|---|
| [docs/arquitectura.md](docs/arquitectura.md) | Visión general, agentes y cómo se relacionan |
| [docs/flujo-issues.md](docs/flujo-issues.md) | Ciclo de vida de un issue |
| [docs/memoria.md](docs/memoria.md) | Reglas del directorio `.ai/` |
| [docs/modelos.md](docs/modelos.md) | Modelo de cada agente y por qué |
| [docs/adr/](docs/adr/) | Decisiones del propio framework |
| [standards/](standards/) | Estándares comunes (código, git, Definition of Done), importados por cada proyecto |
| [template/](template/) | Lo que se copia a cada proyecto nuevo |
| [scripts/](scripts/) | `New-Project.ps1` y `Sync-Agents.ps1` |
| [prompts/](prompts/) | Prompts reutilizables |

## Crear un proyecto nuevo

```powershell
.\scripts\New-Project.ps1 -Name Proyecto002 -Description "Breve descripción"
```

Crea `..\Proyecto002` desde `template/`, sustituye los marcadores, inicializa git, configura `origin` → `https://github.com/HUGO-BENDER/LudumNostrum-Proyecto002.git` y hace el primer commit. No hace push: crea antes el repo en GitHub (vacío) y luego `git push -u origin main`. Para otro dueño: `-GitHubOwner <usuario>`; para no configurar remoto: `-GitHubOwner ''`.

## Repositorios

| Local | GitHub |
|---|---|
| `IA/` | `https://github.com/HUGO-BENDER/LudumNostrum-IA` |
| `ProyectoNNN/` | `https://github.com/HUGO-BENDER/LudumNostrum-ProyectoNNN` |

## Trabajar en un proyecto

```powershell
cd ..\Proyecto001
claude            # arranca directamente como orquestador (settings.json → "agent": "orquestador")
```

Frases útiles para el orquestador: *"¿dónde estamos?"*, *"quiero X"*, *"ejecuta el issue 0003"*, *"cierra el issue"*.

## Actualizar los agentes de un proyecto existente

```powershell
.\scripts\Sync-Agents.ps1 -Name Proyecto001
```

Sobrescribe `.claude/agents` y `.claude/skills` con la versión de `template/`. **No toca** `.ai/`, `AGENTS.md` ni `settings.json` (te avisa si difieren).

## Versionado

El framework sigue semver ([CHANGELOG.md](CHANGELOG.md)). Cada proyecto guarda la versión con la que se creó o sincronizó en `.claude/framework-version`.
