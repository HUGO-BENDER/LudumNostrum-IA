# ADR-0001: Arquitectura del framework de agentes

- **Fecha:** 2026-10-05
- **Estado:** Aceptado

## Contexto

Se quiere desarrollar varios proyectos con ayuda de IA usando una misma forma de trabajar: un único interlocutor, agentes especializados, memoria persistente y desarrollo incremental por issues.

## Decisión

1. Repo `IA/` como framework; proyectos como repos hermanos (`../ProyectoNNN`).
2. La plantilla de agentes y skills se **copia** a cada proyecto (versionado por proyecto); los estándares se **importan** por ruta relativa.
3. `AGENTS.md` como fuente única de instrucciones; `CLAUDE.md` solo lo importa.
4. Orquestador como hilo principal (`"agent": "orquestador"`), porque los subagentes no pueden invocar a otros subagentes.
5. Memoria en `.ai/` (markdown versionado) con dueño único por archivo.
6. Issues locales en markdown (agnóstico, sin depender de GitHub/GitLab). Se puede sincronizar con un gestor externo más adelante.

## Consecuencias

- (+) Cada proyecto es autónomo y reproducible; el framework evoluciona sin romperlos.
- (+) Toda la historia de decisiones vive junto al código.
- (−) Actualizar agentes en proyectos existentes requiere ejecutar `Sync-Agents.ps1`.
- (−) Los issues locales no tienen interfaz web; aceptable mientras el equipo sea pequeño.
