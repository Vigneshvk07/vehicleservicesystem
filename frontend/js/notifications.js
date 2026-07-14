// Modern Toast Notification System

const Toast = {
    init() {
        // Create container if it doesn't exist
        let container = document.getElementById('toast-container');
        if (!container) {
            container = document.createElement('div');
            container.id = 'toast-container';
            container.className = 'toast-container';
            document.body.appendChild(container);
        }
    },

    show(message, type = 'info', duration = 4000) {
        this.init();
        const container = document.getElementById('toast-container');
        
        const toast = document.createElement('div');
        toast.className = `toast-item ${type}`;
        
        // Icons from FontAwesome (optional, fallback to text)
        let iconClass = 'fa-info-circle';
        if (type === 'success') iconClass = 'fa-check-circle';
        if (type === 'error') iconClass = 'fa-exclamation-triangle';
        if (type === 'warning') iconClass = 'fa-exclamation-circle';

        toast.innerHTML = `
            <div class="toast-icon">
                <i class="fas ${iconClass}"></i>
            </div>
            <div class="toast-content">${message}</div>
            <button class="toast-close-btn">&times;</button>
        `;

        container.appendChild(toast);

        // Slide in animation triggers automatically from CSS
        
        // Close event
        const closeBtn = toast.querySelector('.toast-close-btn');
        closeBtn.addEventListener('click', () => this.dismiss(toast));

        // Auto dismiss
        setTimeout(() => {
            if (toast.parentNode) {
                this.dismiss(toast);
            }
        }, duration);
    },

    dismiss(toast) {
        toast.classList.add('toast-dismissing');
        toast.addEventListener('transitionend', () => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        });
    }
};

// Expose globally
window.Toast = Toast;
