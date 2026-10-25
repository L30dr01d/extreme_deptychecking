import os
import subprocess
from pathlib import Path

import pytest

DISCOVER = Path(__file__).resolve().parent / "discover"
REPO_ROOT = Path(__file__).resolve().parents[3]
README = REPO_ROOT / "README.md"


@pytest.fixture
def discover():
    def run(docsdir):
        env = {**os.environ}
        if docsdir is None:
            env.pop("DOCSDIR", None)
        else:
            env["DOCSDIR"] = str(docsdir)
        result = subprocess.run(
            [str(DISCOVER)],
            env=env,
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.splitlines()

    return run


def test_names_strip_leading_digits_and_underscores(tmp_path, discover):
    (tmp_path / "patterns").mkdir()
    (tmp_path / "patterns" / "00_safe_select.md").write_text("```idris\n")
    assert discover(tmp_path) == ["Patterns.SafeSelect"]


def test_skips_superpowers_even_with_idris(tmp_path, discover):
    spec = tmp_path / "superpowers" / "specs"
    spec.mkdir(parents=True)
    (spec / "note.md").write_text("```idris\n")
    (tmp_path / "rules.md").write_text("# Rules\n")
    assert discover(tmp_path) == []


def test_skips_markdown_with_no_idris(tmp_path, discover):
    (tmp_path / "rules.md").write_text("# Rules\n")
    (tmp_path / "tips.md").write_text("<!-- idris\n%default total\n-->\n")
    assert discover(tmp_path) == ["Tips"]


def test_repo_docs_list_the_five_pattern_modules(discover):
    assert discover(None) == [
        "Patterns.ConstructivePredicate",
        "Patterns.HelperType",
        "Patterns.SafeSelect",
        "Patterns.SecondFuel",
        "Patterns.UniqueIndex",
    ]


def test_readme_is_front_door_without_pattern_bodies():
    text = README.read_text()
    assert "data BoolPredResult" not in text
    assert "https://l3odr0id.github.io/extreme_deptychecking/rules_of_extreme_deptychecking/" in text


def test_discover_fails_when_python3_missing(tmp_path):
    env = {**os.environ, "DOCSDIR": str(tmp_path), "PATH": str(tmp_path / "empty-bin")}
    (tmp_path / "empty-bin").mkdir()
    result = subprocess.run(
        [str(DISCOVER)],
        env=env,
        capture_output=True,
        text=True,
    )
    assert result.returncode != 0
