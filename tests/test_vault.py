"""Integration tests for the MARS 4.5 command-line simulator."""

import os
import subprocess
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE = PROJECT_ROOT / "vault_security_system.asm"
MARS_JAR = os.environ.get("MARS_JAR")


@unittest.skipUnless(MARS_JAR and Path(MARS_JAR).is_file(), "Set MARS_JAR to Mars4_5.jar")
class VaultIntegrationTests(unittest.TestCase):
    def run_vault(self, values, choices):
        data = "\n".join(str(value) for value in (*values, *choices)) + "\n"
        result = subprocess.run(
            ["java", "-jar", MARS_JAR, "nc", str(SOURCE)],
            input=data,
            text=True,
            capture_output=True,
            timeout=15,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn("Error in", result.stdout + result.stderr)
        return result.stdout

    def test_validation_and_invalid_menu_choice(self):
        output = self.run_vault([0, *range(1, 11)], [99, 8])
        self.assertIn("Invalid! Code must be between 1 and 9999.", output)
        self.assertEqual(output.count("for slot 1:"), 2)
        self.assertIn("Codes: 1 2 3 4 5 6 7 8 9 10", output)
        self.assertIn("Invalid menu choice. Enter a number from 1 to 8.", output)

    def test_scans_search_and_no_odd_codes(self):
        output = self.run_vault([2, 4, 6, 8, 10, 12, 14, 16, 18, 20], [1, 2, 3, 8, 7, 8])
        self.assertIn("Highest access code is: 20", output)
        self.assertIn("Even codes count: 10", output)
        self.assertIn("Odd codes count: 0", output)
        self.assertIn("Code found at zero-based index: 3", output)
        self.assertIn("Odd codes: (none)", output)

    def test_second_largest_ignores_duplicate_maximum(self):
        output = self.run_vault([9, 9, 8, 7, 6, 5, 4, 3, 2, 1], [4, 8])
        self.assertIn("Second largest distinct code is: 8", output)

    def test_all_equal_has_no_second_distinct_code(self):
        output = self.run_vault([9999] * 10, [4, 8])
        self.assertIn("No second distinct code: all ten codes are equal.", output)

    def test_sort_then_reverse_changes_the_array(self):
        output = self.run_vault(list(range(10, 0, -1)), [5, 6, 8])
        self.assertIn("Sorted ascending.\nCodes: 1 2 3 4 5 6 7 8 9 10", output)
        self.assertIn("Reversed list.\nCodes: 10 9 8 7 6 5 4 3 2 1", output)


if __name__ == "__main__":
    unittest.main()
