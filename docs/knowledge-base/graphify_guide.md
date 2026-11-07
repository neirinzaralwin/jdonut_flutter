# Graphify — local knowledge graph

Same setup as `vint_flutter` (Claude Code / Cowork side): npm package `@sentropic/graphify` installed locally in `.graphify-local/`, output in `.graphify/` (git-ignored).

## Use it FIRST when
- You don't know which files are involved: "how does X work", "what calls Y", "trace A → B", cross-module impact, entering an unfamiliar feature.

```bash
bash scripts/graphify.sh query "How does the router guard read the session?"
bash scripts/graphify.sh path "HomePage" "AppDatabase"
bash scripts/graphify.sh explain "MemberRepository"
```

## SKIP it when
- Running commands, git, mock server, lint/test.
- You already know the file and are doing a line-level edit.
- Reading docs in `docs/`.
- `.graphify/graph.json` doesn't exist yet → build first (below) or just read files.

## Keep it fresh
```bash
bash scripts/graphify.sh update .                 # after code changes (AST only, no API cost)
bash scripts/graphify.sh rebuild                  # forced full code rebuild, no LLM steps
```
Include this when/skip rule in every subagent prompt that explores code.

## Notes
- If `graphify` (Python `graphifyy`, Cursor side) is on your PATH, it writes `graphify-out/` instead — a different tool and schema. Don't mix reports from the two.
- Excluded paths: `.graphifyignore` (platform folders, generated Dart, node_modules, assets).
