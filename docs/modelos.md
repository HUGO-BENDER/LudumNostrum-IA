# Modelos por agente

Se usan **alias** (`opus`, `sonnet`, `haiku`) en el frontmatter de los agentes, no IDs con versión: así siempre apuntan al último modelo de cada familia y no caducan.

| Agente | Modelo | Motivo |
|---|---|---|
| Orquestador | `opus` | Juicio: interpretar al usuario, decidir qué delegar, integrar resultados. Es el agente con más impacto por token. |
| Planificador | `opus` | Acotar alcance y escribir criterios verificables es razonamiento puro. Un mal plan cuesta más que el modelo. |
| Developer | `sonnet` | Mejor relación calidad/coste programando un plan ya acotado. Es el que más tokens consume. |
| Tester | `sonnet` | Verificar criterios, ejecutar tests y pensar casos límite. |
| Explorer | `haiku` | Solo lectura, búsquedas rápidas y baratas; devuelve resúmenes. |

## Ajustes posibles

- **Ahorrar:** orquestador a `sonnet`. Se pierde algo de calidad al decidir y planificar el flujo.
- **Issue difícil:** el orquestador puede pedir al developer con `model: opus` puntualmente (se indica en el plan técnico del issue).
- **Exploración profunda** (arquitectura compleja, decisiones): el explorer puede subir a `sonnet`.

## Otras herramientas

Si se usa otra IA (Codex, Cursor, Gemini CLI…), la equivalencia es por capacidad: modelo de razonamiento alto para orquestador/planificador, modelo de código para developer/tester, modelo rápido para explorer.
