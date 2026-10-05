# Arquitectura

## Principios

1. **Un único interlocutor.** El usuario solo habla con el orquestador.
2. **Responsabilidad única por agente.** Cada agente hace una cosa y sabe qué *no* hace.
3. **Memoria explícita.** Los agentes no comparten contexto entre sí, solo archivos. Lo que no está en `.ai/` no existe.
4. **Incremental.** Un issue a la vez, pequeño (S/M), con criterios de aceptación verificables.
5. **Agnóstico donde se puede.** `AGENTS.md` es la fuente de instrucciones (estándar abierto). `CLAUDE.md` solo lo importa.

## Agentes

```
                    ┌──────────┐
                    │ Usuario  │
                    └────┬─────┘
                         │ (única conversación)
                  ┌──────▼───────┐
                  │ Orquestador  │  hilo principal · opus
                  └┬────┬────┬──┬┘
        ┌──────────┘    │    │  └───────────┐
┌───────▼──────┐ ┌──────▼─┐ ┌▼─────────┐ ┌──▼─────┐
│ Planificador │ │Explorer│ │Developer │ │ Tester │
│    opus      │ │ haiku  │ │ sonnet   │ │ sonnet │
└───────┬──────┘ └───┬────┘ └────┬─────┘ └───┬────┘
        └────────────┴─────┬─────┴───────────┘
                     ┌─────▼─────┐
                     │   .ai/    │  memoria · fuente de verdad
                     └───────────┘
```

| Agente | Hace | No hace |
|---|---|---|
| Orquestador | Entiende al usuario, decide, delega, integra, hace commits, mantiene `STATE.md` y `LOG.md` | Escribir código de producto |
| Planificador | Crea issues pequeños con criterios de aceptación, ADRs, roadmap corto | Implementar; planificar a largo plazo |
| Explorer | Investiga código, documentación y web; resume en `knowledge/` | Modificar nada fuera de `knowledge/` |
| Developer | Implementa un issue `ready` siguiendo su plan, con tests unitarios | Cambiar el alcance; cerrar issues |
| Tester | Verifica cada criterio de aceptación, ejecuta tests, busca casos límite | Corregir código de producción |

## Por qué el orquestador es el hilo principal

En Claude Code los subagentes **no pueden invocar a otros subagentes**. Por eso el orquestador no es un subagente sino la sesión principal, configurada con `"agent": "orquestador"` en `.claude/settings.json`. Toda coordinación pasa por él, lo que además da trazabilidad: cada delegación y su resultado quedan en una sola conversación.

## Framework y proyectos

- `IA/template/` se **copia** a cada proyecto: agentes y skills quedan versionados con el proyecto y no se rompen si el framework evoluciona.
- `IA/standards/` se **importa** desde cada proyecto (`@../IA/standards/...`): una sola fuente para convenciones comunes.
- `Sync-Agents.ps1` actualiza un proyecto a la última versión del framework de forma explícita.

## Contrato de respuesta de los subagentes

Todo subagente termina con:

```
Estado: OK | BLOQUEADO | FALLO
Resumen: <2-5 líneas>
Archivos tocados: <lista>
Siguiente paso sugerido: <una línea>
```
