module ApplicationHelper
  def markdown_to_html(text)
    renderer = Redcarpet::Render::HTML.new(escape_html: true, safe_links_only: true)
    Redcarpet::Markdown.new(renderer, autolink: true, quote: true).render(text).html_safe
  end
end
