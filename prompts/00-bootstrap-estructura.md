# Prompt de bootstrap — Framework multi‑agente LudumNostrum

> Copia todo lo que hay debajo de la línea en una sesión nueva de tu IA (Claude Code recomendado),
> abierta en `C:\Users\hugo.bender\Documents\Code\LudumNostrum`.

---

Actúa como arquitecto de sistemas de desarrollo asistido por IA. Vas a crear un **framework reutilizable de agentes** y la estructura del primer proyecto. No escribas código de producto todavía: solo estructura, agentes, skills, plantillas y documentación.

## 1. Contexto y objetivos

- Raíz: `C:\Users\hugo.bender\Documents\Code\LudumNostrum`.
- `LudumNostrum\IA\` es el **framework** (repo git propio): documentación, estándares, plantillas de agentes y scripts. Toda la documentación del framework vive aquí.
- Los proyectos son **hermanos** de `IA`: `LudumNostrum\Proyecto001`, `LudumNostrum\Proyecto002`, … Cada uno es su propio repo git y contiene su propia configuración de agentes (copiada desde la plantilla) y su propia memoria.
- El usuario **solo habla con el Orquestador**. El resto de agentes son subagentes que el Orquestador invoca.
- Desarrollo **siempre por issues**: pasos pequeños, incrementales, verificables. No se planifica todo de antemano; se planifica solo el siguiente paso con valor.
- Debe funcionar con Claude Code y ser lo más agnóstico posible respecto a otras herramientas (Codex, Cursor, Copilot, Gemini CLI) usando el estándar `AGENTS.md`.
- Idioma de la documentación y de los agentes: español. Identificadores de código en inglés.

## 2. Estructura a crear

```
LudumNostrum/
├── IA/                                   # Framework (repo git)
│   ├── README.md                         # Qué es, cómo crear un proyecto, cómo actualizarlo
│   ├── CHANGELOG.md                      # Versionado del framework (semver)
│   ├── docs/
│   │   ├── arquitectura.md               # Visión general, diagrama de agentes y flujo
│   │   ├── flujo-issues.md               # Ciclo de vida de un issue paso a paso
│   │   ├── memoria.md                    # Reglas del directorio de memoria (.ai/)
│   │   ├── modelos.md                    # Qué modelo usa cada agente y por qué
│   │   └── adr/ADR-0001-framework.md     # Decisiones del propio framework
│   ├── standards/
│   │   ├── coding.md                     # Convenciones generales de código
│   │   ├── git.md                        # Ramas, commits (Conventional Commits), PRs
│   │   └── definition-of-done.md         # DoD común a todos los issues
│   ├── template/                         # Lo que se copia a cada proyecto nuevo
│   │   ├── AGENTS.md
│   │   ├── CLAUDE.md
│   │   ├── .claude/
│   │   │   ├── settings.json
│   │   │   ├── agents/  (orquestador.md, planificador.md, developer.md, explorer.md, tester.md)
│   │   │   └── skills/  (nuevo-issue/, ejecutar-issue/, cerrar-issue/, actualizar-memoria/, estado/)
│   │   └── .ai/                          # Memoria del proyecto (ver §4)
│   ├── scripts/
│   │   ├── New-Project.ps1               # Crea ProyectoNNN desde template/, git init, primer commit
│   │   └── Sync-Agents.ps1               # Actualiza .claude/ de un proyecto existente desde template/ (sin tocar .ai/)
│   └── prompts/                          # Prompts reutilizables (este incluido)
├── Proyecto001/                          # Generado con New-Project.ps1
└── Proyecto002/
```

Cada proyecto, tras crearse:

```
ProyectoNNN/
├── AGENTS.md            # Fuente única de instrucciones (agnóstica). Importa estándares de ../IA
├── CLAUDE.md            # Solo: @AGENTS.md  (+ particularidades de Claude Code)
├── .claude/
│   ├── settings.json    # "agent": "orquestador", permisos, hook SessionStart
│   ├── agents/
│   └── skills/
├── .ai/                 # Memoria y fuentes de verdad del proyecto (versionada en git)
├── src/  tests/  docs/  # Se crean cuando un issue lo necesite, no antes
└── .gitignore
```

## 3. Agentes

Crea cada agente como `.claude/agents/<nombre>.md` con frontmatter YAML (`name`, `description`, `tools`, `model`) y un cuerpo con: rol, responsabilidades, lo que NO hace, entradas, salidas, archivos de memoria que lee y escribe, y formato de respuesta al Orquestador. Usa alias de modelo (`opus`, `sonnet`, `haiku`) en lugar de IDs fijos para que no caduquen.

| Agente | Modelo | Por qué | Herramientas | Escribe en |
|---|---|---|---|---|
| **orquestador** | `opus` | Hilo principal: entiende al usuario, decide, delega, integra resultados. Necesita el mejor juicio. | Todas + Agent | `.ai/STATE.md`, `.ai/LOG.md`, estado de issues |
| **planificador** | `opus` | Descomponer, acotar alcance y definir criterios de aceptación es razonamiento puro; un mal plan cuesta más que el modelo. | Read, Grep, Glob, Write (solo `.ai/`) | `.ai/issues/`, `.ai/decisions/`, `.ai/ROADMAP.md` |
| **developer** | `sonnet` | Mejor relación calidad/coste para escribir código; ejecuta un plan ya acotado. | Read, Edit, Write, Bash, Grep, Glob | Código, tests unitarios, sección "Implementación" del issue |
| **explorer** | `haiku` | Solo lectura, búsquedas rápidas y baratas; devuelve resúmenes, no volcados. | Read, Grep, Glob, WebFetch, WebSearch | `.ai/knowledge/` |
| **tester** | `sonnet` | Verifica contra criterios de aceptación, ejecuta tests, piensa en casos límite. | Read, Bash, Grep, Glob, Write (solo `tests/` y el issue) | Tests, sección "Verificación" del issue |

Reglas obligatorias:
- El **orquestador** es el hilo principal (no un subagente): configúralo con `"agent": "orquestador"` en `.claude/settings.json` (o arrancando con `claude --agent orquestador`). Los subagentes no pueden invocar a otros subagentes; toda coordinación pasa por el orquestador.
- El orquestador **no escribe código de producto**; delega.
- El developer **no cambia el alcance** del issue; si detecta que algo falta, lo devuelve al orquestador.
- El tester **no corrige código de producción**; reporta fallos con reproducción.
- El explorer **nunca modifica** nada fuera de `.ai/knowledge/`.
- Cada subagente termina su trabajo con un bloque de resultado estándar: `Estado: OK | BLOQUEADO | FALLO`, `Resumen`, `Archivos tocados`, `Siguiente paso sugerido`.
- Bucle developer ↔ tester: máximo 2 reintentos; después el orquestador escala al usuario.

## 4. Memoria compartida (`.ai/`)

Archivos markdown versionados en git. Regla clave: **cada archivo tiene un único dueño que escribe**; el resto solo lee. Así se evitan conflictos y contradicciones.

```
.ai/
├── README.md            # Cómo usar esta memoria (para humanos y agentes)
├── PROJECT.md           # Visión, objetivo, alcance, stack. Dueño: orquestador (con el usuario)
├── STATE.md             # Estado actual en ≤40 líneas: issue en curso, último hecho, bloqueos. Dueño: orquestador
├── ROADMAP.md           # Próximos 3‑5 issues candidatos, nada más lejano. Dueño: planificador
├── LOG.md               # Diario append‑only: fecha, issue, qué se hizo. Dueño: orquestador
├── issues/
│   ├── _TEMPLATE.md
│   └── 0001-<slug>.md   # Un archivo por issue
├── decisions/           # ADRs: ADR-0001-<slug>.md (contexto, decisión, consecuencias). Dueño: planificador
├── knowledge/           # Hallazgos del explorer: arquitectura, APIs, dependencias. Dueño: explorer
└── glossary.md          # Términos del dominio
```

Plantilla de issue (`_TEMPLATE.md`) con frontmatter:

```yaml
---
id: 0001
title: ...
status: draft | ready | in-progress | in-review | done | blocked
type: feature | fix | chore | spike
size: S | M        # si sería L, el planificador debe partirlo
branch: issue/0001-slug
created: YYYY-MM-DD
---
```
Secciones: Contexto · Objetivo · Fuera de alcance · Criterios de aceptación (checklist verificable) · Plan técnico (planificador) · Implementación (developer) · Verificación (tester) · Notas.

Reglas de memoria:
- Todo agente lee `STATE.md` y el issue activo al empezar. Nada más por defecto (ahorro de contexto); el resto bajo demanda.
- Lo que no está en `.ai/` no existe: las decisiones importantes se registran como ADR.
- `STATE.md` se reescribe (no se acumula); `LOG.md` solo se añade.
- Hook `SessionStart` en `settings.json` que inyecte el contenido de `.ai/STATE.md` al iniciar sesión.

## 5. Flujo por issue

1. Usuario → orquestador: describe la necesidad.
2. Orquestador → explorer (solo si falta contexto) → resumen en `knowledge/`.
3. Orquestador → planificador: crea el issue `draft` con criterios de aceptación, tamaño S/M.
4. Orquestador → usuario: presenta el issue en 5‑10 líneas y pide aprobación → `ready`.
5. Orquestador crea la rama `issue/NNNN-slug` → developer implementa → `in-review`.
6. Orquestador → tester: valida cada criterio, ejecuta tests → OK o FALLO con reproducción.
7. Si OK: orquestador hace commit (Conventional Commits, referencia al issue), marca `done`, actualiza `STATE.md`, `LOG.md` y `ROADMAP.md`, y propone el siguiente issue.
8. Nunca se trabaja en dos issues a la vez.

## 6. Skills

Crea en `.claude/skills/<nombre>/SKILL.md` (frontmatter `name` y `description` claros para que se activen solos):
- `nuevo-issue`: crea un issue desde la plantilla con el siguiente número libre.
- `ejecutar-issue`: ejecuta los pasos 5‑7 del flujo para un issue `ready`.
- `cerrar-issue`: checklist de DoD, commit, actualización de memoria.
- `actualizar-memoria`: sincroniza `STATE.md`/`LOG.md` con la realidad.
- `estado`: resumen breve para el usuario de dónde estamos y qué sigue.

## 7. AGENTS.md del proyecto

Debe contener: propósito del proyecto (enlace a `.ai/PROJECT.md`), regla "solo se habla con el orquestador", resumen del flujo por issues, reglas de memoria, comandos de build/test (vacíos hasta que existan) y referencias a los estándares compartidos con rutas relativas `../IA/standards/*.md`. `CLAUDE.md` contiene `@AGENTS.md` y las importaciones `@../IA/standards/git.md` etc.

## 8. Entregables y forma de trabajar

1. Primero muéstrame el árbol final y un resumen de cada archivo; espera mi aprobación.
2. Después crea `IA/` completo, ejecuta `New-Project.ps1 -Name Proyecto001` y verifica que el proyecto resultante es correcto.
3. Inicializa git en `IA` y en `Proyecto001` con un primer commit (no hagas push).
4. Termina con: cómo arrancar el orquestador en Proyecto001 y un primer issue de ejemplo (`0001-setup-inicial`) en estado `draft`.

Mantén cada archivo conciso: instrucciones claras > texto largo. Los agentes deben poder leerse en menos de 2 minutos.
