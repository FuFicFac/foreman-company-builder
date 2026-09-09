#!/usr/bin/env python3
"""Build a versioned, allowlisted student ZIP from committed Git content."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import zipfile


ROOT = Path(__file__).resolve().parents[1]
FILES = (
    "VERSION", "README.md", "PROTOCOL.md", "RUNTIMES.md",
    "company-template/COMPANY.md", "company-template/TEAM.md",
    "company-template/AGENTS.md", "company-template/PROJECT.md",
    "company-template/TASK.md", "company-template/SKILL.md",
    "examples/archive-pilot/README.md", "examples/archive-pilot/COMPANY.md",
    "examples/archive-pilot/PROJECT.md", "examples/archive-pilot/TASK.md",
)


def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", required=True, type=Path)
    args = parser.parse_args()
    # A stale committed ZIP must not silently stand in for uncommitted kit edits.
    changes = git("status", "--porcelain", "--", "student-kit", "LICENSE",
                  "scripts/package-student-kit.py")
    if changes.strip():
        raise SystemExit("Commit the student kit, license, and packager before building.")

    commit = git("rev-parse", "HEAD").decode().strip()
    contents = {name: git("show", f"HEAD:student-kit/{name}") for name in FILES}
    contents["LICENSE"] = git("show", "HEAD:LICENSE")
    version = contents["VERSION"].decode().strip()
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+(?:-[a-zA-Z0-9.-]+)?", version):
        raise SystemExit("Invalid student kit version.")
    manifest = {
        "name": "Foreman Company Builder Student Kit",
        "version": version,
        "repository": "https://github.com/FuFicFac/foreman-company-builder",
        "commit": commit,
        "files_sha256": {name: hashlib.sha256(data).hexdigest()
                         for name, data in sorted(contents.items())},
    }
    contents["MANIFEST.json"] = (json.dumps(manifest, indent=2) + "\n").encode()
    folder = f"Foreman-Company-Builder-Student-Kit-v{version}"
    args.output_dir.mkdir(parents=True, exist_ok=True)
    destination = args.output_dir / f"{folder}.zip"
    # Fixed timestamps and ordering make repeat builds from the same commit identical.
    with zipfile.ZipFile(destination, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for name, data in sorted(contents.items()):
            info = zipfile.ZipInfo(f"{folder}/{name}", date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            archive.writestr(info, data)

    # Check integrity and every member, including its hash, after writing.
    with zipfile.ZipFile(destination) as archive:
        assert archive.testzip() is None, "Archive integrity failed"
        expected = {f"{folder}/{name}" for name in contents}
        assert set(archive.namelist()) == expected, "Unexpected archive members"
        for name, expected_hash in manifest["files_sha256"].items():
            assert hashlib.sha256(archive.read(f"{folder}/{name}")).hexdigest() == expected_hash
    print(json.dumps({"path": str(destination.resolve()), "version": version,
                      "commit": commit, "files": len(contents),
                      "bytes": destination.stat().st_size,
                      "sha256": hashlib.sha256(destination.read_bytes()).hexdigest()}, indent=2))


if __name__ == "__main__":
    main()
