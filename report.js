let dbInstance = null;

// Function to get query parameter by name
function getQueryParam(name) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(name);
}

async function initDB() {
    const SQL = await initSqlJs({
        locateFile: file => `https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.8.0/${file}`
    });
    
    const response = await fetch('Sample4GRM.mmb');
    const dbBuffer = await response.arrayBuffer();
    dbInstance = new SQL.Database(new Uint8Array(dbBuffer));
}

function renderReports(data) {
    const container = document.getElementById('report-nav');
    let totalReports = 0;

    data.reportGroups.forEach(group => {
        totalReports += group.reports.length;
        const groupDiv = document.createElement('div');
        groupDiv.className = 'report-group';
        groupDiv.innerHTML = `<h3>${group.name} (${group.reports.length})</h3>`;

        group.reports.forEach(report => {
            const reportElem = document.createElement('div');
            reportElem.className = 'report-item';
            reportElem.textContent = report.name;
            reportElem.onclick = () => loadReport(report);
            groupDiv.appendChild(reportElem);
        });

        container.appendChild(groupDiv);
    });

    document.getElementById('report-total').textContent = `TOTAL: ${totalReports} reports`;
}

async function loadReport(report) {
    try {
        const sqlPath = `packages/${report.path}`;
        const response = await fetch(sqlPath);
        const sql = await response.text();
       
        // Display SQL content in the UI
        renderSQLContent(report.name, sql);

        const stmt = dbInstance.prepare(sql);
        const results = stmt.getAsObject({});
        const columns = stmt.getColumnNames();
        
        renderResults(report.name, columns, results);

        // Update URL with the current report's name
        window.history.pushState(
            { reportName: report.name },  // State object (can store data for the history entry)
            '',                           // Title (optional)
            `?report=${encodeURIComponent(report.name)}`  // Update the URL with the report name
        );
    } catch (error) {
        console.error('Error executing report:', error);

        alert('Error loading report: ' + error.message);
    } finally {
        console.log(`Finished processing report: ${report.name}`);
        // Optionally, update UI to reflect the loading status
    }
}

function renderResults(title, columns, rows) {
    const resultDiv = document.getElementById('query-result');
    document.getElementById('report-title').textContent = title;
    
    let html = '<table><tr>';
    columns.forEach(col => html += `<th>${col}</th>`);
    html += '</tr><tr>';
    
    columns.forEach(col => {
        html += `<td>${rows[col] || ''}</td>`;
    });
    
    html += '</tr></table>';
    resultDiv.innerHTML = html;
}

// Function to render the SQL content and title in the UI
function renderSQLContent(title, sql) {
    const sqlContainer = document.getElementById('sql-container');

    // Set the report title for the SQL section
    const reportTitleElem = sqlContainer.querySelector('#sql-title');
    reportTitleElem.textContent = `SQL for: ${title}`;  // Dynamic title based on report

    // Set the SQL content in the pre tag
    const sqlContentElem = sqlContainer.querySelector('#sql-content');
    sqlContentElem.textContent = sql;  // Display the SQL query in pre-formatted text
}

// 初始化
(async () => {
    await initDB();
    const response = await fetch('reports.json');
    const data = await response.json();
    renderReports(data);

    // Check if there's a report query parameter in the URL
    const reportParam = getQueryParam('report');
    if (reportParam) {
        // Find the report corresponding to the query parameter
        const report = data.reportGroups.flatMap(group => group.reports)
            .find(report => report.name === reportParam);

        // If the report exists, load it
        if (report) {
            loadReport(report);
        } else {
            alert(`Report ${reportParam} not found!`);
        }
    }
})();
