const API_BASE = '/api';
async function apiRequest(url, options) {
    const token = localStorage.getItem('huawei_token');
    const headers = options && options.headers ? options.headers : {};
    headers['Content-Type'] = 'application/json';
    if (token) headers['Authorization'] = 'Bearer ' + token;
    try {
        const resp = await fetch(API_BASE + url, Object.assign({}, options, { headers: headers }));
        if (resp.status === 403) { localStorage.removeItem('huawei_token'); window.location.href = '../index.html'; return null; }
        return resp.json();
    } catch(e) { return null; }
}
function logout() { if (confirm('确定要退出登录吗？')) { localStorage.removeItem('huawei_token'); window.location.href = '../index.html'; } }
/* 公共JS函数 - 华技云平台 */

// 退出登录
function logout() {
    if (confirm('确定要退出登录吗？')) {
        window.location.href = '../index.html';
    }
}

// 侧边栏激活状态管理
document.addEventListener('DOMContentLoaded', function() {
    const currentPage = window.location.pathname.split('/').pop();
    document.querySelectorAll('.sidebar-menu .menu-item').forEach(item => {
        const href = item.getAttribute('href');
        if (href && href.includes(currentPage)) {
            item.classList.add('active');
        } else {
            item.classList.remove('active');
        }
    });

    // 顶部导航激活状态
    document.querySelectorAll('.header-nav a').forEach(item => {
        const href = item.getAttribute('href');
        if (href && href.includes(currentPage)) {
            item.classList.add('active');
        }
    });
});

// 模拟数据 - 学生信息
const studentData = {
    name: '学生用户',
    role: '华为ICT学员',
    avatar: '学',
    stats: {
        focus: 86,
        accuracy: 72,
        hours: 128,
        level: 'HCIA'
    }
};

// 模拟数据 - 课程列表
const courseList = [
    { id: 1, name: 'HCIA-Datacom 基础认证', progress: 68, status: '进行中', img: 'https://img.alicdn.com/imgextra/i2/O1CN01QeJFdg1YcCZ7XeVDK_!!6000000003069-2.png' },
    { id: 2, name: 'HCIP-Datacom 高级认证', progress: 0, status: '未开始', img: 'https://img.alicdn.com/imgextra/i4/O1CN01ZJQzfT1YcCZ8WqXyG_!!6000000003069-2.png' },
    { id: 3, name: 'HCIE-Datacom 专家认证', progress: 0, status: '未开始', img: 'https://img.alicdn.com/imgextra/i3/O1CN01ABC1231YcCZ9RrXZ_!!6000000003069-2.png' },
    { id: 4, name: '华为云计算基础', progress: 45, status: '进行中', img: 'https://img.alicdn.com/imgextra/i1/O1CN01Cloud1YcCZAaBbCC_!!6000000003069-2.png' }
];

// 模拟数据 - 题库列表
const examList = [
    { id: 1, title: 'HCIA-Datacom 模拟题（一）', questions: 50, score: 72, date: '2024-06-10' },
    { id: 2, title: 'HCIA-Datacom 模拟题（二）', questions: 50, score: 85, date: '2024-06-08' },
    { id: 3, title: 'HCIP-Datacom 模拟题（一）', questions: 60, score: null, date: null },
    { id: 4, title: 'HCIE 实验模拟题', questions: 30, score: null, date: null }
];

// 格式化日期
function formatDate(date) {
    const d = new Date(date);
    return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
}

// 显示提示
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.style.cssText = `
        position: fixed; top: 20px; right: 20px; z-index: 9999;
        padding: 12px 24px; border-radius: 8px; color: white;
        background: ${type === 'success' ? '#28a745' : type === 'danger' ? '#dc3545' : '#17a2b8'};
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        animation: slideIn 0.3s ease;
    `;
    toast.innerHTML = message;
    document.body.appendChild(toast);
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transition = 'opacity 0.3s';
        setTimeout(() => toast.remove(), 300);
    }, 2500);
}

// 添加CSS动画
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
`;
document.head.appendChild(style);
