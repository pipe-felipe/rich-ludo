---
mode: 'agent'
description: 'Generate detailed documentation for a specific flow/feature of the project'
---

# Generate Flow Documentation

You are documenting the RichLudo Flutter project. The user will specify a flow or feature to document.

## Instructions

1. **Read** all files involved in the flow (model, mapper, service, repository, use case, viewmodel, UI widgets/screens)
2. **Trace** the full data path from UI → ViewModel → UseCase → Repository → Service → Database (and back)
3. **Write** a Markdown file inside `docs/` with the following structure:

   - **Overview**: One paragraph explaining what the flow does
   - **Architecture Diagram**: ASCII diagram showing the layer-by-layer path
   - **Data Model**: Tables listing all fields, types, and descriptions
   - **Layer-by-Layer Breakdown**: For each layer (UI, ViewModel, UseCase, Repository, Service, DB), describe:
     - Which file/class is involved
     - What method is called
     - What data goes in and comes out
   - **Edge Cases / Rules**: Any business logic, filters, or special conditions
   - **Related Tests**: List test files that cover this flow

4. **Language**: Always write in English
5. **File naming**: Use lowercase kebab-case (e.g., `docs/recurring-deletion.md`)
6. **Do NOT** duplicate content already documented in other `docs/*.md` files — reference them instead

## Project context

- Architecture: Clean Architecture + MVVM
- Layers: `presentation/` → `domain/` → `data/`
- Error handling: `Result<T>` sealed class (`Ok<T>` | `Error<T>`)
- Async ops: `Command<T>` pattern
- DB: SQLite via sqflite
- DI: Provider in `main.dart`
- Refer to `AGENTS.md` for code conventions
