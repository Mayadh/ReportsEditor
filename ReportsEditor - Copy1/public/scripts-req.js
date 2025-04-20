// Function to submit changes for editable fields
async function submitChanges() {
    const rows = document.querySelectorAll('tbody tr'); // Get all rows in the table

    for (const row of rows) {
        const id = row.querySelector('input[id^="identifier-"]')?.value; // Get ID from input field
        const violationType = row.dataset.violationType; // Get violation type from data attribute
        const reason = row.querySelector('input[id^="reason-"]')?.value; // Get reason from input field
        const approval = row.querySelector('select[id^="approval-"]')?.value; // Get approval from dropdown

        console.log('Processing row:', { id, violationType, reason, approval });

        // Skip rows with missing ID, violationType, reason, or approval
        if (!id || !violationType || !reason || !approval) {
            console.warn('Skipping row due to missing data:', { id, violationType, reason, approval });
            continue;
        }

        const data = {
            id,
            violationType,
            reason,
            approval
        };

        console.log('Submitting data:', data); // Log the data being sent for debugging

        try {
            const response = await fetch('/updateREQViolation', {
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
            // Add table headers dynamically based on the data fetched
            Object.keys(data[0]).forEach(key => {
                const headerText = key.replace(/_/g, ' '); // Replace underscores with spaces
                thead.innerHTML += `<th>${headerText}</th>`;
            });

            data.forEach((row, rowIndex) => {
                const tr = document.createElement('tr');
                Object.keys(row).forEach(key => {
                    const value = row[key] === null ? '' : row[key];
                    let cellContent = `<input type="text" value="${value}" readonly>`; // Default to read-only

                    // Debugging: Log the row data
                    console.log(`Row ${rowIndex + 1}:`, { key, value, row });

                    // Check for editable fields based on violation type
                    if (key === 'ID') {
                        cellContent = `<input type="text" value="${value}" id="identifier-${rowIndex}" readonly>`;
                    } else if (key === 'Violation_SLM_Reason' && row['Violation_SLM'] === true) {
                        console.log('Editable Violation_SLM_Reason:', value); // Debugging log
                        cellContent = `<input type="text" value="${value}" id="reason-${rowIndex}">`; // Editable reason
                        tr.dataset.violationType = 'SLM'; // Set violation type
                    } else if (key === 'Violation_SLM_Approval' && row['Violation_SLM'] === true) {
                        console.log('Editable Violation_SLM_Approval:', value); // Debugging log
                        cellContent = `
                            <select id="approval">
                                <option value="" ${value === null ? 'selected' : ''}>-- Select --</option>
                                <option value="1" ${value === true || value === 1 ? 'selected' : ''}>Yes</option>
                                <option value="0" ${value === false || value === 0 ? 'selected' : ''}>No</option>
                            </select>
                        `; // Editable dropdown for approval
                    } else if (key === 'Violation_ReqSurvey_Reason' && row['Violation_ReqSurvey'] === true) {
                        console.log('Editable Violation_ReqSurvey_Reason:', value); // Debugging log
                        cellContent = `<input type="text" value="${value}" id="reason-${rowIndex}">`; // Editable reason
                        tr.dataset.violationType = 'ReqSurvey'; // Set violation type
                    } else if (key === 'Violation_ReqSurvey_Approval' && row['Violation_ReqSurvey'] === true) {
                        console.log('Editable Violation_ReqSurvey_Approval:', value); // Debugging log
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
                tbody.appendChild(tr);
            });

            console.log('Table populated successfully:', data); // Log the data for debugging
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Failed to fetch data. Please try again later.');
    }
}