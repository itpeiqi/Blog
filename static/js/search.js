(function () {
  const input = document.getElementById('search-input');
  const results = document.getElementById('search-results');
  const count = document.getElementById('search-count');

  if (!input || !results || !count) {
    return;
  }

  const escapeHtml = (value) => String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

  const normalize = (value) => String(value || '').toLowerCase().trim();
  const tokensFrom = (value) => normalize(value).split(/\s+/).filter(Boolean);

  const emptyState = (message) => {
    results.innerHTML = `<div class="search-empty">${escapeHtml(message)}</div>`;
  };

  const render = (items, query, total) => {
    count.textContent = query ? `找到 ${items.length} 篇文章` : `共 ${total} 篇文章`;

    if (!items.length) {
      emptyState(query ? '没有找到匹配的文章。换个关键词试试。' : '开始输入关键词，文章会立刻出现。');
      return;
    }

    results.innerHTML = items.map((item) => {
      const tags = Array.isArray(item.tags) ? item.tags : [];
      const tagHtml = tags.length
        ? `<div class="search-tags">${tags.map((tag) => `<span class="tag">${escapeHtml(tag)}</span>`).join('')}</div>`
        : '';

      return `
        <article class="search-card">
          <div class="search-card-top">
            <h2><a href="${escapeHtml(item.url)}">${escapeHtml(item.title)}</a></h2>
            <div class="meta">${escapeHtml(item.date || '')}</div>
          </div>
          <p>${escapeHtml(item.description || item.summary || '没有摘要。')}</p>
          ${tagHtml}
        </article>
      `;
    }).join('');
  };

  const matchItem = (item, tokens) => {
    if (!tokens.length) {
      return true;
    }

    const haystack = normalize([
      item.title,
      item.description,
      item.summary,
      Array.isArray(item.tags) ? item.tags.join(' ') : '',
    ].join(' '));

    return tokens.every((token) => haystack.includes(token));
  };

  let allPosts = [];
  let timer = 0;

  const update = () => {
    const query = input.value.trim();
    const tokens = tokensFrom(query);
    const visible = allPosts.filter((item) => matchItem(item, tokens));
    render(visible, query, allPosts.length);
  };

  fetch('/index.json', { headers: { Accept: 'application/json' } })
    .then((response) => {
      if (!response.ok) {
        throw new Error('无法加载文章索引');
      }
      return response.json();
    })
    .then((data) => {
      allPosts = Array.isArray(data) ? data : [];
      update();
    })
    .catch(() => {
      count.textContent = '搜索索引加载失败';
      emptyState('搜索索引加载失败，请稍后再试。');
    });

  input.addEventListener('input', () => {
    window.clearTimeout(timer);
    timer = window.setTimeout(update, 80);
  });
})();
