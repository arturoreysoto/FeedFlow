# Top 10 RSS Feeds — Casuísticas para FeedFlow

## 1. iconfactory — blog.iconfactory.com/feed/
- **Formato:** RSS 2.0
- **Contenido:** `content:encoded` con CDATA
- **Imágenes:** Dentro del HTML del `content:encoded`
- **Fechas:** `pubDate` estándar
- **Estado:** ✅ Funciona

---

## 2. The Joe Rogan Experience — feeds.megaphone.fm/GLT1412515089
- **Formato:** RSS 2.0 + iTunes namespace
- **Contenido:** `description` con texto plano
- **Imágenes:** `itunes:image` a nivel de **canal** (no por item)
- **Fechas:** `pubDate` estándar
- **Estado:** ✅ Funciona con `channelImageURL`

---

## 3. Reddit r/macapps — reddit.com/r/macapps.rss
- **Formato:** Atom
- **Contenido:** `content` con HTML escapado
- **Imágenes:** Dentro del contenido HTML
- **Fechas:** `updated` en formato ISO 8601
- **Estado:** ⚠️ Fechas pueden no parsearse bien

---

## 4. Daring Fireball — daringfireball.net/feeds/json
- **Formato:** RSS 2.0
- **Contenido:** `description` con HTML
- **Imágenes:** No suele traer imágenes
- **Fechas:** `pubDate` estándar
- **Estado:** ✅ Debería funcionar

---

## 5. YouTube Canal — youtube.com/feeds/videos.xml?channel_id=XXX
- **Formato:** Atom con namespace `media:`
- **Contenido:** `media:description` texto plano
- **Imágenes:** `media:thumbnail` con atributo `url`
- **Fechas:** `published` ISO 8601
- **Estado:** ⚠️ Necesita soporte `media:description`

---

## 6. The Verge — theverge.com/rss/index.xml
- **Formato:** RSS 2.0
- **Contenido:** `content:encoded` con CDATA
- **Imágenes:** Dentro del HTML del `content:encoded`
- **Fechas:** `pubDate` estándar
- **Estado:** ✅ Debería funcionar

---

## 7. Hacker News — news.ycombinator.com/rss
- **Formato:** RSS 2.0
- **Contenido:** `description` muy corto (solo link)
- **Imágenes:** No trae imágenes
- **Fechas:** `pubDate` estándar
- **Estado:** ✅ Funciona pero contenido mínimo

---

## 8. NASA — nasa.gov/rss/dyn/breaking_news.rss
- **Formato:** RSS 2.0
- **Contenido:** `description` con HTML
- **Imágenes:** `enclosure` con `type="image/jpeg"`
- **Fechas:** `pubDate` estándar
- **Estado:** ✅ Funciona con soporte `enclosure` imagen

---

## 9. Spotify Podcast genérico — anchor.fm feeds
- **Formato:** RSS 2.0 + iTunes namespace
- **Contenido:** `description` con HTML o texto
- **Imágenes:** `itunes:image` por **item** con atributo `href`
- **Fechas:** `pubDate` estándar
- **Estado:** ✅ Funciona con `itunes:image` por item

---

## 10. Medium — medium.com/feed/@username
- **Formato:** RSS 2.0
- **Contenido:** `content:encoded` con CDATA
- **Imágenes:** Dentro del HTML del `content:encoded`
- **Fechas:** `pubDate` estándar
- **Estado:** ✅ Debería funcionar

---

## Resumen de campos a soportar

| Campo                       | Uso                           |
| --------------------------- | ----------------------------- |
| `content:encoded` + CDATA   | Blogs, Medium, The Verge      |
| `description`               | Podcasts, HN, Daring Fireball |
| `itunes:image` href (canal) | JRE, Megaphone                |
| `itunes:image` href (item)  | Anchor, Spotify               |
| `media:thumbnail` url       | YouTube                       |
| `enclosure` type=image      | NASA, algunos blogs           |
| `pubDate`                   | RSS estándar                  |
| `published` / `updated`     | Atom (Reddit, YouTube)        |

## Prioridad de contenido recomendada
1. `content:encoded`
2. `content`
3. `description`
4. `summary`

## Prioridad de imagen recomendada
1. `media:thumbnail` url (por item)
2. `itunes:image` href (por item)
3. `enclosure` type=image (por item)
4. `itunes:image` href (canal — fallback)