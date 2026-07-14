// Charts.js initialization for Admin Dashboard

document.addEventListener("DOMContentLoaded", () => {
    // 1. Service Status Doughnut Chart
    const statusCtx = document.getElementById("statusChart");
    if (statusCtx) {
        // Fetch raw statistics from dataset attributes on the canvas itself (injected by JSP)
        const pending = parseInt(statusCtx.dataset.pending || "0");
        const approved = parseInt(statusCtx.dataset.approved || "0");
        const inProgress = parseInt(statusCtx.dataset.inProgress || "0");
        const completed = parseInt(statusCtx.dataset.completed || "0");

        new Chart(statusCtx, {
            type: 'doughnut',
            data: {
                labels: ['Pending', 'Approved', 'In Progress', 'Completed'],
                datasets: [{
                    label: 'Service Appointments',
                    data: [pending, approved, inProgress, completed],
                    backgroundColor: [
                        'rgba(255, 193, 7, 0.7)',  // Warning / Yellow
                        'rgba(13, 110, 253, 0.7)', // Info / Blue
                        'rgba(255, 99, 132, 0.7)', // Coral / Pink
                        'rgba(25, 135, 84, 0.7)'   // Success / Green
                    ],
                    borderColor: [
                        'rgba(255, 193, 7, 1)',
                        'rgba(13, 110, 253, 1)',
                        'rgba(255, 99, 132, 1)',
                        'rgba(25, 135, 84, 1)'
                    ],
                    borderWidth: 1.5
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: getComputedStyle(document.body).getPropertyValue('--text-color') || '#333'
                        }
                    }
                }
            }
        });
    }

    // 2. Monthly Revenue Line Chart
    const revenueCtx = document.getElementById("revenueChart");
    if (revenueCtx) {
        const revData = JSON.parse(revenueCtx.dataset.monthly || "[12000, 19000, 3000, 5000, 2000, 3000, 24000]");
        const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];

        new Chart(revenueCtx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Revenue (₹)',
                    data: revData,
                    borderColor: 'rgba(13, 110, 253, 1)',
                    backgroundColor: 'rgba(13, 110, 253, 0.15)',
                    fill: true,
                    tension: 0.3,
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            color: getComputedStyle(document.body).getPropertyValue('--text-color') || '#333'
                        }
                    },
                    x: {
                        ticks: {
                            color: getComputedStyle(document.body).getPropertyValue('--text-color') || '#333'
                        }
                    }
                },
                plugins: {
                    legend: {
                        labels: {
                            color: getComputedStyle(document.body).getPropertyValue('--text-color') || '#333'
                        }
                    }
                }
            }
        });
    }

    // 3. Top Packages Bar Chart
    const packageCtx = document.getElementById("packageChart");
    if (packageCtx) {
        new Chart(packageCtx, {
            type: 'bar',
            data: {
                labels: ['General Service', 'Oil Change', 'Brakes', 'Alignment', 'Wash'],
                datasets: [{
                    label: 'Bookings Count',
                    data: [15, 24, 8, 12, 19],
                    backgroundColor: 'rgba(25, 135, 84, 0.7)',
                    borderColor: 'rgba(25, 135, 84, 1)',
                    borderWidth: 1.5
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            color: getComputedStyle(document.body).getPropertyValue('--text-color') || '#333'
                        }
                    },
                    x: {
                        ticks: {
                            color: getComputedStyle(document.body).getPropertyValue('--text-color') || '#333'
                        }
                    }
                },
                plugins: {
                    legend: {
                        labels: {
                            color: getComputedStyle(document.body).getPropertyValue('--text-color') || '#333'
                        }
                    }
                }
            }
        });
    }
});
