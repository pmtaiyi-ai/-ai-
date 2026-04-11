# 豫见广州网站部署说明

这个网站是纯静态页面，不需要服务器、不需要数据库，也不需要你写代码。

## 当前文件

- `index.html`：网页内容和结构
- `styles.css`：页面视觉设计
- `script.js`：手机端菜单交互

## 免费部署推荐

### 方案一：Netlify

适合完全不写代码的用户。

1. 打开 Netlify，注册或登录账号。
2. 选择 Add new site。
3. 选择 Deploy manually。
4. 把本文件夹拖进去。
5. Netlify 会给你一个免费的 `xxx.netlify.app` 地址。

### 方案二：Cloudflare Pages

适合以后绑定自己的正式域名。

1. 打开 Cloudflare Dashboard。
2. 进入 Workers & Pages。
3. 新建 Pages 项目。
4. 上传静态文件，或连接 GitHub 仓库。
5. 可以使用免费 Pages 地址，也可以绑定自有域名。

### 方案三：GitHub Pages

适合长期维护，有公开仓库即可免费使用。

1. 创建 GitHub 仓库。
2. 上传这三个网站文件。
3. 在 Settings > Pages 里开启部署。
4. 获得 `用户名.github.io/仓库名` 地址。

## 免费域名选择

真正免费的顶级域名越来越少，长期稳定性通常不如付费域名。建议优先使用平台免费二级域名：

- `yujian-guangzhou.netlify.app`
- `yujian-guangzhou.pages.dev`
- `你的用户名.github.io/yujian-guangzhou`

如果必须要免费域名，可以研究：

- `eu.org`：可申请免费子域名，审核慢，不保证通过。
- `pp.ua`：部分地区仍有人使用，规则可能变化。
- 平台自带二级域名：最稳、最快、最少折腾。

正式对外推广时，建议购买一个便宜域名，比如：

- `yujian-gz.com`
- `henan-gz.com`
- `hnren-gz.cn`
- `yujian-guangzhou.cn`

## 上线前替换内容

- 联系人手机号
- 微信二维码或公众号二维码
- 邮箱
- 真实活动照片
- 真实活动时间和地点
- “河南人社群民运主席”是否为公开正式头衔，或是否改为“发起人”“会长”“名誉主席”
