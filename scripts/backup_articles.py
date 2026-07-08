import requests
import json
import os
import datetime

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def _load_env():
    """Load SUPABASE_URL / SUPABASE_ANON_KEY.

    Mirrors lib/app/env.dart: read a root .env file (git-ignored) first,
    then fall back to process environment variables. Credentials are never
    hardcoded here.
    """
    env_path = os.path.join(PROJECT_ROOT, '.env')
    if os.path.isfile(env_path):
        with open(env_path, 'r', encoding='utf-8') as f:
            for line in f:
                trimmed = line.strip()
                if not trimmed or trimmed.startswith('#'):
                    continue
                idx = trimmed.find('=')
                if idx < 1:
                    continue
                key = trimmed[:idx].strip()
                value = trimmed[idx + 1:].strip()
                if key in ('SUPABASE_URL', 'SUPABASE_ANON_KEY') and value:
                    os.environ.setdefault(key, value)

    supabase_url = os.environ.get('SUPABASE_URL', '')
    supabase_anon_key = os.environ.get('SUPABASE_ANON_KEY', '')
    if not supabase_url or not supabase_anon_key:
        print('Backup aborted: SUPABASE_URL and SUPABASE_ANON_KEY must be set.')
        print('Set them in a git-ignored .env file or as environment variables.')
        os._exit(1)
    return supabase_url, supabase_anon_key


SUPABASE_URL, SUPABASE_ANON_KEY = _load_env()

BACKUP_DIR = os.path.join(PROJECT_ROOT, 'backups')
ARTICLES_URL = f'{SUPABASE_URL}/rest/v1/articles'


def main():
    os.makedirs(BACKUP_DIR, exist_ok=True)

    response = requests.get(
        ARTICLES_URL,
        params={'select': '*'},
        headers={
            'apikey': SUPABASE_ANON_KEY,
            'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
            'Range': '0-9999',
        },
    )

    if response.status_code != 200:
        print(f'Backup failed: HTTP {response.status_code}')
        print(response.text)
        os._exit(1)

    articles = response.json()
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d_%H%M')
    filename = f'articles_backup_{timestamp}.json'
    filepath = os.path.join(BACKUP_DIR, filename)

    with open(filepath, 'w', encoding='utf-8') as backup_file:
        json.dump(articles, backup_file, indent=2, ensure_ascii=False)

    file_size_kb = os.path.getsize(filepath) / 1024

    print(f'✅ Backup complete: {filename}')
    print(f'   Articles saved: {len(articles)}')
    print(f'   File size: {file_size_kb:.2f} KB')


if __name__ == '__main__':
    main()
