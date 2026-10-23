---
name: Rómpelo Dynamic Party System
colors:
  surface: '#fdf7ff'
  surface-dim: '#ded6f1'
  surface-bright: '#fdf7ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f7f1ff'
  surface-container: '#f2ebff'
  surface-container-high: '#ece4ff'
  surface-container-highest: '#e7dff9'
  on-surface: '#1d192c'
  on-surface-variant: '#42474e'
  inverse-surface: '#322e42'
  inverse-on-surface: '#f5eeff'
  outline: '#73777f'
  outline-variant: '#c3c6d0'
  surface-tint: '#3b608c'
  primary: '#3b608c'
  on-primary: '#ffffff'
  primary-container: '#95baeb'
  on-primary-container: '#224a75'
  inverse-primary: '#a4c9fb'
  secondary: '#b62416'
  on-secondary: '#ffffff'
  secondary-container: '#fd5842'
  on-secondary-container: '#5b0200'
  tertiary: '#635e51'
  on-tertiary: '#ffffff'
  tertiary-container: '#beb7a8'
  on-tertiary-container: '#4c483c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d2e4ff'
  primary-fixed-dim: '#a4c9fb'
  on-primary-fixed: '#001c37'
  on-primary-fixed-variant: '#204873'
  secondary-fixed: '#ffdad4'
  secondary-fixed-dim: '#ffb4a8'
  on-secondary-fixed: '#410100'
  on-secondary-fixed-variant: '#920400'
  tertiary-fixed: '#e9e2d1'
  tertiary-fixed-dim: '#cdc6b6'
  on-tertiary-fixed: '#1e1b11'
  on-tertiary-fixed-variant: '#4b473a'
  background: '#fdf7ff'
  on-background: '#1d192c'
  surface-variant: '#e7dff9'
typography:
  headline-xl:
    fontFamily: Outfit
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 46px
    letterSpacing: -0.03em
  headline-xl-mobile:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 38px
    letterSpacing: -0.025em
  headline-lg:
    fontFamily: Outfit
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Outfit
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Outfit
    fontSize: 19px
    fontWeight: '700'
    lineHeight: 25px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Outfit
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 26px
  body-md:
    fontFamily: Outfit
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Outfit
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Outfit
    fontSize: 16px
    fontWeight: '700'
    lineHeight: 22px
  label-md:
    fontFamily: Outfit
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
  label-sm:
    fontFamily: Outfit
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.375rem
  space-sm: 0.75rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.25rem
---

## Brand & Style

This design system drives a vibrant, in-person party game experience engineered for rapid comprehension, physical pass-and-play phone handling, and joyous social friction. The design movement marries **Chunky Pop Tactility** with **Soft Modern Playfulness**—celebrating physical toy-like dimensionality, squishy feedback, bold profiles, and exaggerated pill silhouettes.

### Emotional Response & Principles
- **Effortless Energy:** High visual contrast and punchy weights eliminate cognitive drag in loud, dim party rooms without feeling clinical or aggressive.
- **Physical & Chunky:** Buttons and interactive cards feature bottom-weighted bevel offsets (tactile hard shadows) that compress downward on press, providing tactile certainty without needing skeuomorphic gradients.
- **Friendly Natural Expression:** Strictly avoid all-caps lock shouting. Typography relies on natural sentence casing rendered in ultra-bold geometric forms to retain warmth and approachability.
- **Game Mode Differentiation:** The system pivots between ambient social flow (airy heavenly sky blue and rich milk hues) and intense action sprints like Charadas (deep high-stakes wine crimson).

## Colors

The palette balances airy buoyancy with visceral game tension:

- **Primary Sky Blue (`#95baeb`):** The ambient heart of the UI. Used for root app canvas backdrops, main header wraps, positive navigation anchors, and joyful illustrations.
- **Deep Wine (`#930400`):** The adrenaline driver. Reserved for high-stakes action prompts, Charadas timers, critical turn alerts, buzzer buttons, and buzzer tactile drops.
- **Milk & Warm Light Neutral (`#fff7e6`, `#fdfbf7`, `#ffffff`):** Soft, non-glare surface containers that hold question prompts, rules cards, score tiles, and player trays.
- **Deep Slate/Plum (`#1f1b2e` & `#2d1822`):** Grounding ink. Supplies strong contrast ratios across all display typography, body copy, and structural outlines. Replaces harsh pitch black with a rich, organic tone.
- **Tactile Depth Shades:** Chunky button offsets use darkened structural drops: `#6f97ce` under primary blue elements, and `#5c0200` under deep wine elements.

## Typography

The single typeface family across the entire experience is **Outfit**. Its geometric curves, open counters, and high x-height create immediate clarity across room lengths.

### Rules of Usage
- **Natural Casing Mandatory:** Never render headlines or long-form copy in all-caps. Capitalization is restricted to Title Case or Sentence Case to keep game instructions friendly and conversational.
- **Optical Tightening:** Display headers use tighter negative tracking (`-0.02em` to `-0.03em`) to cluster words as cohesive, punchy graphic shapes.
- **Numeric Clarity:** Game scores, timers, and point tallies utilize tabular figures with bold weights (`700` or `800`) to prevent visual jittering as clocks tick down.

## Layout & Spacing

The layout is optimized primarily for single-screen handheld interactions: quick finger tap zones, large pass-and-play margins, and thumbs-reach target regions.

### Screen Adaptability & Grid Model
- **Mobile First (Fluid Grid):** Operates on a 4-column dynamic grid with `1.25rem` (`20px`) outer safe margins and `1rem` (`16px`) gutters. Interactive elements span all 4 columns for full-width thumb strikes or 2 columns for side-by-side decisions (e.g., "Pass" vs. "Correct").
- **Tablet / Group Display Mode:** Constrains max content container width to `540px` centered on screen, preventing cards and buttons from stretching into awkward horizontal bands when placed on a table between players.
- **Vertical Rhythm:** Game prompts and card surfaces occupy prime vertical center view, while high-velocity action buttons are pinned within the bottom thumb zone with at least `1rem` clearance above platform home indicators.

## Elevation & Depth

This system avoids blurred, realism-less drop shadows in favor of **Chunky Solid Offsets** inspired by board game tiles and tactile rubber stamps.

- **The Chunky Offset (Card & Button Depth):** Elements feature an opaque solid edge on the bottom axis. 
  - *Standard tactile layer:* `box-shadow: 0 4px 0 0 rgba(31, 27, 46, 0.12);`
  - *Primary action button:* `box-shadow: 0 5px 0 0 #6f97ce;`
  - *Action buzzer / Wine button:* `box-shadow: 0 6px 0 0 #5c0200;`
- **Active / Pressed State:** On press/touch, the element translates downward along the Y-axis (`transform: translateY(4px);`) and the offset collapses to `0px` or `1px`, visually mimicking an arcade push-button switch.
- **Floating Modals & Floating Cards:** Layering over full-screen game states uses a `2px` crisp border in slate/plum (`#1f1b2e` at 15% opacity) accompanied by an exaggerated physical shadow: `0 12px 0 0 rgba(31, 27, 46, 0.18)`.

## Shapes

The shape system is hyper-rounded and pill-dominated (`roundedness: 3`), ensuring that every corner feels friendly, bouncy, and immune to sharp abrasiveness.

- **Pill Badges & Buttons:** Buttons, tab switches, and status badges utilize the full pill geometry (`rounded-full` / `9999px`).
- **Main Cards & Prompt Boards:** Primary play boards and question trays utilize `rounded-3xl` (`1.75rem` - `2rem`) to produce a chunky, toy-like appearance.
- **Nested Inner Containers:** Sub-elements such as score counters, timers, and input modules inside larger cards adopt `rounded-2xl` (`1rem` - `1.25rem`) to maintain proportional concentric curvature.

## Components

### Buttons
- **Tactile Chunky Button (Primary Action):** Full pill silhouette, `min-height: 58px`, `font-weight: 700`. Colored in Wine (`#930400`) with white text or Sky Blue (`#95baeb`) with dark plum text (`#1f1b2e`). Built with a `0 5px 0 0` solid base-tone drop shadow that translates down on `:active`.
- **Ghost / Ambient Button:** Pill boundary with a `2px` solid border (`#1f1b2e` at 20% opacity), transparent background, and no shadow offset.

### Game Cards (Prompt & Charadas Surfaces)
- Rendered in Milk (`#fff7e6`) or Warm Ivory (`#fdfbf7`) with `rounded-3xl` curves.
- Features an ultra-subtle border (`1.5px solid rgba(31, 27, 46, 0.08)`) and a `0 8px 0 0 rgba(31, 27, 46, 0.08)` physical bottom drop.
- Generous internal padding (`space-lg` / `24px`) keeps party game phrases readable from a 3-foot viewing distance.

### Chips & Category Pills
- Pill-shaped counters and tags (`rounded-full`) using soft pastel tinted fills (e.g., Sky Blue at 25% opacity or warm apricot).
- Text styled using `label-md` in deep plum (`#1f1b2e`). No drop shadows, preserving an agile and secondary presence against primary cards.

### Input Fields & Name Entry
- Background in Milk (`#fff7e6`), container rounded to `rounded-2xl`.
- Height of `56px` with inner padding of `16px`. Deep plum text cursor.
- Focused state gains a solid `2.5px` border in Primary Sky Blue with an immediate slight pop lift (`transform: translateY(-2px)`).

### Selection Controls (Checkboxes & Radios)
- **Selection Pill Tile:** Instead of bare check boxes, option selections use entire pill or `rounded-2xl` tiles. Unselected state is white with Milk border; selected state fills with Sky Blue or Wine, with white bold text and an animated spring scale bounce (`scale(1.02)`).

### Action Buzzer / Pass-Fail Split Trigger
- Side-by-side full-bleed responsive cards at the base of the screen: Left side "Pass" (Milk cream base with slate text, 4px shadow drop); Right side "Correct!" (Deep Wine base with crisp white text, 6px crimson shadow drop). Large icon/text combinations formatted for rapid thumb tapping without looking away from fellow players.