---
name: experiment-design
description: Design a sound product experiment or A/B test. Use when planning an experiment, an A/B test, or how to validate a feature's impact.
---

# Experiment Design

## Produce
- **Hypothesis** - "We believe [change] will cause [effect] for [segment] because [reasoning]." It must be falsifiable.
- **Variants** - control and treatment(s); change one thing where possible.
- **Primary metric** - the single decision metric, defined precisely. Plus guardrail metrics.
- **Power** - rough sample size and runtime given the baseline rate and the minimum effect worth detecting (MDE). If traffic cannot detect the MDE in a reasonable time, say so and propose an alternative (qualitative, painted-door, sequential test).
- **Decision rule** - pre-commit what result ships, kills, or iterates. Decide before you look.

## Rules
- One primary metric. Watching ten metrics guarantees a false positive.
- No peeking and no moving the goalposts. State the stop condition up front.
- Pair the quantitative test with the qualitative "why" whenever you can.
