import json
import re
import sys


def extract_gloss(text):
    return re.sub(
        '[()"]',
        "",
        text.split("/")[0].strip(),
    )


def gloss(body, head):
    m = re.search("['‘’\"“”]([a-z .]+)['‘’\"“”];", body)
    if m:
        return m.group(1)
    body = body.split(";")[0].strip()
    body = re.sub("\.$", "", body)
    body = re.sub("\(.+\)$", "", body)
    if body.count("▯") >= 3:
        body = "▯".join(body.split("▯")[:2]) + "▯"
    body = body.strip()
    body = re.sub(r" (of|for|to|by|from)? ▯$", "", body)
    m = re.search(r"^▯ (?:is|are) (?:(?:a|an|the) )?([^▯]+)$", body)
    if m:
        return extract_gloss(m.group(1))
    m = re.search(r"^▯ ([^▯]+)( ▯)?$", body)
    if m:
        return extract_gloss(m.group(1))
    return None


glosses = {}
for entry in sorted(json.load(sys.stdin), key=lambda x: x["head"]):
    head = entry["head"]
    body = entry["body"]
    g = gloss(body, head)
    if g and 1 <= len(g) <= 22 and len(head) <= 30:
        glosses[head] = g

print(json.dumps(glosses))
