---
description: Run end-to-end browser tests against a local or remote URL
---

## /webapp-testing:test-e2e

### Steps

1. Confirm the target URL (default: `http://localhost:3000`)
2. Ask user what flows to test (login, checkout, navigation, etc.)
3. Use Playwright MCP to launch a browser
4. Navigate to the target URL
5. Execute each test flow:
   - Interact with page elements (click, type, select)
   - Take screenshots at key steps
   - Assert expected outcomes (text visible, URL changed, element exists)
6. Report results: pass/fail per flow with screenshots
7. For failures, capture console errors and network requests

### Rules
- Always take a screenshot before and after critical actions
- Wait for page loads and animations before asserting
- Test with realistic data, not "test123"
- Report all failures, don't stop at the first one
