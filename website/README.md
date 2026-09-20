# KumaPush website

Marketing page and docs for KumaPush, built with [Astro](https://astro.build).

```bash
pnpm install
pnpm dev      # http://localhost:4321
pnpm build    # static output in dist/
```

- `src/pages/index.astro` composes the homepage from `src/components/`.
- Docs are Markdown files in `src/content/docs/`. The sidebar is generated from each file's front matter (`title`, `description`, `group`, `groupOrder`, `order`).
- Colours are defined as CSS variables at the top of `src/styles/global.css` and mirror the app's `AccentColor` and `AppBackground` assets.
