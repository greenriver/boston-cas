## CSS Architecture and Client Theming

### How it works

`application.css` compiles once for all clients. Brand colors are defined as Sass variables in
`app/assets/stylesheets/settings/_colors.scss` and exposed as CSS custom properties in a `:root`
block near the top of `app/assets/stylesheets/application.scss.erb`:

```scss
:root {
  --brand-primary:    #{$brand-primary};
  --brand-primary-l:  #{$brand-primary-l};
  // ... etc.
  --bs-primary:       #{$primary};
  --bs-primary-rgb:   #{to-rgb($primary)};
  // ... etc.
}
```

All custom component styles reference these CSS variables (`var(--brand-primary)`) rather than
hard-coded Sass variable values. Bootstrap 5's own components also use CSS custom properties
internally, so they respond to the same overrides.

### Per-client color overrides

Each client that diverges from the default color palette has a thin CSS file in
`app/assets/stylesheets/client_themes/` that overrides the `:root` custom properties:

These files contain only `:root { --brand-primary: ...; ... }` and very simple overrides. No Sass compilation is required — they are plain CSS served alongside `application.css`.

The layout loads the client theme file at runtime based on `ENV['CLIENT']`
(`app/views/layouts/application.html.haml`), checking once per rails boot to see if the file exists.

### Adding a new client theme

1. Create `app/assets/stylesheets/client_themes/{client_name}.css` with `:root` overrides for
   whichever brand variables differ from the defaults.
2. Add the new file to the precompile list in `config/initializers/assets.rb`.
3. Set `ENV['CLIENT']` to `{client_name}` in the client's deployment environment.

---

## Asset Precompilation

`config/initializers/assets.rb` registers all assets that Sprockets must precompile beyond the
defaults (`application.js`, `application.css`):

- `print.css` — print stylesheet
- `theme/styles/*.css` — operator-uploaded theme style overrides (loaded from S3 at deploy time)
- `client_themes/*.css` — per-client CSS variable override files (one per client listed above)

Assets are precompiled **once** as part of the Docker image build. No per-client or
per-environment variants are produced.

---

## Asset Checksumming and S3 Sync

`bin/asset_checksum` and `bin/sync_app_assets.rb` still run at deploy time. They handle
per-client **image and logo assets** (not CSS) that are stored in S3 and pulled into the
running container. These are unrelated to CSS compilation and continue to work the same way.

`config/deploy/docker/assets/entrypoint.sh` runs `bin/sync_app_assets.rb` when a container
starts, downloading any client-specific image overrides from S3.
