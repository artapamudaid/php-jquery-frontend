Saya ingin membangun sistem yang efisien dengan pendekatan client-side processing menggunakan jQuery dan PHP. Tolong buatkan struktur kode untuk alur berikut:

Fitur Import (Upload): Gunakan PapaParse untuk membaca file CSV di browser, bagi data menjadi batch (100-500 baris), dan kirim ke endpoint PHP secara berurutan dengan AJAX agar server tidak timeout.

Fitur Download: Buat logika untuk mengambil data dari PHP dengan pagination agar data tidak ditarik sekaligus. Setelah data terkumpul di browser, gunakan library (seperti SheetJS) untuk men-generate file Excel/CSV langsung di sisi client.

Fitur Cetak (Print): Buat fungsi untuk merender data dalam format HTML tabel yang rapi, lalu gunakan perintah JavaScript window.print() untuk mencetaknya sebagai dokumen atau menyimpannya sebagai PDF tanpa perlu memproses PDF di backend.
Progress Feedback: Pastikan setiap proses (import/download) memiliki indikator visual (seperti progress bar) agar pengguna mengetahui status prosesnya.

Fokuslah pada efisiensi resource di sisi backend.

Buatkan sql file dan .csv/xlsx file untuk import data.

buatdata export yg lebih compleks banyak join