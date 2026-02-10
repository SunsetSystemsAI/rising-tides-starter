---
name: playwright-testing
description: Use when writing E2E tests with Playwright, setting up test infrastructure,
  or debugging flaky browser tests. Invoke for Playwright API patterns, Page Object
  Model, selectors, network mocking, visual testing, mobile testing, CI/CD integration,
  and advanced Playwright techniques.
triggers:
- Playwright
- E2E test
- end-to-end
- browser testing
- automation
- UI testing
- visual testing
role: specialist
scope: testing
output-format: code
dependencies:
  recommended: [qa-test-planner, webapp-testing]
---

# Playwright Testing

Senior E2E testing specialist for robust, maintainable browser automation with Playwright.

**When to use this skill vs webapp-testing:**
- **webapp-testing** -- MCP-driven browser control, dev server management, quick interactive testing
- **playwright-testing** -- Writing robust test suites, POM architecture, network mocking, CI/CD integration

## Core Workflow

1. **Analyze requirements** - Identify user flows to test
2. **Setup** - Configure Playwright with proper settings
3. **Write tests** - Use POM pattern, proper selectors, auto-waiting
4. **Debug** - Fix flaky tests, use traces
5. **Integrate** - Add to CI/CD pipeline

## Constraints

### MUST DO
- Use role-based or data-testid selectors
- Leverage auto-waiting (no arbitrary timeouts)
- Keep tests independent (no shared state)
- Use Page Object Model for maintainability
- Enable traces/screenshots for debugging
- Run tests in parallel

### MUST NOT DO
- Use `waitForTimeout()` in production tests (use proper waits)
- Rely on CSS class selectors (brittle)
- Share state between tests
- Ignore flaky tests
- Use `first()`, `nth()` without good reason

## Playwright Config

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
  webServer: {
    command: 'npm run start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

## Test Structure

```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature Name', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('should do something', async ({ page }) => {
    await page.getByRole('button', { name: 'Submit' }).click();
    await expect(page).toHaveURL('/success');
    await expect(page.locator('.message')).toHaveText('Success!');
  });
});
```

## Selector Strategy (Priority Order)

```javascript
// 1. BEST: data-testid attributes (most stable)
page.locator('[data-testid="submit-button"]')

// 2. GOOD: Role-based selectors (accessible)
page.getByRole('button', { name: 'Submit' })
page.getByRole('textbox', { name: 'Email' })

// 3. GOOD: Text content (for unique text)
page.getByText('Sign in')

// 4. OK: Semantic HTML attributes
page.locator('button[type="submit"]')

// 5. AVOID: Classes and IDs (fragile)
page.locator('.btn-primary')  // avoid
```

### Advanced Locator Patterns

```javascript
// Filter rows by text, then act on child
const row = page.locator('tr').filter({ hasText: 'John Doe' });
await row.locator('button').click();

// Combine conditions
await page.locator('button').and(page.locator('[disabled]')).count();
```

## Page Object Model (POM)

```javascript
class LoginPage {
  constructor(page) {
    this.page = page;
    this.usernameInput = page.getByLabel('Username');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign in' });
    this.errorMessage = page.locator('[data-testid="error"]');
  }

  async navigate() {
    await this.page.goto('/login');
  }

  async login(username, password) {
    await this.usernameInput.fill(username);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}

// Usage in test
test('login with valid credentials', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.navigate();
  await loginPage.login('user@example.com', 'password123');
  await expect(page).toHaveURL('/dashboard');
});
```

## Network Mocking and Interception

```javascript
// Mock API responses
await page.route('**/api/users', route => {
  route.fulfill({
    status: 200,
    contentType: 'application/json',
    body: JSON.stringify([{ id: 1, name: 'John' }])
  });
});

// Block resources (speed up tests)
await page.route('**/*.{png,jpg,jpeg,gif}', route => route.abort());

// Wait for specific API response
const responsePromise = page.waitForResponse('**/api/users');
await page.click('button#load-users');
const response = await responsePromise;
```

## Assertions Reference

```javascript
// Page-level
await expect(page).toHaveTitle('My App');
await expect(page).toHaveURL(/.*dashboard/);

// Visibility and state
await expect(page.locator('.message')).toBeVisible();
await expect(page.locator('button')).toBeEnabled();

// Text and attributes
await expect(page.locator('h1')).toHaveText('Welcome');
await expect(page.locator('.msg')).toContainText('success');
await expect(page.locator('button')).toHaveAttribute('type', 'submit');

// Count and value
await expect(page.locator('.item')).toHaveCount(5);
await expect(page.locator('input')).toHaveValue('test@example.com');
```

## Waiting Strategies

```javascript
// Element states
await page.locator('button').waitFor({ state: 'visible' });
await page.locator('.spinner').waitFor({ state: 'hidden' });

// URL changes
await page.waitForURL('**/success');

// Network
await page.waitForLoadState('networkidle');

// Custom conditions
await page.waitForFunction(() => document.querySelector('.loaded'));
```

## Form Interactions

```javascript
await page.getByLabel('Email').fill('user@example.com');
await page.selectOption('select#country', { label: 'United States' });
await page.setInputFiles('input[type="file"]', 'path/to/file.pdf');
await page.getByLabel('I agree').check();
```

## Visual Testing

```javascript
await expect(page).toHaveScreenshot('homepage.png');
await page.locator('.chart').screenshot({ path: 'chart.png' });
```

## Mobile Device Emulation

```javascript
const { devices } = require('playwright');
const iPhone = devices['iPhone 12'];

const context = await browser.newContext({
  ...iPhone,
  locale: 'en-US',
  permissions: ['geolocation'],
  geolocation: { latitude: 37.7749, longitude: -122.4194 }
});
```

## Handling Special Cases

```javascript
// Popups
const [popup] = await Promise.all([
  page.waitForEvent('popup'),
  page.click('button.open-popup')
]);

// File downloads
const [download] = await Promise.all([
  page.waitForEvent('download'),
  page.click('button.download')
]);
await download.saveAs(`./downloads/${download.suggestedFilename()}`);

// iFrames
const frame = page.frameLocator('#my-iframe');
await frame.locator('button').click();
```

## CI/CD Integration (GitHub Actions)

```yaml
name: Playwright Tests
on:
  push:
    branches: [main, master]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test
```

## Debugging

```bash
npx playwright test --debug        # Inspector
npx playwright test --headed       # See browser
npx playwright codegen example.com # Generate code from actions
npx playwright show-report         # View HTML report
```

```javascript
await page.pause();  // Opens inspector
page.on('console', msg => console.log('Browser:', msg.text()));
page.on('pageerror', error => console.log('Error:', error));
```

## Related Skills

- **webapp-testing** - MCP-driven browser control and interactive testing
- **qa-test-planner** - Overall testing strategy
