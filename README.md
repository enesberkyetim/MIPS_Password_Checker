# MIPS Password Strength Checker

> **Course:** CSE 3038 – Computer Organization  
> **Semester:** Spring 2025  
> **Instructor:** Prof. Haluk Topcuoğlu  
> **Author:** *Enes Berk Yetim*  
> **File:** `mips_soru3.asm`

## 1 . Overview
This program implements a robust password–quality checker in **MIPS32 assembly**.  
It validates a user-supplied password against a strict policy and, when necessary, produces a suggested correction that meets every rule.

The work corresponds to **Question 3** of the first programming project but is provided here as a self-contained repository.

## 2 . Password Policy
A strong password must satisfy **all** the following:

| Rule | Description |
|------|-------------|
| **Length** | > 6 characters |
| **Character classes** | At least one lowercase letter, one uppercase letter, one digit, **`*`** and **`+`** |
| **No repeats** | No two identical characters adjacent |

If any rule fails, the program constructs a compliant password by **appending** missing symbols and/or **replacing** repeating characters.

## 3 . Features
- Interactive prompt (`Please enter a password:`).  
- Immediate verdict:
  - `Your password is strong.` –– no changes required.
  - `Your password is not strong enough. Consider using: <fixed_password>`
- Automatic fix guarantees minimal modifications.
- Continuous loop: accept new input after each verdict.
- Fully commented, modular code with separate sub-routines for each rule check:
  - `number_counter`, `uppercase_check`, `lowercase_check`, `digit_check`, `star_check`, `plus_check`, `same_check`, and corresponding “correct_*” helpers.
- Adheres to MIPS calling conventions; preserves `$a0–$a3` across calls.


## 4 . How It Works (High-Level)
1. **Input capture** – Dynamically allocates 50 bytes on the heap to store the password.
2. **Copy stage** – Duplicates the original string for non-destructive edits.
3. **Validation pipeline**  
   Each rule × sub-routine returns `true/false`; failures set flag `$s0 ← 1`.
4. **Correction phase**  
   Corresponding `correct_*` routine patches the copy in-place:
   - Appends required characters (`*`, `+`, digit, etc.).
   - Rewrites duplicates with sequential `A–Z` characters.
5. **Result reporting** – Prints either **strong** or **suggested fix**.
6. **Loop back** to prompt.

## 5 . Testing
Unit-style tests were performed manually with edge-case inputs:

| Input | Expected Output |
|-------|-----------------|
| `aaaaaa` | Suggestion incl. uppercase, digit, `*+`, removes repeats |
| `AB12*+` | Suggestion to add one lowercase char & length > 6 |
| `GoodP@ssword1*+` | Already strong |

