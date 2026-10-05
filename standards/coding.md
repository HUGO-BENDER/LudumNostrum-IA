# Estándar de código

- **Idioma:** identificadores, nombres de archivo y mensajes de log en inglés. Documentación y comentarios para humanos en español.
- **Simplicidad primero:** la solución más simple que cumpla los criterios de aceptación. Nada de abstracciones "por si acaso".
- **Coherencia:** el código nuevo se parece al código que lo rodea (estilo, nombres, patrones).
- **Formato automático:** cada proyecto define su formatter/linter en el issue de setup y se respeta siempre.
- **Tests:** toda lógica nueva o corregida lleva test. Los tests describen comportamiento, no implementación.
- **Errores:** nunca se silencian. Se manejan o se propagan con contexto.
- **Secretos:** jamás en el repo. Variables de entorno y `.env` en `.gitignore`; se versiona `.env.example`.
- **Dependencias:** cada dependencia nueva se justifica en el plan técnico del issue.
- **Comentarios:** explican el *porqué*, no el *qué*.
