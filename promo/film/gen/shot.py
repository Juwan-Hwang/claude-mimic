import sys, asyncio
from playwright.async_api import async_playwright
async def main(url, out, w, h):
    async with async_playwright() as p:
        b = await p.chromium.launch(); pg = await b.new_page(viewport={'width': w, 'height': h})
        await pg.goto(url); await pg.wait_for_timeout(500); await pg.screenshot(path=out); await b.close()
asyncio.run(main(sys.argv[1], sys.argv[2], int(sys.argv[3]) if len(sys.argv)>3 else 600, int(sys.argv[4]) if len(sys.argv)>4 else 600))
