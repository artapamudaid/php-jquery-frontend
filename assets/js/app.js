(function ($) {
    const api = {
        import: 'api/import.php',
        export: 'api/export.php'
    };

    let printableRows = [];

    function setProgress(selector, current, total) {
        const percent = total === 0 ? 0 : Math.round((current / total) * 100);
        $(selector).css('width', `${Math.min(percent, 100)}%`);
        return percent;
    }

    function postBatch(rows, batchIndex, totalBatches) {
        return $.ajax({
            url: api.import,
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                batch_index: batchIndex,
                total_batches: totalBatches,
                rows
            })
        });
    }

    async function processImportRows(rows, batchSize) {
        const totalBatches = Math.ceil(rows.length / batchSize);
        let imported = 0;

        try {
            for (let index = 0; index < totalBatches; index++) {
                const start = index * batchSize;
                const batch = rows.slice(start, start + batchSize);
                const response = await postBatch(batch, index + 1, totalBatches);
                imported += response.inserted || 0;
                const percent = setProgress('#importProgress', index + 1, totalBatches);
                $('#importStatus').text(`Batch ${index + 1}/${totalBatches} selesai. ${percent}% - ${imported} baris tersimpan.`);
            }
        } catch (error) {
            $('#importStatus').text(error.responseJSON?.message || 'Import gagal.');
            return;
        } finally {
            $('#btnImport').prop('disabled', false);
        }

        $('#importStatus').text(`Import selesai. ${imported} baris diproses.`);
    }

    async function importCsv() {
        const file = $('#csvFile')[0].files[0];
        const batchSize = Number($('#batchSize').val());

        if (!file) {
            $('#importStatus').text('Pilih file CSV/XLSX terlebih dahulu.');
            return;
        }

        $('#btnImport').prop('disabled', true);
        $('#importProgress').css('width', '0%');
        $('#importStatus').text('Membaca file di browser...');

        if (file.name.endsWith('.xlsx')) {
            const reader = new FileReader();
            reader.onload = async (e) => {
                const buffer = e.target.result;
                const workbook = new ExcelJS.Workbook();
                await workbook.xlsx.load(buffer);
                const worksheet = workbook.worksheets[0];
                let rows = [];
                let keys = [];
                worksheet.eachRow((row, rowNumber) => {
                    if (rowNumber === 1) {
                        keys = row.values.slice(1);
                    } else {
                        let rowData = {};
                        row.values.slice(1).forEach((val, idx) => {
                            rowData[keys[idx]] = val;
                        });
                        rows.push(rowData);
                    }
                });
                processImportRows(rows, batchSize);
            };
            reader.readAsArrayBuffer(file);
        } else {
            Papa.parse(file, {
                header: true,
                skipEmptyLines: true,
                worker: true,
                complete: function (result) {
                    processImportRows(result.data, batchSize);
                },
                error: function () {
                    $('#btnImport').prop('disabled', false);
                    $('#importStatus').text('CSV tidak dapat dibaca.');
                }
            });
        }
    }

    function fetchExportPage(page, pageSize) {
        return $.getJSON(api.export, {
            page,
            page_size: pageSize
        });
    }

    async function fetchAllExportRows() {
        const pageSize = Number($('#pageSize').val());
        const allRows = [];
        let page = 1;
        let totalPages = 1;

        $('#exportProgress').css('width', '0%');
        $('#exportStatus').text('Mengambil data halaman 1...');

        do {
            const response = await fetchExportPage(page, pageSize);
            totalPages = response.meta.total_pages || 1;
            allRows.push(...response.data);
            const percent = setProgress('#exportProgress', page, totalPages);
            $('#exportStatus').text(`Mengambil halaman ${page}/${totalPages}. ${percent}% - ${allRows.length} baris.`);
            page++;
        } while (page <= totalPages);

        $('#exportStatus').text(`Data terkumpul di browser: ${allRows.length} baris.`);
        return allRows;
    }

    function downloadRows(rows, type) {
        if (type === 'csv') {
            const csvData = Papa.unparse(rows);
            const blob = new Blob([csvData], { type: 'text/csv;charset=utf-8;' });
            saveAs(blob, 'export_orders.csv');
            return;
        }

        const workbook = new ExcelJS.Workbook();
        const sheet = workbook.addWorksheet('export_orders');
        
        if (rows.length > 0) {
            sheet.columns = Object.keys(rows[0]).map(key => ({ header: key, key: key }));
            rows.forEach(row => sheet.addRow(row));
        }

        workbook.xlsx.writeBuffer().then(function(buffer) {
            const blob = new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
            saveAs(blob, 'export_orders.xlsx');
        });
    }

    function money(value) {
        return Number(value || 0).toLocaleString('id-ID', {
            style: 'currency',
            currency: 'IDR',
            maximumFractionDigits: 0
        });
    }

    function renderPrintTable(rows) {
        const html = rows.map(row => `
            <tr>
                <td>${row.order_number}</td>
                <td>${row.order_date}</td>
                <td>${row.customer_name}</td>
                <td>${row.city}</td>
                <td>${row.sales_name}</td>
                <td>${row.product_names}</td>
                <td>${row.total_qty}</td>
                <td>${money(row.grand_total)}</td>
            </tr>
        `).join('');

        $('#printBody').html(html || '<tr><td colspan="8" class="empty">Tidak ada data.</td></tr>');
        $('#previewCount').text(`${rows.length} baris`);
        $('#btnPrint, #btnExportPdf').prop('disabled', rows.length === 0);
    }

    $('#btnImport').on('click', importCsv);

    $('#btnExportXlsx').on('click', async function () {
        $(this).prop('disabled', true);
        try {
            downloadRows(await fetchAllExportRows(), 'xlsx');
        } finally {
            $(this).prop('disabled', false);
        }
    });

    $('#btnExportCsv').on('click', async function () {
        $(this).prop('disabled', true);
        try {
            downloadRows(await fetchAllExportRows(), 'csv');
        } finally {
            $(this).prop('disabled', false);
        }
    });

    $('#btnLoadPrint').on('click', async function () {
        $(this).prop('disabled', true);
        try {
            printableRows = await fetchAllExportRows();
            renderPrintTable(printableRows);
        } finally {
            $(this).prop('disabled', false);
        }
    });

    $('#btnPrint').on('click', function () {
        window.print();
    });

    $('#btnExportPdf').on('click', function () {
        const element = document.getElementById('printArea');
        const opt = {
            margin:       0.5,
            filename:     'export_orders.pdf',
            image:        { type: 'jpeg', quality: 0.98 },
            html2canvas:  { scale: 2 },
            jsPDF:        { unit: 'in', format: 'letter', orientation: 'landscape' }
        };
        html2pdf().set(opt).from(element).save();
    });

    // Auto load data on page load
    $(document).ready(async function() {
        $('#btnLoadPrint').trigger('click');
    });
})(jQuery);
