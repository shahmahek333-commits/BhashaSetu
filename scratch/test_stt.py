import subprocess
import os

html_content = """<!DOCTYPE html>
<html>
<head><title>STT Test</title></head>
<body>
<div id="output">Testing STT...</div>
<script>
try {
  const SpeechRec = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (!SpeechRec) {
    document.getElementById('output').innerText = JSON.stringify({ error: 'No SpeechRec' });
  } else {
    const rec = new SpeechRec();
    rec.lang = 'hi-IN';
    rec.continuous = false;
    rec.interimResults = true;
    document.getElementById('output').innerText = JSON.stringify({
      success: true,
      lang: rec.lang,
      continuous: rec.continuous,
      interimResults: rec.interimResults
    });
  }
} catch (e) {
  document.getElementById('output').innerText = JSON.stringify({ error: e.toString() });
}
</script>
</body>
</html>
"""

html_path = os.path.abspath("scratch/test_stt.html")
with open(html_path, "w", encoding="utf-8") as f:
    f.write(html_content)

cmd = [
    "C:/Program Files/Google/Chrome/Application/chrome.exe",
    "--headless=new",
    "--dump-dom",
    "--virtual-time-budget=2000",
    f"file:///{html_path.replace(os.sep, '/')}"
]

res = subprocess.run(cmd, capture_output=True)
out = res.stdout.decode("utf-8", errors="ignore")
import re
m = re.search(r'<div id="output">(.*?)</div>', out)
print("STT DUMP:", m.group(1) if m else "NO_MATCH")
