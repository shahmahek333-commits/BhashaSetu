import subprocess
import os
import re
import json

html_path = os.path.abspath("scratch/test_speech.html")
cmd = [
    "C:/Program Files/Google/Chrome/Application/chrome.exe",
    "--headless=new",
    "--dump-dom",
    "--virtual-time-budget=3000",
    f"file:///{html_path.replace(os.sep, '/')}"
]

res = subprocess.run(cmd, capture_output=True)
out = res.stdout.decode("utf-8", errors="ignore")
m = re.search(r'<div id="output">(.*?)</div>', out)
if m:
    with open("scratch/chrome_voices.json", "w", encoding="utf-8") as f:
        f.write(m.group(1))
    print("SAVED_TO_FILE")
else:
    print("NO_MATCH")
