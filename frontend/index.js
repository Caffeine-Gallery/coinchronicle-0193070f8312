import { backend } from "declarations/backend";

let priceChart = null;

async function fetchBitcoinPrice() {
    try {
        const response = await fetch('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd');
        const data = await response.json();
        return data.bitcoin.usd;
    } catch (error) {
        console.error('Error fetching Bitcoin price:', error);
        return null;
    }
}

async function updatePrice() {
    const priceLoader = document.getElementById('priceLoader');
    priceLoader.classList.remove('d-none');
    
    const price = await fetchBitcoinPrice();
    if (price) {
        await backend.addPrice(price);
        document.getElementById('currentPrice').textContent = `$${price.toLocaleString()}`;
        await updatePriceHistory();
    }
    
    priceLoader.classList.add('d-none');
}

function formatDate(timestamp) {
    return new Date(Number(timestamp) / 1000000).toLocaleString();
}

async function updatePriceHistory() {
    const prices = await backend.getLastMonthPrices();
    
    // Update table
    const tableBody = document.getElementById('priceTable');
    tableBody.innerHTML = prices.map(entry => `
        <tr>
            <td>${formatDate(entry.timestamp)}</td>
            <td>$${entry.price.toLocaleString()}</td>
        </tr>
    `).join('');

    // Update chart
    const labels = prices.map(entry => formatDate(entry.timestamp));
    const data = prices.map(entry => entry.price);

    if (priceChart) {
        priceChart.destroy();
    }

    const ctx = document.getElementById('priceChart').getContext('2d');
    priceChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Bitcoin Price (Last 30 Days)',
                data: data,
                borderColor: '#0d6efd',
                tension: 0.1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: false
                }
            }
        }
    });
}

// Initial load
updatePrice();

// Update price every 5 minutes
setInterval(updatePrice, 5 * 60 * 1000);
