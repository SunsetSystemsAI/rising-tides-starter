---
description: Create and render a programmatic video using Remotion
---

## /video-generator:render-video

### Steps

1. Ask user for video concept (topic, duration, style)
2. Check if Remotion project exists; if not, scaffold one
3. Create the composition in `src/compositions/`
4. Define video props (text, colors, timing, assets)
5. Preview with Remotion Studio: `npx remotion studio`
6. Render to MP4: `npx remotion render src/index.ts CompositionName out/video.mp4`
7. Report output file location and duration

### Rules
- Always preview before final render
- Keep compositions under 60 seconds unless specified
- Use spring animations for smooth motion
- Ensure text is readable (min 24px, high contrast)
