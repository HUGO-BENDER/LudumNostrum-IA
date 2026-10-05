# Estándar git

## Ramas

- `main`: siempre estable.
- `issue/NNNN-slug`: una rama por issue, creada desde `main`.
- Merge a `main` solo con el issue verificado por el tester y con aprobación del usuario.

## Commits — [Conventional Commits](https://www.conventionalcommits.org/es/v1.0.0/)

```
<tipo>(<ámbito opcional>): <descripción en imperativo, minúsculas>

<cuerpo opcional: el porqué>

Refs: #NNNN
```

Tipos: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci`, `perf`.

Ejemplos:
- `feat(auth): add login form validation`
- `docs(ai): close issue 0003 and update state`

## Reglas

- Commits pequeños y con sentido propio.
- Los cambios en `.ai/` se commitean junto con el trabajo del issue o en un commit `docs(ai): ...`.
- Nunca `push --force` a `main`. Nunca saltarse hooks.
- Push y PR solo cuando el usuario lo pida.
