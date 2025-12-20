import pytest
import subprocess
import os
from pathlib import Path

# --- Configuration ---
# Update this path to point to your actual compiler executable
EXECUTABLE_PATH = Path("./bin/compiler.exe").resolve()

TEST_DIR = Path(__file__).parent
SHOULD_COMPILE_DIR = TEST_DIR / "sources" / "should-compile"
SHOULD_NOT_COMPILE_DIR = TEST_DIR / "sources" / "should-not-compile"

# --- Helper Functions ---


def get_test_files(directory):
    """
    Returns a list of .c files in the given directory.
    Returns an empty list if the directory does not exist.
    """
    if not directory.exists():
        return []
    return list(directory.glob("*.c"))


def run_compiler(file_path):
    """
    Runs the compiler against a specific file.
    Returns the completed process object.
    """
    if not EXECUTABLE_PATH.exists():
        pytest.fail(f"Compiler executable not found at: {EXECUTABLE_PATH}")

    # Capture output to keep the test runner clean, but available on failure
    result = subprocess.run(
        [str(EXECUTABLE_PATH), str(file_path)],
        capture_output=True,
        text=True
    )
    return result

# --- Tests ---


@pytest.mark.parametrize("file_path", get_test_files(SHOULD_COMPILE_DIR))
def test_should_compile(file_path):
    """
    Expects the compiler to return exit code 0 (Success).
    """
    result = run_compiler(file_path)

    error_msg = (
        f"File '{file_path.name}' failed to compile.\n"
        f"Stderr: {result.stderr}\n"
        f"Stdout: {result.stdout}"
    )

    assert result.returncode == 0, error_msg


@pytest.mark.parametrize("file_path", get_test_files(SHOULD_NOT_COMPILE_DIR))
def test_should_not_compile(file_path):
    """
    Expects the compiler to return a non-zero exit code (Failure).
    """
    result = run_compiler(file_path)

    error_msg = (
        f"File '{file_path.name}' compiled successfully, but should have failed.\n"
        f"Stdout: {result.stdout}"
    )

    assert result.returncode != 0, error_msg
