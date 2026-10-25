from pathlib import Path


def test_pages_workflow_uses_latest_actions():
    text = Path(".github/workflows/pages.yml").read_text()
    for pin in (
        "actions/checkout@v7",
        "actions/setup-python@v7",
        "actions/configure-pages@v6",
        "actions/upload-pages-artifact@v5",
        "actions/deploy-pages@v5",
    ):
        assert pin in text
    assert "mkdocs gh-deploy" not in text
    assert "peaceiris" not in text


def test_typecheck_job_runs_docs_not_readme():
    text = Path(".github/workflows/benchmark.yml").read_text()
    assert "docs-typecheck" in text
    assert "readme-typecheck" not in text
    assert "./tests/docs/typecheck/run" in text
    typecheck_job = text.split("docs-typecheck:", 1)[1].split("benchmarks:", 1)[0]
    assert "setup-python" in typecheck_job
    assert "actions/setup-python@v7" in typecheck_job
