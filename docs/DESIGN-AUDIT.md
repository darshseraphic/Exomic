# Exomic website design audit

## Reference pattern observed

The supplied DoingNow screenshots use a restrained, editorial landing-page system rather than a conventional SaaS dashboard. The hierarchy comes from large black typography, small uppercase labels, generous white space, thin borders, repeated phone mockups and a small number of high-contrast cards.

The desktop layout is a sequence of short, strongly separated stories: hero + phone, compact metrics, feature intro, visual collage, utility section, detail section, comparison/table, FAQ, then a large black final CTA. The mobile layout preserves the same order but collapses everything to a single column and lets the phone mockups become the primary visual anchors.

## Exomic translation

- Brand voice: technical, quiet, exact; avoid generic fintech buzzwords.
- Visual system: off-white paper background, black text, thin gray rules, one alert red.
- Content structure: privacy-first architecture → five workspaces → liquidity formula → security → model comparison → FAQ → final CTA.
- Imagery: use the supplied Exomic 1–10 app screenshots as the visual system, with the mapping recorded in `README.md`.
- Motion: modest reveal motion, immediate link/button feedback, theme persistence, and reduced-motion support.
- Navigation: simple anchor navigation plus separate Privacy, Terms, Security and Contact pages.

## Source notes

Product content is grounded in the public Exomic repository documentation. The architecture notes explicitly describe local Hive storage, AES-256 encrypted boxes, Riverpod-driven reactive updates, a five-item bottom navigation (Ledger, Budget, Pools, Utility, Console), and a privacy-first offline operating model.
