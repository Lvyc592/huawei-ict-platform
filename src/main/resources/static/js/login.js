function roleToDashboard(role) {
    if (role === 'student') return 'student/dashboard.html';
    if (role === 'teacher') return 'teacher/dashboard.html';
    if (role === 'admin') return 'admin/dashboard.html';
    return 'index.html';
}
function doLogin() {
    var username = document.getElementById('username').value.trim();
    var password = document.getElementById('password').value.trim();
    var remember = document.getElementById('remember').checked;
    if (!username || !password) { showMsg('请输入账号和密码', 'danger'); return; }
    showMsg('正在登录...', 'info');
    // 不再传 role 字段：后端以账号实际角色为准，自动跳转到对应 dashboard
    fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username: username, password: password })
    }).then(function(resp) { return resp.json(); }).then(function(result) {
        if (result.success) {
            var role = (result.data.role || '').toLowerCase();
            localStorage.setItem('huawei_token', result.data.token);
            localStorage.setItem('huawei_user', JSON.stringify({ id: result.data.userId, name: result.data.name, role: result.data.role }));
            if (remember) { localStorage.setItem('huawei_remembered', JSON.stringify({ username: username })); }
            else { localStorage.removeItem('huawei_remembered'); }
            showMsg('登录成功，正在进入 ' + (result.data.name || '') + ' 的工作台...', 'success');
            setTimeout(function() {
                window.location.href = roleToDashboard(role);
            }, 500);
        } else {
            showMsg(result.message || '登录失败', 'danger');
        }
    }).catch(function(err) {
        showMsg('网络错误，请检查后端服务', 'danger');
        console.error('Login error:', err);
    });
}
function showMsg(text, type) {
    var msg = document.getElementById('loginMsg');
    if (!msg) return;
    msg.style.display = 'block';
    msg.className = 'alert mt-3 alert-' + type;
    var icon = type === 'success' ? 'bi-check-circle-fill' : type === 'danger' ? 'bi-exclamation-triangle-fill' : 'bi-info-circle-fill';
    msg.innerHTML = '<i class="bi ' + icon + ' me-2"></i>' + text;
}
function hideMsg() {
    var msg = document.getElementById('loginMsg');
    if (msg) msg.style.display = 'none';
}
document.addEventListener('DOMContentLoaded', function() {
    var saved = localStorage.getItem('huawei_remembered');
    if (saved) {
        try {
            var d = JSON.parse(saved);
            document.getElementById('username').value = d.username;
            document.getElementById('remember').checked = true;
        } catch(e) {}
    }
});