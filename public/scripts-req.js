async function submitChanges() {
    const rows = document.querySelectorAll('tbody tr'); // Get all rows in the table

    for (const row of rows) {
        // Extract ID and violation type
        const id = row.querySelector('input[id="identifier"]')?.value; // Matches 'identifier' ID set in renderTable
        const violationType = row.dataset.violationType; // Matches data attribute set in renderTable

        // Extract reason and approval based on violation type
        let reason, approval;
        if (violationType === 'SLM') {
            reason = row.querySelector(`input[id^="slm-reason-${id}"]`)?.value; // Matches IDs set in SLM section
            approval = row.querySelector(`select[id^="slm-approval-${id}"]`)?.value; // Matches IDs set in SLM section
        } else if (violationType === 'ReqSurvey') {
            reason = row.querySelector(`input[id^="reqsurvey-reason-${id}"]`)?.value; // Matches IDs set in ReqSurvey section
            approval = row.querySelector(`select[id^="reqsurvey-approval-${id}"]`)?.value; // Matches IDs set in ReqSurvey section
        }

        console.log('Processing row:', { id, violationType, reason, approval });

        // Skip rows with missing data
        if (!id || !violationType || !reason || !approval) {
            console.warn('Skipping row due to missing data:', { id, violationType, reason, approval });
            continue;
        }

        // Prepare data for submission
        const data = { id, violationType, reason, approval };
        console.log('Submitting data:', data); // Debugging

        try {
            // Send data via POST request
            const response = await fetch('/updateREQViolation', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            // Handle response
            if (!response.ok) {
                throw new Error(`Error updating violation for row: ${id}`);
            }

            console.log(`Violation updated successfully for row ID: ${id}`);
        } catch (error) {
            console.error(`Error updating violation for row ID: ${id}`, error);
            alert(`Error updating violation for row ID: ${id}`);
        }
    }

    alert('All changes have been submitted successfully.');
}
function createDetailsRow(rowData) {
    const detailsRow = document.createElement('tr');
    detailsRow.className = 'details-row';
    detailsRow.style.display = 'none';
    
    detailsRow.innerHTML = `
        <td colspan="100%"> <!-- Will span all columns -->
            <div class="details-content">
                <h4>Request Details</h4>
                <div class="details-grid">
                    <div><strong>Customer:</strong> ${rowData.Customer_Full_Name || 'N/A'}</div>
                    <div><strong>Email:</strong> ${rowData.Customer_Internet_Email || 'N/A'}</div>
                    <div><strong>Phone:</strong> ${rowData.Customer_Phone_Number || 'N/A'}</div>
                    <div><strong>Priority:</strong> ${rowData.Request_Priority || 'N/A'}</div>
                    <div><strong>Status:</strong> ${rowData.Request_SLM_Status || 'N/A'}</div>
                    <div><strong>Agent Name:</strong> ${rowData.Full_Name || 'N/A'}</div>
                    <div><strong>Category 1:</strong> ${rowData.Request_Categorization1 || 'N/A'}</div>
                    <div><strong>Category 2:</strong> ${rowData.Request_Categorization2 || 'N/A'}</div>
                    <div><strong>Category 3:</strong> ${rowData.Request_Categorization3 || 'N/A'}</div>
                    <div><strong>Summary:</strong> ${rowData.Summary || 'N/A'}</div>
                </div>
            </div>
        </td>
    `;
    
    return detailsRow;
}

// Modified fetchData function
async function fetchData(apiEndpoint, tableId) {
    try {
        const response = await fetch(apiEndpoint);
        if (!response.ok) throw new Error('Network response was not ok');
        const data = await response.json();
        renderTable(data, tableId);
    } catch (error) {
        console.error('Error fetching data:', error);
        alert('Failed to load data. Please try again.');
    }
}

// Modified renderTable function
function renderTable(data, tableId) {
    const tbody = document.querySelector(`${tableId} tbody`);
    tbody.innerHTML = '';

    data.forEach(row => {
        // Main Row
        const mainRow = document.createElement('tr');
        
        // ID Column (always readonly)
        mainRow.innerHTML = `
            <td><input type="text" value="${row.ID || ''}" id="identifier" readonly></td>
            <td>${row.Request_Number || ''}</td>
             <td>${row.Submit_Date_Time || ''}</td>
            <!-- ... other non-editable columns ... -->
        `;

        // Violation SLM Section
        mainRow.innerHTML += `
            <td>${row.Violation_SLM || ''}</td>
            <td>
                <input type="text" 
                       value="${row.Violation_SLM_Reason || ''}" 
                       ${row.Violation_SLM ? '' : 'readonly'}
                       class="${row.Violation_SLM ? 'editable-field' : ''}"
                       id="slm-reason-${row.ID}">
            </td>
            <td>
                ${row.Violation_SLM ? `
                    <select id="slm-approval-${row.ID}" class="editable-field">
                        <option value="">-- Select --</option>
                        <option value="1" ${row.Violation_SLM_Approval == 1 ? 'selected' : ''}>Approve</option>
                        <option value="0" ${row.Violation_SLM_Approval == 0 ? 'selected' : ''}>Reject</option>
                    </select>
                ` : `
                    <input type="text" 
                           value="${row.Violation_SLM_Approval ? 'Approved' : 'Rejected'}" 
                           readonly>
                `}
            </td>
        `;

        // Violation ReqSurvey Section
        mainRow.innerHTML += `
            <td>${row.Violation_ReqSurvey || ''}</td>
            <td>
                <input type="text" 
                       value="${row.Violation_ReqSurvey_Reason || ''}" 
                       ${row.Violation_ReqSurvey ? '' : 'readonly'}
                       class="${row.Violation_ReqSurvey ? 'editable-field' : ''}"
                       id="reqsurvey-reason-${row.ID}">
            </td>
            <td>
                ${row.Violation_ReqSurvey ? `
                    <select id="reqsurvey-approval-${row.ID}" class="editable-field">
                        <option value="">-- Select --</option>
                        <option value="1" ${row.Violation_ReqSurvey_Approval == 1 ? 'selected' : ''}>Approve</option>
                        <option value="0" ${row.Violation_ReqSurvey_Approval == 0 ? 'selected' : ''}>Reject</option>
                    </select>
                ` : `
                    <input type="text" 
                           value="${row.Violation_ReqSurvey_Approval ? 'Approved' : 'Rejected'}" 
                           readonly>
                `}
            </td>
            <!-- Toggle Button for Details -->
            <td>
                <button class="toggle-details">Show Details</button>
        `;
        // Set violation type if applicable
        if (row.Violation_SLM) mainRow.dataset.violationType = 'SLM';
        if (row.Violation_ReqSurvey) mainRow.dataset.violationType = 'ReqSurvey';

        // Create and append details row
        const detailsRow = createDetailsRow(row);
        tbody.appendChild(mainRow);
        tbody.appendChild(detailsRow);
    });

    // Add event listeners to toggle buttons
    document.querySelectorAll('.toggle-details').forEach(button => {
        button.addEventListener('click', function() {
            const detailsRow = this.closest('tr').nextElementSibling;
            const isHidden = detailsRow.style.display === 'none';
            
            detailsRow.style.display = isHidden ? 'table-row' : 'none';
            this.textContent = isHidden ? 'Hide Details' : 'Show Details';
        });
    });
}
