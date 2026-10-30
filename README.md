# YOUR_PRESENTATION_TITLE

Reveal.js presentation built with Nix and Pandoc.

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled

## Getting Started

1. **Use this template** to create your own repository
2. Edit `slides.md` with your presentation content
3. Update the metadata in `slides.md` (author, title, date)
4. Replace `img/background.jpg` with your background image
5. Customize `slides.css` for your styling preferences
6. Update `flake.nix` to change the presentation name

## Build presentation

```sh
nix build
```

## Run locally

```sh
python -m http.server 8000 -d result/
```

Open http://localhost:8000 in your browser and press `s` to activate 'speaker notes'.

## GitHub Pages Deployment

This repository is configured with GitHub Actions to automatically build and deploy the presentation to GitHub Pages on every push to the `main` branch.

After enabling GitHub Pages in your repository settings (Settings → Pages → Source: GitHub Actions), your presentation will be available at:

`https://YOUR_USERNAME.github.io/YOUR_REPOSITORY_NAME/`

## Customization

- **slides.md**: Your presentation content in Markdown format
- **slides.css**: Custom CSS styles for your presentation
- **img/background.jpg**: Background image for parallax effect
- **flake.nix**: Nix build configuration

## Slide Syntax

Use `---` to separate slides. Example:

```markdown
## Slide Title

- Bullet point 1
- Bullet point 2

::: notes
Speaker notes go here.
:::

---

## Next Slide

Content for the next slide.
```

