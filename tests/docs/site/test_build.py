import re
import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]


def _build(site: Path) -> None:
    subprocess.run(
        ["mkdocs", "build", "--strict", "--site-dir", str(site)],
        check=True,
        cwd=REPO_ROOT,
    )


def _visible_text(html: str) -> str:
    without_comments = re.sub(r"<!--.*?-->", "", html, flags=re.DOTALL)
    return re.sub(r"<[^>]+>", "", without_comments)


def test_mkdocs_build_strict_and_home_is_rules(tmp_path):
    site = tmp_path / "site"
    _build(site)
    assert (site / "rules_of_extreme_deptychecking" / "index.html").is_file()
    assert (site / "debugging-tips" / "index.html").is_file()
    assert (site / "patterns" / "00_safe_select" / "index.html").is_file()
    assert not (site / "superpowers").exists()
    assert not (site / "requirements.txt").exists()



def test_hidden_prelude_not_visible(tmp_path):
    site = tmp_path / "site"
    _build(site)
    html = (site / "patterns" / "00_safe_select" / "index.html").read_text()
    visible_text = _visible_text(html)
    assert "import Data.Fin" not in visible_text


def test_root_is_rules_redirect(tmp_path):
    site = tmp_path / "site"
    _build(site)
    assert "rules_of_extreme_deptychecking" in (site / "index.html").read_text()
