const $ = document.querySelector.bind(document);
const $$ = document.querySelectorAll.bind(document);

const categoryATDs = $$('.atd');
categoryATDs.forEach(categoryATD => {
    categoryATD.addEventListener('click', () => {
        categoryATDs.forEach(i => i.classList.remove("category-item--active"))
        categoryATD.classList.add('category-item--active')
    })
})

$$('.atd').forEach(link => {
    link.addEventListener('click', function (e) {
        e.preventDefault();
        // Lấy class mục tiêu từ thuộc tính data-target của liên kết
        const targetClass = this.getAttribute('data-target');

        // Ẩn tất cả các thẻ
        $$('.atd__content').forEach(content => {
            content.style.display = 'none';
        });

        // Hiển thị thẻ tương ứng
        $$(`.${targetClass}`).forEach(targetElement => {
            targetElement.style.display = 'block';
        });
    });
});
