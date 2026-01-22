#!/usr/bin/env python3
"""
Convert fun tips CSV to SQL INSERT statements for Supabase.
"""

import csv
import uuid
from datetime import datetime

# Input/output files
INPUT_CSV = "/Users/katiepietrowski/Downloads/Copy of Fun Tips FOR DATABASE - fun_tips_seed.csv"
OUTPUT_SQL = "/Users/katiepietrowski/DailyIDo/DailyIDo/fun_tips_import.sql"

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
    sql_lines.append("-- Fun Tips Import for Supabase")
    sql_lines.append(f"-- Generated: {datetime.now().isoformat()}")
    sql_lines.append(f"-- Total rows: {len(rows)}")
    sql_lines.append("")
    sql_lines.append("-- First, clear existing data (optional - comment out if you want to keep existing)")
    sql_lines.append("-- DELETE FROM fun_tips;")
    sql_lines.append("")
    sql_lines.append("-- Insert all fun tips")
    sql_lines.append("INSERT INTO fun_tips (")
    sql_lines.append("    id, title, tip_text, category, priority,")
    sql_lines.append("    has_illustration, illustration_url,")
    sql_lines.append("    affiliate_button_text, affiliate_url,")
    sql_lines.append("    is_active, created_at")
    sql_lines.append(") VALUES")

    value_rows = []
    for row in rows:
        tip_id = str(uuid.uuid4())
        title = to_string_or_null(row.get('title', ''))
        tip_text = to_string_or_null(row.get('tip_text', ''))
        category = to_string_or_null(row.get('category', ''))
        priority = to_int_or_null(row.get('priority', ''))
        has_illustration = to_bool(row.get('has_illustration', ''))
        illustration_url = to_string_or_null(row.get('illustration_url', ''))
        affiliate_button_text = to_string_or_null(row.get('affiliate_button_text', ''))
        affiliate_url = to_string_or_null(row.get('affiliate_url', ''))

        value_row = f"""(
    '{tip_id}', {title}, {tip_text}, {category}, {priority},
    {has_illustration}, {illustration_url},
    {affiliate_button_text}, {affiliate_url},
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
    priority_1_count = sum(1 for r in rows if r.get('priority', '').strip() == '1')
    has_illustration_count = sum(1 for r in rows if r.get('has_illustration', '').strip().upper() == 'TRUE')
    has_affiliate_count = sum(1 for r in rows if r.get('affiliate_url', '').strip() != '')

    # Count unique categories
    categories = set(r.get('category', '').strip() for r in rows if r.get('category', '').strip())

    print(f"\nStats:")
    print(f"  Priority 1 (show first): {priority_1_count}")
    print(f"  Has illustration: {has_illustration_count}")
    print(f"  Has affiliate link: {has_affiliate_count}")
    print(f"  Unique categories: {len(categories)}")
    print(f"  Categories: {', '.join(sorted(categories))}")

if __name__ == "__main__":
    main()
