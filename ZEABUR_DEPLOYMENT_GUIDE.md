# 华技云·华为ICT智慧实训平台 — Zeabur 上云部署指南

> 项目类型：**Spring Boot 单体应用**（前端页面内嵌在 `static/` 目录，无需单独部署前端）
> 适用平台：https://zeabur.com（国内节点，免费额度，无休眠）

---

## 一、已完成的云端适配修改

### ✅ 1. 数据库配置改为环境变量（`application.yml`）

```yaml
spring:
  datasource:
    url: jdbc:mysql://${ZEABUR_MYSQL_HOST:localhost}:${ZEABUR_MYSQL_PORT:3306}/${ZEABUR_MYSQL_DATABASE:huawei_ict}?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=utf-8&allowPublicKeyRetrieval=true
    username: ${ZEABUR_MYSQL_USERNAME:root}
    password: ${ZEABUR_MYSQL_PASSWORD:root}
```

本地开发时不影响原有功能（默认连接 localhost），上线后读取 Zeabur 环境变量。

### ✅ 2. CORS 跨域已开启（`SecurityConfig.java`）

```java
configuration.setAllowedOrigins(Arrays.asList("*"));
```

允许所有来源访问 API，上线后可根据需要限制为具体域名。

### ✅ 3. 已创建 `Dockerfile`

多阶段构建，使用 JDK 21 编译，JRE 21 运行，支持 Zeabur 动态端口。

### ✅ 4. 已合并 SQL 初始化脚本

`sql/zeabur-init-all.sql`（837行），可直接导入 Zeabur MySQL。

---

## 二、注册 Zeabur 账号

1. 打开官网：https://zeabur.com
2. 推荐使用 **GitHub 登录**（最快捷）
3. 首次登录创建**组织**（填个人名称即可）

---

## 三、新建项目

1. 控制台点击 **New Project**
2. 项目名称：`huawei-ict-platform`
3. 区域选择：**China**（中国内地节点，访问速度快）
4. 点击创建，进入项目面板

---

## 四、第一步：部署 MySQL 数据库

1. 项目面板点击 **Deploy New Service** → 选择 **Databases** → **MySQL**
2. 数据库名称：`huawei-ict-mysql`，版本选 **8.0**
3. 等待约 1 分钟构建完成
4. 进入数据库详情页，点击 **Variables** 标签，复制以下 5 个环境变量（后面后端要用）：

| 变量名 | 说明 |
|--------|------|
| `ZEABUR_MYSQL_HOST` | 数据库主机地址 |
| `ZEABUR_MYSQL_PORT` | 端口（通常是 3306） |
| `ZEABUR_MYSQL_USERNAME` | 用户名 |
| `ZEABUR_MYSQL_PASSWORD` | 密码 |
| `ZEABUR_MYSQL_DATABASE` | 数据库名称 |

5. 点击数据库详情页的 **Connect** 或 **phpMyAdmin** 入口
6. 选择数据库，点击 **Import**，上传项目里的 `sql/zeabur-init-all.sql`
7. 等待导入完成（表结构 + 初始化数据全部就绪）

---

## 五、第二步：部署 Spring Boot 后端（单体，含前端）

> ⚠️ 注意：本项目是单体应用，前端页面在 `static/` 目录里，
> 只需要部署这一个服务，不需要单独部署前端！

### 方式 A：使用 Dockerfile 部署（推荐）

1. 项目面板点击 **Deploy New Service** → 选择 **Dockerfile**
2. 连接 GitHub 仓库（如果代码已推到 GitHub）
3. Zeabur 自动识别 `Dockerfile`，开始构建
4. 构建完成后进入 **Environment Variables**，添加以下变量：

```
ZEABUR_MYSQL_HOST       = (从上面 MySQL 服务复制)
ZEABUR_MYSQL_PORT       = 3306
ZEABUR_MYSQL_USERNAME   = (从上面 MySQL 服务复制)
ZEABUR_MYSQL_PASSWORD   = (从上面 MySQL 服务复制)
ZEABUR_MYSQL_DATABASE   = huawei_ict
```

5. 点击 **Redeploy** 使环境变量生效
6. 部署成功后，进入 **Networking** → **Generate Domain**
7. 复制生成的后端域名，格式为：`https://huawei-ict-platform.zeabur.app`

### 方式 B：Local Project 上传（无 GitHub 时使用）

1. 将整个项目文件夹压缩为 `.zip`（不含 `target/` 目录）
2. 项目面板点击 **Deploy New Service** → **Local Project**
3. 拖拽上传 zip 压缩包
4. Zeabur 自动识别为 Java/Maven 项目
   - 构建命令：`mvn clean package -DskipTests`
   - 启动命令：`java -jar target/ict-platform-1.0.0.jar`
5. 同样需要添加上述 5 条数据库环境变量
6. 部署完成后生成域名

---

## 六、访问测试

1. 打开生成的 Zeabur 域名：`https://xxx.zeabur.app`
2. 应看到登录页面（`index.html`）
3. 测试登录：
   - 管理员账号：`admin` / `admin123`（见 `02-init-data.sql`）
   - 学生账号：`student` / `123456`
4. 测试主要功能：课程浏览、模拟考试、题库练习

---

## 七、绑定自有域名（可选，软著演示用）

1. 进入服务详情 → **Networking** → **Custom Domain**
2. 点击 **Add Domain**，填写你的域名（如 `ict.xxx.com`）
3. 按提示在域名服务商处添加 **CNAME 记录**
4. Zeabur 自动签发 **SSL 证书**（免费）

---

## 八、后续更新代码流程

### 若使用 GitHub 自动部署（推荐）

1. 本地修改代码
2. `git push` 到 GitHub
3. Zeabur 自动检测并重新构建部署

### 若使用 Local Project 上传

1. 本地重新打包或确保代码最新
2. 进入 Zeabur 服务 → **Deployments** → **Redeploy**
3. 重新上传 zip 包

---

## 九、环境变量完整清单

除了数据库相关的 5 条，还可以根据需要添加：

```
# JWT 配置（可选，已有默认值）
APP_JWT_SECRET=HuaweiICTPlatform2024SecretKeyForJWTTokenGeneration
APP_JWT_EXPIRATION_MS=86400000

# AI 引擎配置（上线后 Ollama 不可用，自动降级为知识库）
APP_AI_ENGINE=auto
```

---

## 十、常见问题排查

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| 服务构建失败 | Java 版本不匹配 | 确认 Dockerfile 使用 JDK 21 |
| 数据库连接失败 | 环境变量未填或填错 | 检查 5 条数据库变量是否完整 |
| 页面 404 | 静态资源路径问题 | 检查 `static/` 目录是否在 jar 包内 |
| 登录失败 | 数据库无初始化数据 | 确认 `zeabur-init-all.sql` 已导入 |
| 端口错误 | Zeabur 动态端口未读取 | 确认 Dockerfile 的 ENTRYPOINT 包含 `--server.port=${PORT:-8080}` |

---

## 十一、项目文件清单（部署相关）

```
springboot-huawei-ict(1)/
├── Dockerfile              ← 新增，供 Zeabur 构建
├── pom.xml                 ← 无需修改
├── sql/
│   └── zeabur-init-all.sql ← 新增，合并后的初始化脚本
├── src/main/resources/
│   └── application.yml     ← 已修改，支持环境变量
└── target/
    └── ict-platform-1.0.0.jar  ← Maven 打包后生成
```

---

*部署指南生成时间：2026-06-18*
*适用 Zeabur 版本：2025 最新版*
