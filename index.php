<!doctype html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Client-Side Import Export</title>
    <link rel="stylesheet" href="assets/css/app.css">
</head>
<body>
    <main class="shell">
        <header class="page-header">
            <div>
                <h1>Client-Side Processing</h1>
                <p>Import batch, export pagination, dan cetak langsung dari browser.</p>
            </div>
        </header>

        <section class="panel">
            <div class="panel-title">
                <h2>Import CSV / XLSX</h2>
                <span>Batch dikirim berurutan ke PHP</span>
            </div>
            <div class="controls">
                <input id="csvFile" type="file" accept=".csv,text/csv,.xlsx,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
                <label>
                    Batch
                    <select id="batchSize">
                        <option value="100">100</option>
                        <option value="250" selected>250</option>
                        <option value="500">500</option>
                    </select>
                </label>
                <button id="btnImport" type="button">Import</button>
            </div>
            <div class="progress">
                <div id="importProgress" class="progress-bar"></div>
            </div>
            <p id="importStatus" class="status">Belum ada proses import.</p>
        </section>

        <section class="panel">
            <div class="panel-title">
                <h2>Export Data Kompleks</h2>
                <span>Data order + customer + sales + produk</span>
            </div>
            <div class="controls">
                <label>
                    Page size
                    <select id="pageSize">
                        <option value="100">100</option>
                        <option value="250" selected>250</option>
                        <option value="500">500</option>
                    </select>
                </label>
                <button id="btnExportXlsx" type="button">Download XLSX</button>
                <button id="btnExportCsv" type="button">Download CSV</button>
                <button id="btnLoadPrint" type="button">Muat untuk Cetak</button>
                <button id="btnPrint" type="button" disabled>Cetak</button>
                <button id="btnExportPdf" type="button" disabled>Cetak PDF</button>
            </div>
            <div class="progress">
                <div id="exportProgress" class="progress-bar"></div>
            </div>
            <p id="exportStatus" class="status">Belum ada proses export.</p>
        </section>

        <section class="panel">
            <div class="panel-title">
                <h2>Preview Cetak</h2>
                <span id="previewCount">0 baris</span>
            </div>
            <div id="printArea" class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Order</th>
                            <th>Tanggal</th>
                            <th>Customer</th>
                            <th>Kota</th>
                            <th>Sales</th>
                            <th>Produk</th>
                            <th>Qty</th>
                            <th>Total</th>
                        </tr>
                    </thead>
                    <tbody id="printBody">
                        <tr><td colspan="8" class="empty">Belum ada data.</td></tr>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <script src="node_modules/jquery/dist/jquery.min.js"></script>
    <script src="node_modules/papaparse/papaparse.min.js"></script>
    <script src="node_modules/exceljs/dist/exceljs.min.js"></script>
    <script src="node_modules/file-saver/dist/FileSaver.min.js"></script>
    <script src="node_modules/html2pdf.js/dist/html2pdf.bundle.min.js"></script>
    <script src="assets/js/app.js"></script>
</body>
</html>
