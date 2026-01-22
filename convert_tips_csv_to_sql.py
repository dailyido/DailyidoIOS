#!/usr/bin/env python3
"""
Convert wedding tips CSV to SQL INSERT statements for Supabase.
Handles:
- UUID generation
- Blank cells → FALSE for boolean fields
- Text escaping for SQL
- is_active = true for all rows
- created_at timestamp
"""

import csv
import uuid
from datetime import datetime

# Input/output files
INPUT_CSV = "/Users/katiepietrowski/Downloads/Copy FOR DATABASE of Tips By Category.xlsx - CURRENT 400 Tips.csv"
OUTPUT_SQL = "/Users/katiepietrowski/DailyIDo/DailyIDo/wedding_tips_import.sql"

def escape_sql_string(s):
    """Escape single quotes for SQL"""
    if s is None:
        return None
    return s.replace("'", "''")

def to_bool(value):
    """Convert spreadsheet value to SQL boolean"""
    if value is None or value.strip() == '':
        return 'false'
    return 'true' if value.strip().upper() == 'TRUE' else 'false'

def to_int_or_null(value):
    """Convert to integer or NULL"""
    if value is None or value.strip() == '':
        return 'NULL'
    try:
        return str(int(value))
    except ValueError:
        return 'NULL'

def to_string_or_null(value):
    """Convert to escaped string or NULL"""
    if value is None or value.strip() == '':
        return 'NULL'
    return f"'{escape_sql_string(value.strip())}'"

def main():
    rows = []

    with open(INPUT_CSV, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)

    print(f"Read {len(rows)} rows from CSV")

    # Generate SQL
    sql_lines = []
    sql_lines.append("-- Wedding Tips Import for Supabase")
    sql_lines.append(f"-- Generated: {datetime.now().isoformat()}")
    sql_lines.append(f"-- Total rows: {len(rows)}")
    sql_lines.append("")
    sql_lines.append("-- First, clear existing data (optional - comment out if you want to keep existing)")
    sql_lines.append("-- DELETE FROM wedding_tips;")
    sql_lines.append("")
    sql_lines.append("-- Insert all tips")
    sql_lines.append("INSERT INTO wedding_tips (")
    sql_lines.append("    id, category, specific_day, title, tip_text, priority,")
    sql_lines.append("    month_category, fun_tip, has_illustration, illustration_url,")
    sql_lines.append("    affiliate_button_text, affiliate_url, on_checklist, wedding_type,")
    sql_lines.append("    is_active, created_at")
    sql_lines.append(") VALUES")

    value_rows = []
    for row in rows:
        tip_id = str(uuid.uuid4())
        category = to_string_or_null(row.get('Category', ''))
        specific_day = to_int_or_null(row.get('specific_day', ''))
        title = to_string_or_null(row.get('title', ''))
        tip_text = to_string_or_null(row.get('tip_text', ''))
        priority = to_int_or_null(row.get('priority', ''))
        month_category = to_string_or_null(row.get('month_category', ''))
        fun_tip = to_bool(row.get('fun_tip', ''))
        has_illustration = to_bool(row.get('has_illustration', ''))
        illustration_url = to_string_or_null(row.get('illustration_url', ''))
        affiliate_button_text = to_string_or_null(row.get('affiliate_button_text', ''))
        affiliate_url = to_string_or_null(row.get('affiliate_url', ''))
        on_checklist = to_bool(row.get('on_checklist', ''))
        wedding_type = to_string_or_null(row.get('wedding_type', ''))

        value_row = f"""(
    '{tip_id}', {category}, {specific_day}, {title}, {tip_text}, {priority},
    {month_category}, {fun_tip}, {has_illustration}, {illustration_url},
    {affiliate_button_text}, {affiliate_url}, {on_checklist}, {wedding_type},
    true, NOW()
)"""
        value_rows.append(value_row)

    sql_lines.append(",\n".join(value_rows) + ";")

    # Write output
    with open(OUTPUT_SQL, 'w', encoding='utf-8') as f:
        f.write("\n".join(sql_lines))

    print(f"Generated SQL file: {OUTPUT_SQL}")
    print(f"Total INSERT statements: {len(value_rows)}")

    # Print some stats
    fun_tip_count = sum(1 for r in rows if r.get('fun_tip', '').strip().upper() == 'TRUE')
    priority_1_count = sum(1 for r in rows if r.get('priority', '').strip() == '1')
    tented_count = sum(1 for r in rows if r.get('wedding_type', '').strip().lower() == 'tented')
    negative_days = sum(1 for r in rows if r.get('specific_day', '').strip().startswith('-'))

    print(f"\nStats:")
    print(f"  Fun tip placeholders: {fun_tip_count}")
    print(f"  Priority 1 (critical): {priority_1_count}")
    print(f"  Tented-specific: {tented_count}")
    print(f"  Post-wedding (negative days): {negative_days}")

if __name__ == "__main__":
    main()
