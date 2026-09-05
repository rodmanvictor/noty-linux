

## Code Documentation


- Document code in a style close to PHPDoc: every non-trivial module, class, public function, method, and complex data contract should have a structured docblock/docstring with purpose, parameters, return value, raised errors, and relevant side effects.
- Keep documentation useful and current. Do not add empty boilerplate that repeats the function name or obvious type hints.
- When changing behavior, update the related docblocks/docstrings in the same change.



## Documentation Rules

Start every task by checking [docs/index.md](docs/index.md). Treat it as the top-level documentation map, not as the place for detailed notes. Then open the relevant folder `index.md` before changing that area.

All durable project documentation must live under `docs/` as separate Markdown files grouped by logical folder.
Documentation uses a two-level index system:

- `docs/index.md` links only to folder indexes.
- Every logical docs folder must have its own `index.md`.
- Each folder `index.md` links to the detailed Markdown files inside that folder.
- Every link in `docs/index.md` and every folder `index.md` must include a short description after the link. Use the format `- [Title](file.md): description`. Do not leave bare link lists without descriptions.

When adding or changing a feature, task, service integration, command, schema, scoring rule, runbook, or operational finding:

1. Create or update the most specific Markdown file under the right `docs/` folder.
2. Update that folder's `index.md` in the same task so the new or changed file is discoverable.
3. Update [docs/index.md](docs/index.md) only when adding, removing, or renaming a documentation folder.
4. Do not bury detailed documentation inside `AGENTS.md` or `docs/index.md`.
5. If a new documentation category becomes necessary, create a logical folder and add it to the index.
6. Keep index descriptions current when a file's purpose changes.
7. Создай скрипт, который будет проверять, что бы были `index.md` файлы в папках, что бы каждый `index.md` описывал файлы в его иерархии и запускай его через Run `npm run docs:check`, когда надо проверить документацию или когда мы сильно переписываем документацию.
8. В папке docs хранить только устойчивое знание о системе. Для планов, чеклистов и т.д. используй папку plans
Use one file per major function, task, or service. Prefer names like `docs/pipeline/scoring.md`, `docs/services/rdrr.md`, or `docs/operations/live-collection.md`.



### 2. PHPDoc — обязательно для всех классов и методов
Каждый PHP класс, метод и свойство должны иметь PHPDoc-комментарий
