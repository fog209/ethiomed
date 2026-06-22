import requests
import json
import os
import datetime

SUPABASE_URL = 'https://kxcdzlyirdonkipcymvc.supabase.co'
SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt4Y2R6bHlpcmRvbmtpcGN5bXZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwMTgxNzcsImV4cCI6MjA5NjU5NDE3N30.S70lUuSwgQBb05BFdcjRAP8F4x2ydeVppljuS6yKlQY'

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
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
