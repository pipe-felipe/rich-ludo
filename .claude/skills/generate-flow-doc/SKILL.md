---
name: generate-flow-doc
description: Generate detailed documentation for a specific data flow or feature of the RichLudo app, tracing UI -> ViewModel -> UseCase -> Repository -> Service -> SQLite (and back), and write it as a new file under docs/. Use when the user asks to "document this flow", "write docs for X feature", "trace how Y works end to end", or wants a new docs/*.md file describing a feature.
---

# Generate flow documentation

Document a specific flow or feature of the RichLudo Flutter project. The user names the flow or feature to document (e.g. "recurring transaction deletion", "database backup/restore", "monthly transaction loading").

## Steps

1. **Read every file involved in the flow**: model (`lib/domain/model/`), mapper, service (`lib/data/services/`), repository (`lib/data/repository/`), use case (`lib/domain/usecase/`), viewmodel (`lib/presentation/viewmodel/`), and any UI widgets/screens that trigger or display it. Search broadly before writing anything — do not document from assumptions.
2. **Trace the full data path** from UI -> ViewModel -> UseCase -> Repository -> Service -> Database, and back to the UI.
3. **Check `docs/` first.** Do not duplicate content already covered in `docs/project-map.md`, `docs/monthly-data-flow.md`, `docs/database.md`, `docs/test-map.md`, or `docs/known-issues.md` — link to them with relative Markdown links instead of repeating them.
4. **Write a new Markdown file inside `docs/`**, lowercase kebab-case naming (e.g. `docs/recurring-deletion.md`), with this structure:
   - **Overview** — one paragraph on what the flow does.
   - **Architecture Diagram** — ASCII diagram of the layer-by-layer path (see existing docs for the house style).
   - **Data Model** — table of fields, types, and descriptions touched by the flow.
   - **Layer-by-Layer Breakdown** — for each layer (UI, ViewModel, UseCase, Repository, Service, DB): file/class involved, method called, data in/out.
   - **Edge Cases / Rules** — business logic, filters, or special conditions (e.g. recurring start/end months, exclusions, cache keys).
   - **Related Tests** — existing test files that already cover this flow; note any gap you find instead of writing the missing test yourself unless asked.
5. **Write in English**, regardless of the language of the request — this matches the rest of `docs/`.
6. Follow the conventions in `AGENTS.md` (layer boundaries, `Result<T>`, `Command<T>`, Provider-based DI) when describing code.
7. If the README's "Internal documentation" list doesn't yet link the new file, add a line there.

Report the path of the file you wrote when done.
