function showTab(tabId) {
    document.querySelectorAll('.tab').forEach(tab => {
        tab.classList.remove('active');
    });
    document.getElementById(tabId).classList.add('active');
}

async function submitChanges() {
    const rows = document.querySelectorAll('tbody tr'); // Get all rows in the table

    for (const row of rows) {
        const id = row.querySelector('input[id="identifier"]')?.value;
        const violationType = row.dataset.violationType; // Get violation type from data attribute
        const reason = row.querySelector('input[id="reason"]')?.value;
        const approval = row.querySelector('select[id="approval"]')?.value;

        console.log('Processing row:', { id, violationType, reason, approval });

        if (!id || !violationType || !reason || !approval) {
            console.warn('Skipping row due to missing data:', { id, violationType, reason, approval });
            continue; // Skip rows with missing data
        }

        const data = {
            id,
            violationType,
            reason,
            approval
        };

        console.log('Submitting data:', data); // Log the data being sent for debugging

        try {
            const response = await fetch('/updateCSQViolation', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });

            if (!response.ok) {
                throw new Error(`Error updating violation for row: ${id}`);
            }

            console.log('Violation updated successfully for row:', id);
        } catch (error) {
            console.error('Error updating violation for row:', id, error);
            alert(`Error updating violation for row: ${id}`);
        }
    }

    alert('All violations processed successfully');
}

async function fetchData(apiEndpoint, tableId) {
    try {
        const response = await fetch(apiEndpoint);
        if (!response.ok) {
            throw new Error(`Error fetching data: ${response.statusText}`);
        }
        const data = await response.json();
        const thead = document.querySelector(`${tableId} thead tr`);
        const tbody = document.querySelector(`${tableId} tbody`);
        tbody.innerHTML = '';
        thead.innerHTML = '';

        if (data.length > 0) {
            // Define the columns to display in the main table
            const mainColumns = [
                'ID',
                'Node_Session_Seq',
                'Violation_ABD',
                'Violation_ABD_Reason',
                'Violation_ABD_Approval',
                'Violation_Ring',
                'Violation_Ring_Reason',
                'Violation_Ring_Approval',
                'Violation_CallSurvey',
                'Violation_CallSurvey_Reason',
                'Violation_CallSurvey_Approval'
            ];

            // Add table headers dynamically based on the mainColumns
            mainColumns.forEach(key => {
                const headerText = key.replace(/_/g, ' '); // Replace underscores with spaces
                thead.innerHTML += `<th>${headerText}</th>`;
            });

            // Add a header for the "Call Details" toggle button
            thead.innerHTML += `<th>Call Details</th>`;

            data.forEach(row => {
                const tr = document.createElement('tr');
                mainColumns.forEach(key => {
                    const value = row[key] === null ? '' : row[key];
                    let cellContent = `<input type="text" value="${value}" readonly>`; // Default to read-only

                    // Check for editable fields based on violation type
                    if (key === 'ID') {
                        cellContent = `<input type="text" value="${value}" id="identifier" readonly>`;
                    } else if (key === 'Violation_ABD_Reason' && row['Violation_ABD'] === true) {
                        cellContent = `<input type="text" value="${value}" id="reason">`; // Editable reason
                        tr.dataset.violationType = 'ABD'; // Set violation type
                    } else if (key === 'Violation_ABD_Approval' && row['Violation_ABD'] === true) {
                        cellContent = `
                            <select id="approval">
                                <option value="" ${value === null ? 'selected' : ''}>-- Select --</option>
                                <option value="1" ${value === true || value === 1 ? 'selected' : ''}>Yes</option>
                                <option value="0" ${value === false || value === 0 ? 'selected' : ''}>No</option>
                            </select>
                        `; // Editable dropdown for approval
                    } else if (key === 'Violation_Ring_Reason' && row['Violation_Ring'] === true) {
                        cellContent = `<input type="text" value="${value}" id="reason">`; // Editable reason
                        tr.dataset.violationType = 'Ring'; // Set violation type
                    } else if (key === 'Violation_Ring_Approval' && row['Violation_Ring'] === true) {
                        cellContent = `
                            <select id="approval">
                                <option value="" ${value === null ? 'selected' : ''}>-- Select --</option>
                                <option value="1" ${value === true || value === 1 ? 'selected' : ''}>Yes</option>
                                <option value="0" ${value === false || value === 0 ? 'selected' : ''}>No</option>
                            </select>
                        `; // Editable dropdown for approval
                    } else if (key === 'Violation_CallSurvey_Reason' && row['Violation_CallSurvey'] === true) {
                        cellContent = `<input type="text" value="${value}" id="reason">`; // Editable reason
                        tr.dataset.violationType = 'CallSurvey'; // Set violation type
                    } else if (key === 'Violation_CallSurvey_Approval' && row['Violation_CallSurvey'] === true) {
                        cellContent = `
                            <select id="approval">
                                <option value="" ${value === null ? 'selected' : ''}>-- Select --</option>
                                <option value="1" ${value === true || value === 1 ? 'selected' : ''}>Yes</option>
                                <option value="0" ${value === false || value === 0 ? 'selected' : ''}>No</option>
                            </select>
                        `; // Editable dropdown for approval
                    }

                    tr.innerHTML += `<td>${cellContent}</td>`;
                });

                // Add a button to toggle call details visibility
                const toggleButtonCell = document.createElement('td');
                const toggleButton = document.createElement('button');
                toggleButton.textContent = 'Toggle Call Details';
                toggleButton.onclick = () => toggleCallDetails(tr);
                toggleButtonCell.appendChild(toggleButton);
                tr.appendChild(toggleButtonCell);

                // Add call details row
                const callDetailsRow = document.createElement('tr');
                callDetailsRow.classList.add('call-details');
                callDetailsRow.style.display = 'none';
                const callDetailsCell = document.createElement('td');
                callDetailsCell.colSpan = mainColumns.length + 1; // Span all columns
                callDetailsCell.innerHTML = `
                    <div>
                        <strong>SessionID:</strong> ${row.SessionID}<br>
                        <strong>CallStartTime:</strong> ${row.CallStartTime}<br>
                        <strong>CallEndTime:</strong> ${row.CallEndTime}<br>
                        <strong>ContactDisposition:</strong> ${row.ContactDisposition}<br>
                        <strong>OriginatorDN:</strong> ${row.OriginatorDN}<br>
                        <strong>CalledNumber:</strong> ${row.CalledNumber}<br>
                        <strong>QueueTime:</strong> ${row.QueueTime}<br>
                        <strong>AgentName:</strong> ${row.AgentName}<br>
                        <strong>RingTime:</strong> ${row.RingTime}<br>
                        <strong>TalkTime:</strong> ${row.TalkTime}<br>
                        <strong>CallSurvey:</strong> ${row.CallSurvey}<br>
                    </div>
                `;
                callDetailsRow.appendChild(callDetailsCell);
                tbody.appendChild(tr);
                tbody.appendChild(callDetailsRow);
            });

            console.log('Table populated successfully:', data); // Log the data for debugging
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Failed to fetch data. Please try again later.');
    }
}

function toggleCallDetails(row) {
    const callDetailsRow = row.nextElementSibling;
    if (callDetailsRow.style.display === 'none') {
        callDetailsRow.style.display = '';
    } else {
        callDetailsRow.style.display = 'none';
    }
}

function toggleCallDetails(row) {
    const callDetailsRow = row.nextElementSibling;
    if (callDetailsRow.style.display === 'none') {
        callDetailsRow.style.display = '';
    } else {
        callDetailsRow.style.display = 'none';
    }
}