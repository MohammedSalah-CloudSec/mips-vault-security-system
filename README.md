# Vault Security System (MIPS Assembly)

An interactive MIPS assembly program that stores and analyzes ten vault access codes. It was built as a four-person Computer Organization and Architecture coursework project. The "vault" is a teaching scenario: this program analyzes numbers and does not secure a real vault.

## What it does

Each code must be an integer from **1 to 9999**. An out-of-range value is rejected, and the same slot is requested again. After all ten codes are stored, the menu repeats until Exit is selected.

| Menu option | Behavior |
| --- | --- |
| 1. Highest code | Scans the array for its maximum. |
| 2. Even and odd counts | Counts codes by parity. |
| 3. Search | Reports the **zero-based index** of the first match. |
| 4. Second largest | Finds the second **distinct** largest code; reports when all codes are equal. |
| 5. Sort ascending | Bubble-sorts the stored array in place, then displays it. |
| 6. Reverse | Reverses the current array in place, then displays it. |
| 7. Odd codes | Displays odd values in their current order, or `(none)`. |
| 8. Exit | Ends the program. |

## Run it

1. Install Java and download [MARS 4.5](https://github.com/dpetersanderson/MARS/releases) from the simulator's official repository.
2. Open [`vault_security_system.asm`](vault_security_system.asm) in MARS.
3. Choose **Run → Assemble**, then **Run → Go**.
4. Enter ten codes, followed by menu choices. The same array is used throughout the session, so sorting and reversing affect later searches and displays.

You can also run it from a terminal:

```text
java -jar Mars4_5.jar nc vault_security_system.asm
```

The `nc` option suppresses the simulator copyright banner. MARS command-line usage is described in its [official help](https://dpetersanderson.github.io/Help/MarsHelpCommand.html).

### Example

For input codes `9 9 8 7 6 5 4 3 2 1`, option **4** reports:

```text
Second largest distinct code is: 8
```

If all ten codes are `9`, it reports that no second distinct code exists. The program expects integer input; text input is outside this coursework's input specification.

## Implementation

- `codes` reserves **40 bytes** in the data segment: ten 32-bit words.
- `$s0` holds the array base address. The index is shifted left by two bits to address each word.
- The program uses `beq`, `bne`, comparisons, loops, and `jal` to navigate and process the array.
- MARS syscalls print strings and integers, read integers, and exit.
- Scans, search, and reversal take **O(n)** time; the bubble sort takes **O(n²)** time. Here `n = 10`.

## Contributors

| Contributor | Individual feature |
| --- | --- |
| Hussam Murad Naim Abdelghani | Second largest code |
| Mahmoud Ahmad Naim Abdelghani | Ascending sort |
| Mohamed Munir Hassan Munir | Reverse codes |
| Abdullah Mohammed Salah Qasem | Display odd codes |

Input collection and the menu were group work. This repository presents the improved group project and preserves credit for every member.

## Verify

The [`tests/test_vault.py`](tests/test_vault.py) suite runs the program in MARS and checks validation, scanning, searching, duplicate handling, sorting, reversal, and empty odd output. Set `MARS_JAR` to your downloaded JAR first:

```powershell
$env:MARS_JAR = "C:\path\to\Mars4_5.jar"
python -m unittest discover -s tests -v
```
