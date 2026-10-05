# Flujo por issues

## Estados

```
draft ──► ready ──► in-progress ──► in-review ──► done
  │                     ▲               │
  │                     └── (FALLO, ≤2) ┘
  └──────────────► blocked ◄────────────┘
```

| Estado | Significa | Quién lo pone |
|---|---|---|
| `draft` | Redactado por el planificador, pendiente de aprobación | Planificador |
| `ready` | Aprobado por el usuario | Orquestador |
| `in-progress` | Developer trabajando en la rama `issue/NNNN-slug` | Orquestador |
| `in-review` | Implementado, pendiente del tester | Orquestador |
| `done` | Verificado, commit hecho, memoria actualizada | Orquestador |
| `blocked` | Necesita decisión o información externa | Orquestador |

## Pasos

1. **Necesidad.** El usuario describe qué quiere al orquestador.
2. **Contexto (opcional).** Si falta información, el orquestador lanza al explorer → `.ai/knowledge/`.
3. **Plan.** El planificador crea `.ai/issues/NNNN-slug.md` en `draft`: objetivo, fuera de alcance, criterios de aceptación, plan técnico. Si el tamaño sería L, lo parte en varios issues.
4. **Aprobación.** El orquestador lo resume al usuario en 5–10 líneas. Con el visto bueno → `ready`.
5. **Implementación.** El orquestador crea la rama, marca `in-progress` y lanza al developer.
6. **Verificación.** Marca `in-review` y lanza al tester. Si hay FALLO vuelve al developer (máximo 2 reintentos; después se escala al usuario).
7. **Cierre.** Commit(s) con Conventional Commits y referencia `#NNNN`, merge a `main` si el usuario lo aprueba, `done`, actualización de `STATE.md`, `LOG.md` y `ROADMAP.md`, y propuesta del siguiente issue.

## Reglas

- Un solo issue `in-progress` a la vez.
- Tamaño S (≤ medio día de trabajo humano) o M (≤ 1–2 días). L no existe: se parte.
- Tipo `spike` para investigar sin producir código de producto; su salida es conocimiento o un ADR.
- Los criterios de aceptación son verificables por el tester (comando, test o comprobación concreta), nunca "funciona bien".
