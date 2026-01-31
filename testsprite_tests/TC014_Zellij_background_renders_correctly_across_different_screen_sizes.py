import asyncio
from playwright import async_api

async def run_test():
    pw = None
    browser = None
    context = None

    try:
        # Start a Playwright session in asynchronous mode
        pw = await async_api.async_playwright().start()

        # Launch a Chromium browser in headless mode with custom arguments
        browser = await pw.chromium.launch(
            headless=True,
            args=[
                "--window-size=1280,720",         # Set the browser window size
                "--disable-dev-shm-usage",        # Avoid using /dev/shm which can cause issues in containers
                "--ipc=host",                     # Use host-level IPC for better stability
                "--single-process"                # Run the browser in a single process mode
            ],
        )

        # Create a new browser context (like an incognito window)
        context = await browser.new_context()
        context.set_default_timeout(5000)

        # Open a new page in the browser context
        page = await context.new_page()

        # Navigate to your target URL and wait until the network request is committed
        await page.goto("http://localhost:55372", wait_until="commit", timeout=10000)

        # Wait for the main page to reach DOMContentLoaded state (optional for stability)
        try:
            await page.wait_for_load_state("domcontentloaded", timeout=3000)
        except async_api.Error:
            pass

        # Iterate through all iframes and wait for them to load as well
        for frame in page.frames:
            try:
                await frame.wait_for_load_state("domcontentloaded", timeout=3000)
            except async_api.Error:
                pass

        # Interact with the page elements to simulate user flow
        # -> Navigate to http://localhost:55372
        await page.goto("http://localhost:55372", wait_until="commit", timeout=10000)
        
        # -> Force a reload of the app (cache-bypass) to attempt to load SPA assets, then wait and run a detailed DOM/style inspection to detect any zellij rendering elements (computed backgrounds, canvases, images, svgs, and elements with 'zellij' in id/class). If the reload still fails, plan next: emulate multiple viewports/orientations and re-check rendering.
        await page.goto("http://localhost:55372/?_reload=1", wait_until="commit", timeout=10000)
        
        # --> Assertions to verify final state
        frame = context.pages[-1]
        try:
            await expect(frame.locator('text=Zellij background rendered correctly').first).to_be_visible(timeout=3000)
        except AssertionError:
            raise AssertionError("Test case failed: expected the Moroccan Zellij tile background to render fully and maintain correct proportions across multiple device resolutions and orientations (no clipping, distortion, or misalignment), but the success text/element was not found — the background may be missing, clipped, or distorted after viewport or orientation changes.")
        await asyncio.sleep(5)

    finally:
        if context:
            await context.close()
        if browser:
            await browser.close()
        if pw:
            await pw.stop()

asyncio.run(run_test())
    