# The Art of Ricing with Nix: Declarative, Repeatable Desktop Aesthetics for the *nix OSs

[Presentation](https://gotha.github.io/2026-openfest-ricing-with-nix/) and code for my workshop for OpenFest 2026.


## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled

## Build presentation

```sh
nix build
```

## Run locally

```sh
python -m http.server 8000 -d result/
```

Open http://localhost:8000 in your browser and press `s` to activate 'speaker notes'.
