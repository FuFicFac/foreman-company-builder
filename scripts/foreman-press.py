#!/usr/bin/env python3
"""Foreman press — local registry/validator for generated CLI capabilities."""
from __future__ import annotations

import argparse
import copy
import datetime as dt
import hashlib
import json
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path
from typing import Any

SCHEMA = "foreman.tool.v1"
ID_RE = re.compile(r"^[a-z0-9]+(\.[a-z0-9_-]+)+$")
SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$")
DEFAULT_MAX_OUTPUT_BYTES = 524288


def config_dir() -> Path:
    return Path(os.environ.get("FOREMAN_CONFIG_DIR", str(Path.home() / ".foreman")))


def registry_dir() -> Path:
    return config_dir() / "tools"


def tool_dir(tool_id: str) -> Path:
    return registry_dir() / tool_id


def now_iso() -> str:
    return dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def emit(data: dict[str, Any], code: int = 0) -> int:
    print(json.dumps(data, indent=2, sort_keys=True))
    return code


def load_json(path: str | Path) -> tuple[dict[str, Any] | None, list[str]]:
    try:
        with open(path, "r", encoding="utf-8") as fh:
            data = json.load(fh)
    except Exception as exc:
        return None, [f"manifest must be valid JSON: {exc}"]
    if not isinstance(data, dict):
        return None, ["manifest root must be a JSON object"]
    return data, []


def get_path(data: Any, expr: str | None) -> Any:
    if not expr or expr == "$":
        return data
    if not expr.startswith("$."):
        raise ValueError("expected_output_path must be $ or start with $. for V0")
    cur = data
    for part in expr[2:].split("."):
        if not isinstance(cur, dict) or part not in cur:
            raise KeyError(part)
        cur = cur[part]
    return cur


def validate_manifest(data: dict[str, Any], *, run_smoke: bool) -> tuple[list[str], dict[str, Any]]:
    errors: list[str] = []
    checks: dict[str, Any] = {}

    def require_obj(name: str) -> dict[str, Any]:
        value = data.get(name)
        if not isinstance(value, dict):
            errors.append(f"{name} must be an object")
            return {}
        return value

    required_fields = ["schema", "id", "name", "version", "description", "lifecycle", "provenance", "invocation", "commands", "permissions", "validation", "error_contract", "tags"]
    for field in required_fields:
        if field not in data:
            errors.append(f"missing required field: {field}")
    unsupported_top_level = sorted(set(data) - set(required_fields))
    if unsupported_top_level:
        errors.append(f"unsupported V0 top-level fields: {', '.join(unsupported_top_level)}")

    if data.get("schema") != SCHEMA:
        errors.append(f"schema must equal {SCHEMA}")
    for field in ["name", "description"]:
        if not isinstance(data.get(field), str) or not data.get(field):
            errors.append(f"{field} must be a non-empty string")
    if not isinstance(data.get("provenance"), dict):
        errors.append("provenance must be an object")
    tool_id = data.get("id")
    if not isinstance(tool_id, str) or not ID_RE.match(tool_id):
        errors.append("id must be reverse-domain lowercase form, e.g. com.printingpress.local-weather")
    if not isinstance(data.get("version"), str) or not SEMVER_RE.match(data.get("version", "")):
        errors.append("version must be semver, e.g. 0.1.0")

    lifecycle = require_obj("lifecycle")
    if lifecycle.get("status") != "proposed":
        errors.append("lifecycle.status must be proposed before registration; Foreman owns later transitions")
    for foreman_owned in ["registered_at", "registered_by", "validated_at"]:
        if foreman_owned in lifecycle:
            errors.append(f"lifecycle.{foreman_owned} is Foreman-owned and must not be author-supplied")

    invocation = require_obj("invocation")
    binary = invocation.get("binary")
    if not isinstance(binary, str) or not binary:
        errors.append("invocation.binary must be a non-empty string")
    else:
        if not os.path.isabs(binary):
            errors.append("invocation.binary must be an absolute path")
        elif not os.path.isfile(binary) or not os.access(binary, os.X_OK):
            errors.append("invocation.binary must exist and be executable")
    if invocation.get("output_format") != "json":
        errors.append('invocation.output_format must be "json" for V0')
    timeout_ms = invocation.get("timeout_ms")
    if not isinstance(timeout_ms, int) or timeout_ms <= 0:
        errors.append("invocation.timeout_ms must be a positive integer")
    if not isinstance(invocation.get("idempotent"), bool):
        errors.append("invocation.idempotent must be boolean")
    max_output_bytes = invocation.get("max_output_bytes")
    if not isinstance(max_output_bytes, int) or max_output_bytes <= 0:
        errors.append("invocation.max_output_bytes must be a positive integer")

    commands = data.get("commands")
    if not isinstance(commands, list) or not commands:
        errors.append("commands must be a non-empty array")
    else:
        seen: set[str] = set()
        for idx, command in enumerate(commands):
            if not isinstance(command, dict):
                errors.append(f"commands[{idx}] must be an object")
                continue
            name = command.get("name")
            if not isinstance(name, str) or not name:
                errors.append(f"commands[{idx}].name is required")
            elif name in seen:
                errors.append(f"commands[{idx}].name must be unique within manifest")
            else:
                seen.add(name)
            if not isinstance(command.get("args_schema"), dict):
                errors.append(f"commands[{idx}].args_schema must be an object")
            if not isinstance(command.get("output_schema"), dict):
                errors.append(f"commands[{idx}].output_schema must be an object")

    permissions = require_obj("permissions")
    allowed_permission_keys = {"reads", "risk_level", "writes"}
    unsupported_permission_keys = sorted(set(permissions) - allowed_permission_keys)
    if unsupported_permission_keys:
        errors.append(f"unsupported V0 permission keys: {', '.join(unsupported_permission_keys)}")
    for blocked_key in ["credentials", "credential", "secrets", "secret", "publishing", "payments", "payment", "money"]:
        if blocked_key in permissions:
            errors.append(f"V0 does not allow permissions.{blocked_key}")
    reads = permissions.get("reads")
    if not isinstance(reads, list) or not all(isinstance(item, str) for item in reads):
        errors.append("permissions.reads must be an array of strings")
    else:
        denied = [item for item in reads if item.endswith(":none")]
        if denied:
            errors.append("permissions.reads must be a whitelist; omit denied permissions instead of using :none")
        network = [item for item in reads if item.startswith("network:")]
        if network:
            errors.append("V0 does not allow network reads")
    if permissions.get("risk_level") not in ["none", "low"]:
        errors.append("permissions.risk_level must be none or low for V0")
    if "writes" in permissions:
        errors.append("V0 does not allow permissions.writes")

    validation = require_obj("validation")
    smoke = validation.get("smoke_test")
    smoke_args: list[str] = []
    if not isinstance(smoke, dict):
        errors.append("validation.smoke_test must be an object, not a shell string")
    else:
        args = smoke.get("args")
        if not isinstance(args, list) or not all(isinstance(item, str) for item in args):
            errors.append("validation.smoke_test.args must be an array of strings")
        else:
            smoke_args = args
    expected_output_path = validation.get("expected_output_path")
    if expected_output_path is not None and not isinstance(expected_output_path, str):
        errors.append("validation.expected_output_path must be a string")

    if not isinstance(data.get("error_contract"), dict):
        errors.append("error_contract must be an object")
    if not isinstance(data.get("tags"), list) or not all(isinstance(item, str) for item in data.get("tags", [])):
        errors.append("tags must be an array of strings")

    if errors or not run_smoke:
        return errors, checks

    assert isinstance(binary, str)
    max_bytes_value = invocation.get("max_output_bytes", DEFAULT_MAX_OUTPUT_BYTES)
    timeout_ms_value = invocation.get("timeout_ms", 5000)
    max_bytes = int(max_bytes_value)
    timeout = max(1, int(timeout_ms_value) / 1000)
    try:
        proc = subprocess.run([binary, *smoke_args], capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        errors.append("smoke_test timed out")
        return errors, checks
    except Exception as exc:
        errors.append(f"smoke_test failed to execute: {exc}")
        return errors, checks

    checks["smoke_exit_code"] = proc.returncode
    if proc.returncode != 0:
        errors.append(f"smoke_test exited {proc.returncode}: {proc.stderr.strip()}")
        return errors, checks
    if len(proc.stdout.encode("utf-8")) > max_bytes:
        errors.append("smoke_test output exceeded invocation.max_output_bytes")
        return errors, checks
    try:
        output = json.loads(proc.stdout)
    except Exception as exc:
        errors.append(f"smoke_test stdout must be valid JSON: {exc}")
        return errors, checks
    checks["json_output"] = True
    try:
        get_path(output, expected_output_path)
    except Exception as exc:
        errors.append(f"expected_output_path not found: {expected_output_path} ({exc})")
    else:
        checks["expected_output_path"] = expected_output_path or "$"

    sha = invocation.get("binary_sha256")
    if sha:
        got = hashlib.sha256(Path(binary).read_bytes()).hexdigest()
        checks["binary_sha256"] = got
        if got != sha:
            errors.append("invocation.binary_sha256 does not match binary")

    return errors, checks


def validate_cmd(args: argparse.Namespace) -> int:
    data, errors = load_json(args.manifest)
    if data is None:
        return emit({"ok": False, "errors": errors}, 1)
    errors, checks = validate_manifest(data, run_smoke=not args.no_smoke)
    return emit({"ok": not errors, "id": data.get("id"), "errors": errors, "checks": checks}, 0 if not errors else 1)


def propose_manifest(args: argparse.Namespace) -> dict[str, Any]:
    smoke_args = shlex.split(args.smoke_args or "")
    return {
        "schema": SCHEMA,
        "id": args.tool_id,
        "name": args.name,
        "version": args.version,
        "description": args.description,
        "lifecycle": {"status": "proposed"},
        "provenance": {"source": "foreman-press", "generator_version": "0.1.0"},
        "invocation": {
            "binary": args.binary,
            "output_format": "json",
            "timeout_ms": args.timeout_ms,
            "idempotent": True,
            "max_output_bytes": DEFAULT_MAX_OUTPUT_BYTES,
        },
        "commands": [
            {
                "name": args.command_name,
                "description": args.command_description or args.description,
                "args_schema": {"type": "object"},
                "output_schema": {"type": "object"},
                "example": " ".join([Path(args.binary).name, *smoke_args]) if smoke_args else f"{Path(args.binary).name} {args.command_name}",
            }
        ],
        "permissions": {"reads": ["filesystem:local"], "risk_level": "none"},
        "validation": {"smoke_test": {"args": smoke_args}, "expected_output_path": args.expected_output_path},
        "error_contract": {"on_nonzero_exit": "stderr", "error_json_path": "$.error"},
        "tags": args.tags or [],
    }


def propose_cmd(args: argparse.Namespace) -> int:
    manifest = propose_manifest(args)
    errors, _checks = validate_manifest(manifest, run_smoke=False)
    if errors:
        return emit({"ok": False, "id": manifest.get("id"), "errors": errors}, 1)
    if args.out:
        out = Path(args.out)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        return emit({"ok": True, "id": manifest["id"], "manifest": str(out)})
    return emit(manifest)


def register_cmd(args: argparse.Namespace) -> int:
    data, errors = load_json(args.manifest)
    if data is None:
        return emit({"ok": False, "errors": errors}, 1)
    errors, checks = validate_manifest(data, run_smoke=True)
    if errors:
        return emit({"ok": False, "id": data.get("id"), "errors": errors, "checks": checks}, 1)

    registered = copy.deepcopy(data)
    lifecycle = registered.setdefault("lifecycle", {})
    lifecycle["status"] = "registered"
    lifecycle["registered_at"] = now_iso()
    lifecycle["registered_by"] = "foreman"
    lifecycle["validated_at"] = lifecycle["registered_at"]

    dest_dir = tool_dir(registered["id"])
    dest_dir.mkdir(parents=True, exist_ok=True)
    manifest_path = dest_dir / "manifest.json"
    validation_path = dest_dir / "validation.json"
    manifest_path.write_text(json.dumps(registered, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    validation_path.write_text(json.dumps({"ok": True, "checks": checks, "validated_at": lifecycle["validated_at"]}, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return emit({"ok": True, "id": registered["id"], "status": "registered", "manifest": str(manifest_path), "validation": str(validation_path)})


def list_cmd(args: argparse.Namespace) -> int:
    tools: list[dict[str, Any]] = []
    if registry_dir().is_dir():
        for manifest_path in sorted(registry_dir().glob("*/manifest.json")):
            data, errors = load_json(manifest_path)
            if data is None:
                tools.append({"id": manifest_path.parent.name, "ok": False, "errors": errors})
                continue
            tools.append({
                "id": data.get("id"),
                "name": data.get("name"),
                "version": data.get("version"),
                "status": data.get("lifecycle", {}).get("status"),
                "risk_level": data.get("permissions", {}).get("risk_level"),
            })
    return emit({"ok": True, "tools": tools})


def inspect_cmd(args: argparse.Namespace) -> int:
    manifest_path = tool_dir(args.tool_id) / "manifest.json"
    if not manifest_path.exists():
        return emit({"ok": False, "id": args.tool_id, "errors": ["tool not found"]}, 1)
    data, errors = load_json(manifest_path)
    if data is None:
        return emit({"ok": False, "id": args.tool_id, "errors": errors or ["tool not found"]}, 1)
    data = dict(data)
    data["ok"] = True
    return emit(data)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="foreman press")
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("validate", help="validate a foreman.tool.v1 manifest")
    p.add_argument("manifest")
    p.add_argument("--no-smoke", action="store_true", help="skip smoke command execution")
    p.set_defaults(func=validate_cmd)

    p = sub.add_parser("propose", help="draft a local-only foreman.tool.v1 manifest without registering it")
    p.add_argument("--id", dest="tool_id", required=True, help="reverse-domain tool id, e.g. com.printingpress.demo-json-tool")
    p.add_argument("--name", required=True)
    p.add_argument("--version", default="0.1.0")
    p.add_argument("--description", required=True)
    p.add_argument("--binary", required=True, help="absolute path to a local executable that emits JSON")
    p.add_argument("--command-name", required=True, help="single V0 command name exposed by the tool")
    p.add_argument("--command-description", default=None)
    p.add_argument("--smoke-args", default="", help="shell-style argument string for the smoke test, e.g. 'lookup --city Austin'")
    p.add_argument("--expected-output-path", default="$", help="JSON path that must exist in smoke output; V0 supports $.field paths")
    p.add_argument("--timeout-ms", type=int, default=5000)
    p.add_argument("--tag", dest="tags", action="append", default=[])
    p.add_argument("--out", help="write manifest to this path and print a small JSON status object")
    p.set_defaults(func=propose_cmd)

    p = sub.add_parser("register", help="validate with smoke execution and register a manifest locally")
    p.add_argument("manifest")
    p.set_defaults(func=register_cmd)

    p = sub.add_parser("list", help="list locally registered tools")
    p.set_defaults(func=list_cmd)

    p = sub.add_parser("inspect", help="print a registered manifest")
    p.add_argument("tool_id")
    p.set_defaults(func=inspect_cmd)

    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
