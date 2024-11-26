class CopyToClipboard {
    constructor(selector) {
        this.elements = document.querySelectorAll(selector);
        this.init();
    }

    init() {
        this.elements.forEach((element) => {
            element.style.cursor = 'pointer';
            element.style.color = 'blue';
            element.style.textDecoration = 'underline';
            element.style.position = 'relative';

            element.addEventListener('click', () => {
                const word = element.textContent.trim();
                navigator.clipboard.writeText(word);

                this.showTooltip(element, "Copied!");
            });
        });
    }

    showTooltip(element, message) {
        const tooltip = document.createElement('span');
        tooltip.textContent = message;
        tooltip.classList.add('tooltip');

        element.appendChild(tooltip);

        setTimeout(() => {
            if (tooltip.parentNode === element) {
                element.removeChild(tooltip);
            }
        }, 1000);
    }
}

// Initialize copy-to-clipboard functionality
document.addEventListener('DOMContentLoaded', () => {
    new CopyToClipboard('span.copyable');
});
