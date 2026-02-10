---
name: "design-review"
description: "Comprehensive UI/UX design review with accessibility analysis and web interface guidelines compliance. Use when asked to review UI/UX designs, check accessibility, audit design, review wireframes/mockups/prototypes, check WCAG compliance, or review a site against best practices."
---

# Design Review

Comprehensive design review for web and desktop interfaces covering accessibility (WCAG), visual design, usability, responsiveness, and web interface guidelines.

## When to Use This Skill

- Review UI/UX designs, wireframes, mockups, or deployed interfaces
- Accessibility audit (WCAG 2.1/2.2 compliance)
- Usability or visual design critique
- Responsive design evaluation
- Web interface guidelines compliance check
- Component library or design system review

## Review Process

### 1. Gather Context

Before reviewing, understand:
- Target audience and platform (web, desktop, mobile)
- Accessibility compliance level needed (A, AA, AAA)
- Brand guidelines or design system in use
- Browser/OS support requirements
- Project stage and constraints

### 2. Web Interface Guidelines (Optional Automated Check)

For code-level reviews, fetch the latest Vercel Web Interface Guidelines:

```
https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md
```

Use WebFetch to retrieve rules, then check specified files against them. Output findings in the terse `file:line` format from those guidelines.

## Review Framework

### A. Accessibility (WCAG 2.1/2.2)

This is the highest-priority review area.

**Level A (Minimum):**
- All images have appropriate alt text; decorative images use empty alt
- Video has captions; audio has transcripts
- Content structure is logical without CSS; semantic HTML used properly
- Color is not the sole means of conveying information
- Text contrast: 4.5:1 normal, 3:1 large text
- All functionality keyboard accessible; no keyboard traps
- Focus order is logical and visible
- No content flashes more than 3x/second
- Skip links, descriptive page titles, clear link purpose
- Touch targets minimum 44x44px
- Page language identified
- Navigation consistent across pages; input does not trigger unexpected changes
- Form errors identified with suggestions; labels provided
- Valid HTML; ARIA used correctly; unique IDs

**Level AA (Recommended):**
- Text resizable to 200% without loss of functionality
- Images of text avoided (unless customizable)
- Multiple ways to locate pages; descriptive headings/labels
- Visible focus indicator

**Level AAA (Best Practice):**
- Contrast 7:1 normal, 4.5:1 large
- No images of text; adjustable text spacing
- Content reflows to 320px; hover/focus content dismissible

**For each issue found, document:**
- WCAG criterion (e.g., "1.4.3 Contrast")
- Severity: Critical / High / Medium / Low
- User impact
- How to fix (specific steps)

### B. Visual Design

**Evaluate:** Visual hierarchy, color palette, typography choices, whitespace/density, alignment, grid usage, component consistency, brand compliance.

**Common issues:** Cluttered layouts, poor hierarchy, inconsistent spacing, too many fonts, misaligned elements, dated patterns.

### C. Usability (Nielsen's Heuristics)

1. Visibility of system status
2. Match between system and real world
3. User control and freedom
4. Consistency and standards
5. Error prevention
6. Recognition rather than recall
7. Flexibility and efficiency of use
8. Aesthetic and minimalist design
9. Help users recognize and recover from errors
10. Help and documentation

**Evaluate:** User flow efficiency, navigation clarity, cognitive load, error prevention/recovery, feedback mechanisms, learnability.

### D. Responsive Design

**Evaluate:** Breakpoint strategy, mobile-first approach, touch targets, content reflow, navigation adaptation, form layout on mobile, typography scaling.

**Desktop-specific:** Window resizing, min/max dimensions, native OS patterns, keyboard shortcuts, context menus, drag and drop.

### E. Typography

**Key metrics:** Line length 45-75 chars, line height 1.5-1.8 body, minimum 16px body, limit 2-3 font families. Use relative units (rem/em), system fonts for performance, proper fallbacks.

### F. Color and Contrast

**Contrast requirements:**
- Normal text: 4.5:1 (AA), 7:1 (AAA)
- Large text (18pt+ / 14pt bold+): 3:1 (AA), 4.5:1 (AAA)
- UI components and graphics: 3:1 (AA)

Verify: color blindness accessibility, dark mode support, semantic color usage, no information conveyed by color alone.

### G. Interactive Elements

**All components need:** Default, hover, focus, active, disabled, error, and success states. Clear affordances, visible focus indicators, helpful error messages, loading states that prevent double-submission.

### H. Forms

**Best practices:** Labels above/left of input (never placeholder-as-label), inline validation, specific error messages, clear required indicators, grouped related fields, format hints, preserve data on error, auto-focus first field.

### I. Navigation

Keep shallow (3 levels max), highlight current location, provide multiple paths, consistent across pages, familiar patterns. Include breadcrumbs and search for complex sites.

### J. Content and Microcopy

Action-oriented button labels, conversational error messages, helpful empty states, consistent terminology, match user language.

## Output Format

### Executive Summary
- Overall assessment (1-3 paragraphs)
- Key strengths
- Critical issues requiring immediate attention
- Accessibility compliance level achieved

### Prioritized Findings

**CRITICAL** - Prevents access to core functionality; WCAG Level A violations; blocks keyboard/screen reader users
**HIGH** - Significantly impairs UX; WCAG Level AA violations; major usability issues
**MEDIUM** - Creates friction with workarounds; visual inconsistencies; WCAG AAA recommendations
**LOW** - Polish, edge cases, aesthetic refinements

For each finding: area, severity, description, user impact, fix recommendation, WCAG reference (if applicable).

### Recommendations
- Specific fixes with code examples (HTML, CSS, ARIA) where helpful
- Design system suggestions
- Testing tool recommendations

## Testing Tools

**Accessibility:** axe DevTools, WAVE, Lighthouse, Pa11y, NVDA/JAWS/VoiceOver, WebAIM Contrast Checker, Color Oracle
**Visual/Responsive:** Browser DevTools, BrowserStack, Responsinator
**Usability:** Hotjar, FullStory, Maze, UserTesting.com

## Reference Standards

- WCAG 2.1/2.2 (W3C)
- Material Design (Google), Human Interface Guidelines (Apple), Fluent Design (Microsoft)
- Section 508, ADA, EN 301 549
- GOV.UK Design System, Carbon Design System (IBM)
