---
description: Extract structured data from a web page using browser automation
---

## /browser-automation:scrape

### Steps

1. Ask user for the target URL and what data to extract
2. Navigate to the URL using Claude in Chrome
3. Wait for the page to fully load
4. Read the page structure to identify data elements
5. Extract the requested data (text, links, images, tables)
6. Structure the data as JSON or markdown table
7. Present results to the user
8. Optionally save to a file

### Rules
- Respect robots.txt and rate limits
- Never scrape personal data without explicit user consent
- Wait for dynamic content to load before extracting
- Handle pagination if user requests multiple pages
