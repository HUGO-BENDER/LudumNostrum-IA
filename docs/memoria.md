# Memoria del proyecto (`.ai/`)

Los agentes no comparten contexto entre ejecuciones ni entre sí. La memoria es un directorio de markdown **versionado en git** dentro de cada proyecto.

## Estructura y dueños

| Archivo | Contenido | Dueño (único que escribe) | Estilo |
|---|---|---|---|
| `PROJECT.md` | Visión, objetivo, alcance, stack | Orquestador (con el usuario) | Se edita poco |
| `STATE.md` | Dónde estamos: issue activo, último hecho, bloqueos, siguiente paso | Orquestador | Se **reescribe**, ≤ 40 líneas |
| `ROADMAP.md` | Próximos 3–5 issues candidatos | Planificador | Se reescribe |
| `LOG.md` | Diario: fecha, issue, qué se hizo | Orquestador | **Append-only** |
| `issues/NNNN-slug.md` | Un issue | Planificador (plan), Developer (Implementación), Tester (Verificación), Orquestador (`status`) | Por secciones |
| `decisions/ADR-NNNN-slug.md` | Decisiones de arquitectura | Planificador | Inmutables; se reemplazan con otro ADR |
| `knowledge/*.md` | Hallazgos del explorer | Explorer | Uno por tema |
| `glossary.md` | Términos del dominio | Planificador | Se amplía |

El dueño único evita que dos agentes se contradigan o se pisen. En los issues, cada agente escribe **solo en su sección**.

## Lectura

- Al empezar, todo agente lee `STATE.md` y el issue activo. El resto solo bajo demanda (ahorro de contexto).
- El hook `SessionStart` inyecta `STATE.md` en cada sesión nueva del orquestador.

## Reglas de oro

1. Si no está en `.ai/`, no se decidió.
2. Hechos, no intenciones: `STATE.md` describe la realidad actual.
3. Breve: cada archivo debe leerse en menos de 2 minutos. Si crece, se divide.
4. Enlaces relativos entre archivos (`../issues/0003-login.md`).
5. Fechas en ISO `YYYY-MM-DD`.
