# Content Management Instructions

## Adding New Articles to Supabase

### 1. Required Fields (All 10 Must Be Present)
Every article must follow the WardReady schema with these exact fields:

| Field | Type | Description |
|-------|------|-------------|
| `id` | TEXT | Unique identifier (lowercase, hyphenated slug) |
| `title` | TEXT | Article title |
| `category` | JSONB | Array like `["Internal Medicine", "Cardiology"]` |
| `content` | JSONB | Object with 10 clinical sections |
| `image_url` | TEXT | Optional - URL to image in Supabase Storage |
| `video_url` | TEXT | Optional - YouTube or video link |
| `is_high_yield` | BOOLEAN | Recommended: true if high-yield content |
| `parent_category` | TEXT | Auto-derived but should match `category[0]` |
| `subcategory` | TEXT | Should match `category[1]` |
| `updated_at` | TIMESTAMPTZ | REQUIRED for incremental sync |

### 2. Sample SQL INSERT Statement
```sql
INSERT INTO articles (
  id,
  title,
  category,
  content,
  is_high_yield,
  parent_category,
  subcategory,
  updated_at
) VALUES (
  'wardready-acute-myocardial-infarction',
  'Acute Myocardial Infarction',
  '["Internal Medicine", "Cardiology"]'::jsonb,
  '{
    "definition": "Myocardial infarction is myocardial necrosis due to ischemia.",
    "epidemiology": "Leading cause of death worldwide...",
    "etiology": "Atherosclerotic plaque rupture...",
    "pathophysiology": "Coronary artery occlusion leads to...",
    "clinicalFeatures": "Chest pain, diaphoresis, nausea...",
    "diagnosis": "STEMI: ST elevation on ECG...",
    "treatment": "MONA-BASH: Morphine, Oxygen, Nitrates...",
    "complications": "Arrhythmias, heart failure, cardiogenic shock...",
    "ethiopianContext": "Common presentations and local resources...",
    "mnemonics": "MONA-BASH, STElevation criteria..."
  }'::jsonb,
  true,
  'Internal Medicine',
  'Cardiology',
  NOW()
);
```

### 3. The 10 Clinical Sections (Required in Content JSONB)
1. `definition` - Concise disease definition
2. `epidemiology` - Disease frequency and demographics
3. `etiology` - Cause and risk factors
4. `pathophysiology` - Mechanism of disease
5. `clinicalFeatures` - Signs and symptoms
6. `diagnosis` - How to diagnose
7. `treatment` - Management approach
8. `complications` - What can go wrong
9. `ethiopianContext` - Local clinical pearls (REQUIRED)
10. `mnemonics` - Memory aids (REQUIRED)

### 4. Category Taxonomy Rules

#### Parent Categories (Top-Level)
- Internal Medicine
- Pediatrics
- OB/GYN
- Surgery
- Psychiatry
- Community Medicine
- Emergency Medicine
- Anesthesia

#### Subcategories (Second-Level)
- Cardiology (under Internal Medicine)
- Pulmonology (under Internal Medicine)
- Infectious Diseases (under Internal Medicine)
- Neonatology (under Pediatrics)
- Obstetrics (under OB/GYN)
- etc.

### 5. The `updated_at` Requirement
**CRITICAL**: Every INSERT or UPDATE must include `updated_at` or the sync will not detect changes.

```sql
-- Always use NOW() or explicit timestamp
updated_at: NOW()
```

The app uses cursor-based incremental sync:
- Local max `updated_at` is stored
- Next sync fetches `WHERE updated_at > last_sync_cursor`

### 6. Adding Quiz Questions

Questions should reference existing articles via `article_id`:

```sql
INSERT INTO quiz_table (
  remote_id,
  article_id,
  stem,
  option_a,
  option_b,
  option_c,
  option_d,
  correct_option,
  explanation,
  category,
  difficulty,
  tested_field,
  source_type,
  exam_year,
  exam_source,
  updated_at
) VALUES (
  'qr-ami-001',
  'wardready-acute-myocardial-infarction',
  'A 45-year-old male presents with crushing chest pain...',
  'ST elevation MI',
  'Unstable angina',
  'Pericarditis',
  'Aortic dissection',
  'A',
  'ST elevation with reciprocal changes...',
  'Internal Medicine',
  'medium',
  'clinicalFeatures',
  'original',
  NULL,
  NULL,
  NOW()
);
```

### 7. Testing Your Changes
1. Wait ~1 minute for Supabase replication
2. On device: Pull-to-refresh on article list
3. Search for your new article
4. Verify all sections render correctly