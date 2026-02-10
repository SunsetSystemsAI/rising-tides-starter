---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, mockups, prototypes, or when styling/beautifying any web UI). Generates creative, polished, accessible code and UI design that avoids generic AI aesthetics.
license: Complete terms in LICENSE.txt
mcp: context7
---

## MCP Integration: Context7

**Before building**, use context7 to fetch current framework documentation:

```
Fetch tailwindcss documentation
Fetch Next.js App Router documentation
Fetch shadcn/ui documentation
Fetch framer-motion documentation
```

**Framework-specific fetches:**
- React projects: `Fetch react 19 documentation`
- Vue projects: `Fetch vue 3 documentation`
- Svelte projects: `Fetch svelte documentation`

**Why?** Frameworks update frequently. Context7 ensures you use current syntax, especially for Tailwind v4, Next.js 14+, and other rapidly-evolving tools.

---

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details, creative choices, and accessibility.

The user provides frontend requirements: a component, page, application, or interface to build. They may include context about the purpose, audience, or technical constraints.

## Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:
- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. There are so many flavors to choose from. Use these for inspiration but design one that is true to the aesthetic direction.
- **Constraints**: Technical requirements (framework, performance, accessibility, WCAG level).
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.

Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:
- Production-grade and functional
- Visually striking and memorable
- Cohesive with a clear aesthetic point-of-view
- Meticulously refined in every detail
- Accessible to all users

## Frontend Aesthetics Guidelines

Focus on:
- **Typography**: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics; unexpected, characterful font choices. Pair a distinctive display font with a refined body font.
- **Color & Theme**: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes. Ensure color contrast meets WCAG 4.5:1 minimum for text.
- **Motion**: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise. Respect `prefers-reduced-motion`.
- **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.
- **Backgrounds & Visual Details**: Create atmosphere and depth rather than defaulting to solid colors. Add contextual effects and textures that match the overall aesthetic. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, custom cursors, and grain overlays.

NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes (particularly purple gradients on white backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character.

Interpret creatively and make unexpected choices that feel genuinely designed for the context. No design should be the same. Vary between light and dark themes, different fonts, different aesthetics. NEVER converge on common choices (Space Grotesk, for example) across generations.

**IMPORTANT**: Match implementation complexity to the aesthetic vision. Maximalist designs need elaborate code with extensive animations and effects. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.

Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.

## Accessibility

Every design must be usable by everyone:

- **Semantic HTML5**: Use proper elements (`header`, `nav`, `main`, `footer`, `section`, `article`). Maintain correct heading hierarchy (h1 through h6).
- **Keyboard navigation**: All interactive elements reachable via Tab. Visible focus indicators on every focusable element. Logical tab order. No keyboard traps.
- **ARIA**: Add landmarks, labels, and live regions where semantic HTML alone is insufficient. Use `aria-expanded`, `aria-modal`, `aria-required`, `aria-describedby` on interactive components.
- **Forms**: Every input has an associated `<label>`. Required fields use `aria-required="true"`. Error messages use `role="alert"` and are linked via `aria-describedby`.
- **Skip links**: Include a "Skip to main content" link as the first focusable element.
- **Screen readers**: Alt text on all images. Dynamic content changes announced via ARIA live regions.

Accessibility is not optional and does not conflict with bold design. The most creative interfaces can also be the most inclusive.

## Image Strategy

Images make or break a page. Never leave a page visually barren:

- **Always include images** on landing pages, hero sections, and marketing pages. A page without images looks unfinished.
- **Use WebP format** for all raster images. It provides 25-35% smaller files than JPEG/PNG at equivalent quality.
- **Lazy-load** all images below the fold with `loading="lazy"`. Only the hero/above-fold image should be eager-loaded.
- **Cache locally** — download and serve images from the project's assets directory. Never hotlink to external URLs that could break, throttle, or change.
- **Size targets**: Hero images under 100KB. Thumbnails under 30KB. Use `srcset` and `sizes` attributes for responsive image loading.
- **Alt text**: Every image needs descriptive alt text. Not "image" or "photo" — describe what's actually shown.
- **Placeholders**: If an image isn't ready, use a CSS gradient or SVG placeholder that matches the design. Never show a broken image icon or "image coming soon" text.

## Performance

Ship fast pages. Users leave if LCP exceeds 2.5 seconds:

- **CSS-only animations**: Use GPU-accelerated properties — `transform`, `opacity`, `filter`. Never animate `width`, `height`, `top`, `left`, `margin`, or `padding` (these trigger layout recalculation).
- **LCP target**: Under 2.5 seconds. The largest visible element (usually hero image or heading) must render fast. Preload critical assets with `<link rel="preload">`.
- **Minimize render-blocking**: Inline critical CSS or use `<link rel="preload" as="style">`. Defer non-critical JS with `defer` or `async`.
- **Font loading**: Use `font-display: swap` to prevent invisible text during font load. Preconnect to font CDNs.
- **No heavy JS for visual effects**: CSS can handle gradients, shadows, animations, and transitions. Only reach for JS when CSS genuinely can't do it (scroll-linked animations, complex state-based motion).

## Responsive Design

Every page must work on real devices:

- **Test breakpoints**: 480px (phone), 768px (tablet), 1024px (small laptop), 1440px (desktop). Don't just test at 768 — test the transitions between breakpoints.
- **Touch targets**: Minimum 44x44px for all interactive elements on mobile. Buttons, links, form fields — all must be comfortably tappable.
- **Mobile navigation**: A hidden nav with no way to open it is broken. If nav links hide on mobile, provide a hamburger/toggle button that actually works. Test it.
- **Fluid typography**: Use `clamp()` for font sizes that scale smoothly: `font-size: clamp(1rem, 2.5vw, 2rem)`. Avoid fixed pixel sizes for body text.
- **Container queries**: Prefer container-aware layouts over device-width media queries where supported. Components should adapt to their container, not the viewport.
- **Horizontal scroll**: Never allow accidental horizontal scroll on mobile. Test with `overflow-x: hidden` on the body only as a last resort — fix the actual overflow source.

## Anti-Placeholder Rules

Placeholder content signals incompleteness and destroys credibility:

- **Never ship "coming soon" sections**. If the content doesn't exist yet, remove the section entirely. A shorter page with real content beats a longer page with empty promises.
- **Never ship "Lorem ipsum"**. Write real copy or remove the element. Even rough draft copy is better than filler text.
- **Never ship empty image containers** with "Image coming soon" or play button icons pointing to nothing. Use a real image, a CSS-generated visual, or remove the section.
- **Video placeholders are dead weight**. If you don't have a video, don't show a video section. Replace with a working demo, animated terminal, code snippet, or screenshot — something that actually demonstrates the product.
- **Form actions must work**. A submit button that goes nowhere is worse than no form. Wire it up or remove it.
- **Links must resolve**. `href="#"` is acceptable only for CTAs that will get real links before deploy. Flag these clearly in code comments for the developer.
