# ERPNext WooCommerce Image

这个仓库用于构建一个自定义 ERPNext Docker 镜像，在官方 `frappe/erpnext:v16.29.0` 镜像基础上加入 `woocommerce_fusion` App，用于测试 ERPNext 和 WooCommerce 的商品、价格、库存、订单同步能力。

当前目标镜像：

```text
ghcr.io/jasper4860/erpnext-woocommerce-fusion:v16.29.0-test
```

## 项目用途

本仓库不保存 ERPNext 业务数据，也不保存 WooCommerce 密钥。它只负责构建 Docker 镜像。

构建完成后的镜像可用于现有 Docker Compose 部署，把原来的：

```yaml
x-erpnext-image: &erpnext_image "frappe/erpnext:v16.29.0"
```

替换为：

```yaml
x-erpnext-image: &erpnext_image "ghcr.io/jasper4860/erpnext-woocommerce-fusion:v16.29.0-test"
```

## 包含内容

镜像基于：

```text
frappe/erpnext:v16.29.0
```

额外安装：

```text
https://github.com/Starktail/woocommerce_fusion.git
branch: version-15
```

注意：`woocommerce_fusion` 当前使用 `version-15` 分支，而 ERPNext 镜像是 v16.29.0。因此该镜像应先用于测试环境，确认兼容后再考虑生产使用。

## 文件说明

```text
apps.json
Dockerfile
.github/workflows/build.yml
```

- `apps.json`：记录要安装的额外 Frappe App。
- `Dockerfile`：基于官方 ERPNext 镜像安装 WooCommerce Fusion。
- `.github/workflows/build.yml`：GitHub Actions 自动构建并推送镜像到 GHCR。

## 构建方法

1. 打开本仓库的 `Actions` 页面。
2. 选择 `Build ERPNext WooCommerce Image`。
3. 点击 `Run workflow`。
4. 等待构建完成。
5. 构建成功后，会推送镜像到：

```text
ghcr.io/jasper4860/erpnext-woocommerce-fusion:v16.29.0-test
```

## 绿联 NAS Docker Compose 使用方法

在绿联 NAS 的 Docker 项目中，停止 ERPNext 项目后，编辑 Compose 顶部镜像变量：

```yaml
x-erpnext-image: &erpnext_image "ghcr.io/jasper4860/erpnext-woocommerce-fusion:v16.29.0-test"
```

保存并重新部署。

部署完成后，进入 `backend` 容器终端执行：

```bash
bench --site erp.local install-app woocommerce_fusion
bench --site erp.local migrate
bench --site erp.local clear-cache
```

如果你的站点名不是 `erp.local`，请把命令中的 `erp.local` 替换为实际站点名。

## 验证方法

进入 `backend` 容器后执行：

```bash
ls apps
```

应看到：

```text
woocommerce_fusion
```

再执行：

```bash
bench --site erp.local list-apps
```

应看到：

```text
frappe
erpnext
woocommerce_fusion
```

然后登录 ERPNext，检查是否出现 `WooCommerce Fusion` 模块。

## 注意事项

- 不要把数据库密码、WooCommerce API Key、GitHub Token 写进本仓库。
- 该镜像目前用于兼容性测试，不建议直接用于生产环境。
- 安装 App 前建议先备份数据库和 `sites` 卷。
- `install-app` 和 `migrate` 会修改站点数据库结构，回滚时可能需要恢复数据库备份。
- 如果 GitHub Packages 默认是私有包，绿联 NAS 拉取镜像前需要登录 GHCR，或者把 package visibility 调整为 Public。

## 回滚方法

如果镜像启动失败，停止 Docker 项目，把 Compose 改回官方镜像：

```yaml
x-erpnext-image: &erpnext_image "frappe/erpnext:v16.29.0"
```

然后重新部署。

如果已经执行过：

```bash
bench --site erp.local install-app woocommerce_fusion
bench --site erp.local migrate
```

最稳妥的回滚方式是恢复安装前的数据库和 `sites` 备份。
