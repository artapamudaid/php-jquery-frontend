# PHP jQuery Client-Side Processing Demo

Contoh sistem import, export, dan print yang memindahkan pekerjaan berat ke browser:

- Import CSV dibaca di browser dengan PapaParse, lalu dikirim batch ke PHP.
- Export mengambil data dari PHP per halaman, lalu membuat XLSX/CSV di browser dengan SheetJS.
- Print merender tabel HTML di browser dan memakai `window.print()`.
- Backend hanya memproses batch/page kecil agar hemat memori dan mengurangi risiko timeout.

## Menjalankan

1. Import database:

   ```bash
   mysql -h 127.0.0.1 -u root < database/schema.sql
   ```

2. Sesuaikan kredensial di `api/config.php` bila perlu.

3. Jalankan server PHP:

   ```bash
   php -S 127.0.0.1:8000
   ```

4. Buka `http://127.0.0.1:8000`.

## Contoh Data

- `samples/import_customers.csv`
- `samples/import_customers.xlsx`

File XLSX bisa dipakai untuk contoh data spreadsheet. Untuk fitur import demo ini, simpan spreadsheet sebagai CSV lalu upload CSV agar PapaParse dapat memprosesnya langsung di browser.
